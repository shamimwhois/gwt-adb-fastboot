unit GWT.Protocol.Fastboot;

interface

uses
  System.SysUtils, System.Classes, System.Math,
  GWT.Types, GWT.WinUSB.Transport;

type
  TFastbootResponse = record
    Success: Boolean;
    Status: string;   // 'OKAY', 'FAIL', 'DATA'
    Payload: string;
    InfoLines: TArray<string>;
  end;

  TGWTFastbootEngine = class
  private
    FTransport: TGWTWinUsbTransport;
    FOnLog: TLogCallback;
    procedure Log(const AMsg: string; ALevel: TLogLevel);
    function ReadResponseLoop(out AResp: TFastbootResponse): Boolean;
  public
    constructor Create(ATransport: TGWTWinUsbTransport; AOnLog: TLogCallback);

    function SendCommand(const ACmd: string; out AResp: TFastbootResponse): Boolean;
    function GetVar(const AVarName: string; out AValue: string): Boolean;
    function OemCommand(const AOemArgs: string): Boolean;
    function ErasePartition(const APartition: string): Boolean;
    function DownloadAndFlash(const APartition, AFilePath: string;
      AOnProgress: TProgressCallback = nil): Boolean;
    function Reboot(const ATarget: string = ''): Boolean;
  end;

implementation

const
  FASTBOOT_RESPONSE_MAX = 64;
  FASTBOOT_CHUNK_SIZE   = 1024 * 1024; // 1 MB transfer chunks

constructor TGWTFastbootEngine.Create(ATransport: TGWTWinUsbTransport; AOnLog: TLogCallback);
begin
  inherited Create;
  FTransport := ATransport;
  FOnLog := AOnLog;
end;

procedure TGWTFastbootEngine.Log(const AMsg: string; ALevel: TLogLevel);
begin
  if Assigned(FOnLog) then
    FOnLog(AMsg, ALevel);
end;

function TGWTFastbootEngine.ReadResponseLoop(out AResp: TFastbootResponse): Boolean;
var
  Raw: TBytes;
  Text, Prefix, Body: string;
begin
  AResp := Default(TFastbootResponse);

  while True do
  begin
    if not FTransport.ReadRaw(FASTBOOT_RESPONSE_MAX, Raw) then
    begin
      AResp.Status := 'FAIL';
      AResp.Payload := 'USB Read timeout or device disconnected.';
      Log(AResp.Payload, llError);
      Exit(False);
    end;

    if Length(Raw) < 4 then
    begin
      AResp.Status := 'FAIL';
      AResp.Payload := 'Malformed Fastboot packet (< 4 bytes).';
      Log(AResp.Payload, llError);
      Exit(False);
    end;

    Text := TEncoding.ASCII.GetString(Raw);
    Prefix := Copy(Text, 1, 4);
    Body := Copy(Text, 5, MaxInt);

    if Prefix = 'INFO' then
    begin
      SetLength(AResp.InfoLines, Length(AResp.InfoLines) + 1);
      AResp.InfoLines[High(AResp.InfoLines)] := Body;
      Log('(bootloader) ' + Body, llRx);
      Continue;
    end
    else if Prefix = 'OKAY' then
    begin
      AResp.Success := True;
      AResp.Status := 'OKAY';
      AResp.Payload := Body;
      if Body <> '' then
        Log('OKAY: ' + Body, llSuccess)
      else
        Log('OKAY', llSuccess);
      Exit(True);
    end
    else if Prefix = 'DATA' then
    begin
      AResp.Success := True;
      AResp.Status := 'DATA';
      AResp.Payload := Body;
      Log('DATA ready: 0x' + Body + ' bytes', llInfo);
      Exit(True);
    end
    else if Prefix = 'FAIL' then
    begin
      AResp.Success := False;
      AResp.Status := 'FAIL';
      AResp.Payload := Body;
      Log('FAILED (' + Body + ')', llError);
      Exit(False);
    end
    else
    begin
      AResp.Success := False;
      AResp.Status := 'FAIL';
      AResp.Payload := 'Unknown response: ' + Text;
      Log(AResp.Payload, llError);
      Exit(False);
    end;
  end;
