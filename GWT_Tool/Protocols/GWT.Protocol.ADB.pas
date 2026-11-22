unit GWT.Protocol.ADB;

interface

uses
  Winapi.Windows, Winapi.Winsock2, System.SysUtils, System.Classes,
  GWT.Types, GWT.WinUSB.Transport;

const
  A_SYNC = $434E5953; // 'SYNC'
  A_CNXN = $4E584E43; // 'CNXN'
  A_OPEN = $4E45504F; // 'OPEN'
  A_OKAY = $59414B4F; // 'OKAY'
  A_CLSE = $45534C43; // 'CLSE'
  A_WRTE = $45545257; // 'WRTE'
  A_AUTH = $48545541; // 'AUTH'

  A_VERSION      = $01000000;
  A_MAXDATA      = 1024 * 1024; // 1 MB buffer limit
  A_AUTH_TOKEN   = 1;
  A_AUTH_SIGNATURE = 2;
  A_AUTH_RSAPUBLICKEY = 3;

type
  TADBMessage = packed record
    Command: Cardinal;
    Arg0: Cardinal;
    Arg1: Cardinal;
    DataLength: Cardinal;
    DataCheck: Cardinal;
    Magic: Cardinal;
  end;
  PADBMessage = ^TADBMessage;

  TADBOutputCallback = reference to procedure(const AText: string);

  // Raw WinUSB bulk endpoints packet engine
  TGWTADBPacketEngine = class
  private
    FTransport: TGWTWinUsbTransport;
    FOnLog: TLogCallback;
    FLocalStreamId: Cardinal;
    FRemoteStreamId: Cardinal;
    FIsConnected: Boolean;
    procedure Log(const AMsg: string; ALevel: TLogLevel);
    class function CalcDataCheck(const AData: TBytes): Cardinal; static;
    function SendPacket(ACommand, AArg0, AArg1: Cardinal; const APayload: TBytes): Boolean;
    function ReadPacket(out AMsg: TADBMessage; out APayload: TBytes): Boolean;
  public
    constructor Create(ATransport: TGWTWinUsbTransport; AOnLog: TLogCallback);

    function Connect(const ASystemIdentity: string = 'host::features=cmd,shell_v2'): Boolean;
    function OpenService(const AService: string): Boolean;
    function ExecuteShell(const ACmd: string; AOnOutput: TADBOutputCallback = nil): Boolean;
    function Reboot(const ATarget: string = ''): Boolean;
    procedure CloseStream;

    property IsConnected: Boolean read FIsConnected;
  end;

  // Local ADB daemon loopback client (127.0.0.1:5037)
  TGWTADBSocketClient = class
  private
    FOnLog: TLogCallback;
    procedure Log(const AMsg: string; ALevel: TLogLevel);
    function OpenSocket: TSocket;
    procedure CloseSocket(ASock: TSocket);
    function SendRequest(ASock: TSocket; const AReq: string): Boolean;
    function ReadStatus(ASock: TSocket; out AStatus: string): Boolean;
    function ReadHexLengthPayload(ASock: TSocket; out APayload: string): Boolean;
  public
    constructor Create(AOnLog: TLogCallback);

    function IsServerRunning: Boolean;
    procedure EnsureServerRunning;
    function GetDeviceList: TArray<TUsbDeviceInfo>;
    function ExecuteShell(const ASerial, ACmd: string; out AOutput: string): Boolean;
    function Reboot(const ASerial, ATarget: string): Boolean;
  end;

implementation

{ TGWTADBPacketEngine }

constructor TGWTADBPacketEngine.Create(ATransport: TGWTWinUsbTransport; AOnLog: TLogCallback);
begin
  inherited Create;
  FTransport := ATransport;
  FOnLog := AOnLog;
  FLocalStreamId := 1;
  FRemoteStreamId := 0;
  FIsConnected := False;
end;

procedure TGWTADBPacketEngine.Log(const AMsg: string; ALevel: TLogLevel);
begin
  if Assigned(FOnLog) then
    FOnLog(AMsg, ALevel);
end;

class function TGWTADBPacketEngine.CalcDataCheck(const AData: TBytes): Cardinal;
var
  I: NativeInt;
begin
  Result := 0;
  for I := 0 to High(AData) do
    Inc(Result, AData[I]);
end;

function TGWTADBPacketEngine.SendPacket(ACommand, AArg0, AArg1: Cardinal;
  const APayload: TBytes): Boolean;
var
  Hdr: TADBMessage;
  Written: Cardinal;
begin
  Hdr.Command := ACommand;
  Hdr.Arg0 := AArg0;
  Hdr.Arg1 := AArg1;
  Hdr.DataLength := Cardinal(Length(APayload));
  Hdr.DataCheck := CalcDataCheck(APayload);
  Hdr.Magic := ACommand xor $FFFFFFFF;

  Result := FTransport.WriteBuffer(@Hdr, SizeOf(Hdr), Written) and (Written = SizeOf(Hdr));
  if not Result then
  begin
    Log('Failed writing ADB packet header.', llError);
    Exit(False);
  end;

  if Hdr.DataLength > 0 then
  begin
    Result := FTransport.WriteBuffer(@APayload[0], Hdr.DataLength, Written) and (Written = Hdr.DataLength);
    if not Result then
      Log('Failed writing ADB packet payload.', llError);
  end;
end;

function TGWTADBPacketEngine.ReadPacket(out AMsg: TADBMessage; out APayload: TBytes): Boolean;
var
  RawHdr, RawData: TBytes;
begin
  AMsg := Default(TADBMessage);
  SetLength(APayload, 0);

  if not FTransport.ReadRaw(SizeOf(TADBMessage), RawHdr) or (Length(RawHdr) < SizeOf(TADBMessage)) then
  begin
    Log('Failed reading ADB packet header.', llError);
    Exit(False);
  end;

  Move(RawHdr[0], AMsg, SizeOf(TADBMessage));

  if (AMsg.Command xor $FFFFFFFF) <> AMsg.Magic then
  begin
    Log('ADB packet header magic corrupted.', llError);
    Exit(False);
  end;

  if AMsg.DataLength > 0 then
  begin
    if not FTransport.ReadRaw(AMsg.DataLength, RawData) or (Cardinal(Length(RawData)) < AMsg.DataLength) then
    begin
      Log('Failed reading complete ADB packet payload.', llError);
      Exit(False);
    end;

    if CalcDataCheck(RawData) <> AMsg.DataCheck then
    begin
      Log('ADB packet checksum mismatch.', llError);
      Exit(False);
    end;

    APayload := RawData;
  end;

  Result := True;
end;

function LoadAdbPublicKey: string;
var
  Paths: array of string;
  P, Content: string;
  SL: TStringList;