end;

function TGWTFastbootEngine.SendCommand(const ACmd: string; out AResp: TFastbootResponse): Boolean;
var
  CmdBytes: TBytes;
  Written: Cardinal;
begin
  Log('TX >> ' + ACmd, llTx);
  CmdBytes := TEncoding.ASCII.GetBytes(ACmd);
  if not FTransport.WriteRaw(CmdBytes, Written) then
  begin
    AResp.Success := False;
    AResp.Status := 'FAIL';
    AResp.Payload := 'USB Write failed.';
    Log(AResp.Payload, llError);
    Exit(False);
  end;
  Result := ReadResponseLoop(AResp);
end;

function TGWTFastbootEngine.GetVar(const AVarName: string; out AValue: string): Boolean;
var
  Resp: TFastbootResponse;
begin
  Result := SendCommand('getvar:' + AVarName, Resp);
  AValue := Resp.Payload;
end;

function TGWTFastbootEngine.OemCommand(const AOemArgs: string): Boolean;
var
  Resp: TFastbootResponse;
begin
  Result := SendCommand('oem ' + AOemArgs, Resp);
end;

function TGWTFastbootEngine.ErasePartition(const APartition: string): Boolean;
var
  Resp: TFastbootResponse;
begin
  Result := SendCommand('erase:' + APartition, Resp);
end;

function TGWTFastbootEngine.DownloadAndFlash(const APartition, AFilePath: string;
  AOnProgress: TProgressCallback): Boolean;
var
  FS: TFileStream;
  Resp: TFastbootResponse;
  TotalSize, SentBytes: Int64;
  ToRead: Integer;
  Written: Cardinal;
  Buf: TBytes;
begin
  Result := False;
  if not FileExists(AFilePath) then
  begin
    Log('Image file not found: ' + AFilePath, llError);
    Exit;
  end;

  FS := TFileStream.Create(AFilePath, fmOpenRead or fmShareDenyWrite);
  try
    TotalSize := FS.Size;
    if TotalSize <= 0 then
    begin
      Log('Image file is empty.', llError);
      Exit;
    end;

    Log(Format('Initiating download: %d bytes (0x%.8X)', [TotalSize, TotalSize]), llInfo);
    if not SendCommand(Format('download:%.8x', [TotalSize]), Resp) or (Resp.Status <> 'DATA') then
    begin
      Log('Device refused download command.', llError);
      Exit;
    end;

    SetLength(Buf, FASTBOOT_CHUNK_SIZE);
    SentBytes := 0;

    while SentBytes < TotalSize do
    begin
      ToRead := Integer(Min(Int64(FASTBOOT_CHUNK_SIZE), TotalSize - SentBytes));
      FS.ReadBuffer(Buf[0], ToRead);

      if not FTransport.WriteBuffer(@Buf[0], Cardinal(ToRead), Written) or (Written <> Cardinal(ToRead)) then
      begin
        Log(Format('Failed writing chunk at offset %d', [SentBytes]), llError);
        Exit;
      end;

      Inc(SentBytes, ToRead);
      if Assigned(AOnProgress) then
        AOnProgress(SentBytes, TotalSize);
    end;

    if not ReadResponseLoop(Resp) or not Resp.Success then
    begin
      Log('Device failed after data transfer.', llError);
      Exit;
    end;

    Log('Flashing partition ' + APartition + '...', llInfo);
    Result := SendCommand('flash:' + APartition, Resp) and Resp.Success;
  finally
    FS.Free;
  end;
end;

function TGWTFastbootEngine.Reboot(const ATarget: string): Boolean;
var
  Resp: TFastbootResponse;
  Cmd: string;
begin
  if ATarget <> '' then
    Cmd := 'reboot-' + ATarget
  else
    Cmd := 'reboot';
  Result := SendCommand(Cmd, Resp);
end;

end.