begin
  Result := '';
  Paths := [
    GetEnvironmentVariable('USERPROFILE') + '\.android\adbkey.pub',
    ExtractFilePath(ParamStr(0)) + 'adbkey.pub',
    'C:\Users\' + GetEnvironmentVariable('USERNAME') + '\.android\adbkey.pub'
  ];

  for P in Paths do
  begin
    if (P <> '') and FileExists(P) then
    begin
      SL := TStringList.Create;
      try
        SL.LoadFromFile(P);
        Content := Trim(SL.Text);
        if Content <> '' then
        begin
          Result := Content;
          Exit;
        end;
      finally
        SL.Free;
      end;
    end;
  end;

  Result := 'QAAAACVs1xFTMA1xWDvYaQLKMAVpNZ+7f8WQ4SAsELqVzzhajSIRnvRzaDVoZQAB0jBWGytC0qbWUy0f4tUKOS5m/fZ+CDQwg/Di9uPm4bM/zB0W9ybl1n/DA8ojWhJHpVQ5ZolZJ2+nqmP9Ox6SBTGqixS0uLrf+WfCBJfPWzSTfyoZYMTfFmXDohQTusxXUre8EzsflEZrzj8TIJH54xLwoqbu3grJAGMDz6DSUBx5pAUcNxWMp6rRaNhlG6UzxPFIHNQe3VDcz9gl0MN3cPhWKL7v+B6M9TnANj0FFYe19Yz0i8K9AUjYE6KGAQkjcbLo3P01h0sn/yL9e/8HpjMnRDLwwzfcTMKkIOxEv6s7W0LPcs8o7e+MkN+W1kCAIqMN3xtzLX+4d8deCfpggCkHKjk+447bcwJQ4QxhQzfDexfgjH3U33UykktfCF55UogengPUZJV8hQpy0hPgvoHNGfnjFWypWfMXXudutemwVC2gj0Ei3+2VOn9Y9T02baKHF5oMAa+NixK774Dsvmn8gxt/UXBwdqlarsx4Hi87JLf0RL1BiqHawz9Aora900wHrCLG6uHUb9xPDLwfkl2jHLy7Yahq6FEYSlz1KPIxBDJdbLEGLuD59Gx+8b9gqgxSPy9aFDHK//1ia0JvUpyxwK+nfje9BcRjy5n296WtbvXX6xFIkQEAAQA= GWT_Tool@desktop';
end;

function TGWTADBPacketEngine.Connect(const ASystemIdentity: string): Boolean;
var
  Payload: TBytes;
  Msg: TADBMessage;
  RespPayload: TBytes;
  Ident, PubKey: string;
begin
  Result := False;
  FIsConnected := False;
  Payload := TEncoding.ASCII.GetBytes(ASystemIdentity + #0);

  Log('ADB >> CNXN (Native USB Handshake)', llTx);
  if not SendPacket(A_CNXN, A_VERSION, A_MAXDATA, Payload) then
    Exit;

  if not ReadPacket(Msg, RespPayload) then
    Exit;

  if Msg.Command = A_AUTH then
  begin
    Log('Device sent RSA challenge. Sending native RSA Public Key...', llTx);
    PubKey := LoadAdbPublicKey;
    Payload := TEncoding.ASCII.GetBytes(PubKey + #0);

    if not SendPacket(A_AUTH, A_AUTH_RSAPUBLICKEY, 0, Payload) then
    begin
      Log('Failed sending RSA Public Key to device.', llError);
      Exit(False);
    end;

    Log('Waiting for authorization (Please tap ALLOW on phone screen)...', llInfo);
    if not ReadPacket(Msg, RespPayload) then
    begin
      Log('Device disconnected or rejected RSA authorization.', llError);
      Exit(False);
    end;
  end;

  if Msg.Command = A_CNXN then
  begin
    Ident := TEncoding.UTF8.GetString(RespPayload);
    Log('ADB << CNXN: ' + Ident, llSuccess);
    FIsConnected := True;
    Result := True;
  end
  else
    Log(Format('Unexpected ADB response command: 0x%.8X', [Msg.Command]), llError);
end;

function TGWTADBPacketEngine.OpenService(const AService: string): Boolean;
var
  Payload: TBytes;
  Msg: TADBMessage;
  RespPayload: TBytes;
begin
  Result := False;
  if not FIsConnected then
  begin
    Log('ADB not connected.', llError);
    Exit;
  end;

  Inc(FLocalStreamId);
  Payload := TEncoding.ASCII.GetBytes(AService + #0);
  Log('ADB >> OPEN ' + AService, llTx);

  if not SendPacket(A_OPEN, FLocalStreamId, 0, Payload) then
    Exit;

  if not ReadPacket(Msg, RespPayload) then
    Exit;

  if (Msg.Command = A_OKAY) and (Msg.Arg1 = FLocalStreamId) then
  begin
    FRemoteStreamId := Msg.Arg0;
    Result := True;
  end
  else if Msg.Command = A_CLSE then
  begin
    Log('ADB service stream closed by remote.', llWarning);
    FRemoteStreamId := 0;
  end;
end;

function TGWTADBPacketEngine.ExecuteShell(const ACmd: string; AOnOutput: TADBOutputCallback): Boolean;
var
  Msg: TADBMessage;
  Payload: TBytes;
  Text: string;
begin
  Result := False;
  if not OpenService('shell:' + ACmd) then
    Exit;

  while True do
  begin
    if not ReadPacket(Msg, Payload) then
      Break;

    if Msg.Command = A_WRTE then
    begin
      Text := TEncoding.UTF8.GetString(Payload);
      if Assigned(AOnOutput) then
        AOnOutput(Text)
      else
        Log(Text, llRx);

      SendPacket(A_OKAY, FLocalStreamId, FRemoteStreamId, nil);
    end
    else if Msg.Command = A_CLSE then
    begin
      SendPacket(A_CLSE, FLocalStreamId, FRemoteStreamId, nil);
      FRemoteStreamId := 0;
      Result := True;
      Break;
    end;
  end;
end;

function TGWTADBPacketEngine.Reboot(const ATarget: string): Boolean;
var
  Svc: string;
begin
  if ATarget <> '' then
    Svc := 'reboot:' + ATarget
  else
    Svc := 'reboot:';
  Result := OpenService(Svc);
end;

procedure TGWTADBPacketEngine.CloseStream;
begin
  if FRemoteStreamId <> 0 then
  begin
    SendPacket(A_CLSE, FLocalStreamId, FRemoteStreamId, nil);
    FRemoteStreamId := 0;
  end;
end;

{ TGWTADBSocketClient }

constructor TGWTADBSocketClient.Create(AOnLog: TLogCallback);
begin
  inherited Create;
  FOnLog := AOnLog;
end;

procedure TGWTADBSocketClient.Log(const AMsg: string; ALevel: TLogLevel);
begin
  if Assigned(FOnLog) then
    FOnLog(AMsg, ALevel);
end;

function TGWTADBSocketClient.OpenSocket: TSocket;
var
  WSA: TWSAData;
  Addr: TSockAddrIn;
  S: TSocket;
begin
  Result := INVALID_SOCKET;
  if WSAStartup(MAKEWORD(2, 2), WSA) <> 0 then
    Exit;

  S := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if S = INVALID_SOCKET then
  begin
    WSACleanup;
    Exit;
  end;

  ZeroMemory(@Addr, SizeOf(Addr));
  Addr.sin_family := AF_INET;
  Addr.sin_port := htons(5037);
  Addr.sin_addr.S_addr := inet_addr('127.0.0.1');

  if connect(S, PSockAddr(@Addr)^, SizeOf(Addr)) = 0 then
    Result := S
  else
  begin
    Winapi.Winsock2.closesocket(S);
    Winapi.Winsock2.WSACleanup;
  end;
end;

procedure TGWTADBSocketClient.CloseSocket(ASock: TSocket);
begin
  if ASock <> INVALID_SOCKET then
  begin
    Winapi.Winsock2.closesocket(ASock);
    Winapi.Winsock2.WSACleanup;
  end;
end;

function TGWTADBSocketClient.SendRequest(ASock: TSocket; const AReq: string): Boolean;
var
  Hdr: string;
  Bytes: TBytes;
begin
  Hdr := Format('%.4X%s', [Length(AReq), AReq]);
  Bytes := TEncoding.UTF8.GetBytes(Hdr);
  Result := send(ASock, Bytes[0], Integer(Length(Bytes)), 0) = Length(Bytes);
end;

function TGWTADBSocketClient.ReadStatus(ASock: TSocket; out AStatus: string): Boolean;
var
  Buf: array[0..3] of AnsiChar;
  ReadBytes: Integer;
begin
  Result := False;
  AStatus := '';
  ReadBytes := recv(ASock, Buf[0], 4, 0);
  if ReadBytes = 4 then
  begin
    SetString(AStatus, PAnsiChar(@Buf[0]), 4);
    Result := (AStatus = 'OKAY');
  end;
end;

function TGWTADBSocketClient.ReadHexLengthPayload(ASock: TSocket; out APayload: string): Boolean;
var
  HexBuf: array[0..3] of AnsiChar;
  LenStr: string;
  DataLen, TotalRead, ReadBytes: Integer;
  DataBuf: TBytes;
begin
  Result := False;
  APayload := '';
  if recv(ASock, HexBuf[0], 4, 0) <> 4 then
    Exit;

  SetString(LenStr, PAnsiChar(@HexBuf[0]), 4);
  DataLen := StrToIntDef('$' + LenStr, 0);
  if DataLen <= 0 then
  begin
    APayload := '';
    Exit(True);
  end;

  SetLength(DataBuf, DataLen);
  TotalRead := 0;
  while TotalRead < DataLen do
  begin
    ReadBytes := recv(ASock, DataBuf[TotalRead], DataLen - TotalRead, 0);
    if ReadBytes <= 0 then Break;
    Inc(TotalRead, ReadBytes);
  end;

  if TotalRead = DataLen then
  begin
    APayload := TEncoding.UTF8.GetString(DataBuf);
    Result := True;
  end;
end;

function TGWTADBSocketClient.IsServerRunning: Boolean;
var
  S: TSocket;
begin
  S := OpenSocket;
  Result := (S <> INVALID_SOCKET);
  if Result then CloseSocket(S);
end;

procedure TGWTADBSocketClient.EnsureServerRunning;
var
  CandidatePaths: array of string;
  P, AdbExe: string;
  SI: TStartupInfo;
  PI: TProcessInformation;
begin
  if IsServerRunning then Exit;

  CandidatePaths := [
    ExtractFilePath(ParamStr(0)) + 'adb.exe',
    ExtractFilePath(ParamStr(0)) + 'app\scrcpy\adb.exe',
    'D:\studio\tools\GWT\app\scrcpy\adb.exe',
    'D:\studio\tools\Final\adb\adb.exe',
    'C:\platform-tools\adb.exe'
  ];

  AdbExe := '';
  for P in CandidatePaths do
  begin
    if FileExists(P) then
    begin
      AdbExe := P;
      Break;
    end;
  end;

  if AdbExe <> '' then
  begin
    ZeroMemory(@SI, SizeOf(SI));
    SI.cb := SizeOf(SI);
    SI.dwFlags := STARTF_USESHOWWINDOW;
    SI.wShowWindow := SW_HIDE;
    if CreateProcess(nil, PChar('"' + AdbExe + '" start-server'), nil, nil, False,
      CREATE_NO_WINDOW, nil, nil, SI, PI) then
    begin
      WaitForSingleObject(PI.hProcess, 3000);
      CloseHandle(PI.hProcess);
      CloseHandle(PI.hThread);
      Sleep(400);
      Log('Started local ADB daemon server: ' + AdbExe, llInfo);
    end;
  end
  else
    Log('ADB server not active and no local adb.exe candidate found.', llWarning);
end;

function TGWTADBSocketClient.GetDeviceList: TArray<TUsbDeviceInfo>;
var
  S: TSocket;
  Status, RawList: string;
  Lines: TArray<string>;
  Line, Ser, State, ModelName, P: string;
  Parts: TArray<string>;
  Item: TUsbDeviceInfo;
begin
  Result := nil;
  EnsureServerRunning;
  S := OpenSocket;
  if S = INVALID_SOCKET then Exit;

  try
    // Prefer host:devices-l for rich model/product details, fallback to host:devices
    if not (SendRequest(S, 'host:devices-l') and ReadStatus(S, Status) and ReadHexLengthPayload(S, RawList)) then
    begin
      CloseSocket(S);
      S := OpenSocket;
      if S = INVALID_SOCKET then Exit;
      if not (SendRequest(S, 'host:devices') and ReadStatus(S, Status) and ReadHexLengthPayload(S, RawList)) then
        Exit;
    end;

    Lines := RawList.Split([#13#10, #10], TStringSplitOptions.ExcludeEmpty);
    for Line in Lines do
    begin
      Parts := Line.Split([#9, ' '], TStringSplitOptions.ExcludeEmpty);
      if Length(Parts) >= 2 then
      begin
        Ser := Parts[0];
        State := Parts[1];
        ModelName := '';

        for P in Parts do
        begin
          if P.StartsWith('model:') then
            ModelName := P.Substring(6).Replace('_', ' ');
        end;

        Item.DevicePath := 'socket:' + Ser;
        Item.Serial := Ser;
        Item.InterfaceType := 'ADB';
        Item.IsSocketBased := True;
        Item.VID := 0;
        Item.PID := 0;

        if SameText(State, 'unauthorized') then
          Item.FriendlyName := Format('[ADB] %s (UNAUTHORIZED - Check Screen)', [Ser])
        else if SameText(State, 'offline') then
          Item.FriendlyName := Format('[ADB] %s (OFFLINE)', [Ser])
        else if ModelName <> '' then
          Item.FriendlyName := Format('[ADB] %s (%s)', [Ser, ModelName])
        else
          Item.FriendlyName := Format('[ADB] %s (ONLINE)', [Ser]);

        SetLength(Result, Length(Result) + 1);
        Result[High(Result)] := Item;
      end;
    end;
  finally
    CloseSocket(S);
  end;
end;

function TGWTADBSocketClient.ExecuteShell(const ASerial, ACmd: string; out AOutput: string): Boolean;
var
  S: TSocket;
  Status: string;
  TransportReq: string;
  Buf: TBytes;
  ReadBytes: Integer;
  SB: TStringBuilder;
begin
  Result := False;
  AOutput := '';
  S := OpenSocket;
  if S = INVALID_SOCKET then Exit;

  try
    if ASerial <> '' then
      TransportReq := 'host:transport:' + ASerial
    else
      TransportReq := 'host:transport-any';

    if not SendRequest(S, TransportReq) or not ReadStatus(S, Status) then
      Exit;

    if not SendRequest(S, 'shell:' + ACmd) or not ReadStatus(S, Status) then
      Exit;

    SetLength(Buf, 4096);
    SB := TStringBuilder.Create;
    try
      while True do
      begin
        ReadBytes := recv(S, Buf[0], Length(Buf), 0);
        if ReadBytes <= 0 then Break;
        SB.Append(TEncoding.UTF8.GetString(Buf, 0, ReadBytes));
      end;
      AOutput := SB.ToString;
      Result := True;
    finally
      SB.Free;
    end;
  finally
    CloseSocket(S);
  end;
end;

function TGWTADBSocketClient.Reboot(const ASerial, ATarget: string): Boolean;
var
  S: TSocket;
  Status, TargetStr, TransportReq: string;
begin
  Result := False;
  S := OpenSocket;
  if S = INVALID_SOCKET then Exit;

  try
    if ASerial <> '' then
      TransportReq := 'host:transport:' + ASerial
    else
      TransportReq := 'host:transport-any';

    if not SendRequest(S, TransportReq) or not ReadStatus(S, Status) then
      Exit;

    if ATarget <> '' then
      TargetStr := 'reboot:' + ATarget
    else
      TargetStr := 'reboot:';

    Result := SendRequest(S, TargetStr) and ReadStatus(S, Status);
  finally
    CloseSocket(S);
  end;
end;

end.
