unit GWT.WinUSB.Transport;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.RegularExpressions,
  GWT.Types, GWT.WinUSB.API;

type
  TGWTWinUsbTransport = class
  private
    FDeviceHandle: THandle;
    FWinUsbHandle: WINUSB_INTERFACE_HANDLE;
    FPipeInId: Byte;
    FPipeOutId: Byte;
    FMaxPacketSize: Word;
    FInterfaceProtocol: Byte;
    FDevicePath: string;
    function GetIsOpen: Boolean;
    procedure ConfigurePipeTimeouts(ATimeoutMs: Cardinal);
    class procedure ParseVidPid(const APath: string; out AVID, APID: Word);
    class function IsAndroidVendor(AVID: Word): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    class function CandidateGuids: TArray<TGUID>;
    class function EnumerateDevices(const AGuid: TGUID): TArray<TUsbDeviceInfo>; overload;
    class function EnumerateAllAndroidDevices: TArray<TUsbDeviceInfo>; overload;

    function Open(const ADevicePath: string; ATimeoutMs: Cardinal = 5000): Boolean;
    procedure Close;
    procedure AbortIO;

    function WriteRaw(const AData: TBytes; out ATransferred: Cardinal): Boolean;
    function WriteBuffer(ABuffer: Pointer; ALength: Cardinal; out ATransferred: Cardinal): Boolean;
    function ReadRaw(AMaxLen: Cardinal; out AData: TBytes): Boolean;

    property IsOpen: Boolean read GetIsOpen;
    property PipeInId: Byte read FPipeInId;
    property PipeOutId: Byte read FPipeOutId;
    property MaxPacketSize: Word read FMaxPacketSize;
    property InterfaceProtocol: Byte read FInterfaceProtocol;
    property DevicePath: string read FDevicePath;
  end;

implementation

constructor TGWTWinUsbTransport.Create;
begin
  inherited Create;
  FDeviceHandle := INVALID_HANDLE_VALUE;
  FWinUsbHandle := nil;
  FPipeInId := 0;
  FPipeOutId := 0;
  FMaxPacketSize := 512;
end;

destructor TGWTWinUsbTransport.Destroy;
begin
  Close;
  inherited;
end;

function TGWTWinUsbTransport.GetIsOpen: Boolean;
begin
  Result := (FDeviceHandle <> INVALID_HANDLE_VALUE) and (FWinUsbHandle <> nil);
end;

class function TGWTWinUsbTransport.IsAndroidVendor(AVID: Word): Boolean;
begin
  Result := (AVID = $2717) or // Xiaomi / Redmi / POCO
            (AVID = $18D1) or // Google / AOSP / Android
            (AVID = $22D9) or // Oppo / Realme / OnePlus
            (AVID = $2D95) or // Vivo / iQOO
            (AVID = $12D1) or // Huawei / Honor
            (AVID = $04E8) or // Samsung
            (AVID = $0E8D) or // MediaTek
            (AVID = $05C6) or // Qualcomm
            (AVID = $1782) or // Spreadtrum / Unisoc
            (AVID = $2A45) or // Meizu
            (AVID = $1BBB) or // TCL
            (AVID = $0B05) or // ASUS
            (AVID = $10A9) or // Pantech
            (AVID = $29A9) or // Smartisan
            (AVID = $19D2) or // ZTE
            (AVID = $0489);   // Foxconn
end;

class function TGWTWinUsbTransport.CandidateGuids: TArray<TGUID>;
begin
  SetLength(Result, 6);
  Result[0] := GUID_ANDROID_USB_DEVICE;
  Result[1] := GUID_FASTBOOT_DEVICE;
  Result[2] := GUID_ANDROID_USB_DEVICE_ALT;
  Result[3] := GUID_ANDROID_ADB_CERT;
  Result[4] := GUID_WINUSB_GENERIC;
  Result[5] := GUID_DEVINTERFACE_USB_DEVICE;
end;

class procedure TGWTWinUsbTransport.ParseVidPid(const APath: string; out AVID, APID: Word);
var
  M: TMatch;
begin
  AVID := 0;
  APID := 0;
  M := TRegEx.Match(APath, 'vid_([0-9a-fA-F]{4})&pid_([0-9a-fA-F]{4})', [roIgnoreCase]);
  if M.Success then
  begin
    AVID := Word(StrToIntDef('$' + M.Groups[1].Value, 0));
    APID := Word(StrToIntDef('$' + M.Groups[2].Value, 0));
  end;
end;

class function TGWTWinUsbTransport.EnumerateDevices(const AGuid: TGUID): TArray<TUsbDeviceInfo>;
var
  DevInfo: HDEVINFO;
  IfaceData: TSP_DEVICE_INTERFACE_DATA;
  DetailData: PSP_DEVICE_INTERFACE_DETAIL_DATA_W;
  ReqSize, Index: DWORD;
  List: TArray<TUsbDeviceInfo>;
  Probe: TGWTWinUsbTransport;
  Path: string;
  Item: TUsbDeviceInfo;
  IsGenericClass: Boolean;
begin
  Result := nil;
  IsGenericClass := IsEqualGUID(AGuid, GUID_DEVINTERFACE_USB_DEVICE);
  DevInfo := SetupDiGetClassDevsW(@AGuid, nil, 0, DIGCF_PRESENT or DIGCF_DEVICEINTERFACE);
  if DevInfo = Pointer(INVALID_HANDLE_VALUE) then
    Exit;

  try
    Index := 0;
    while True do
    begin
      ZeroMemory(@IfaceData, SizeOf(IfaceData));
      IfaceData.cbSize := SizeOf(IfaceData);

      if not SetupDiEnumDeviceInterfaces(DevInfo, nil, AGuid, Index, IfaceData) then
        Break;

      ReqSize := 0;
      SetupDiGetDeviceInterfaceDetailW(DevInfo, IfaceData, nil, 0, @ReqSize, nil);
      if ReqSize > 0 then
      begin
        GetMem(DetailData, ReqSize);
        try
          ZeroMemory(DetailData, ReqSize);
          {$IFDEF WIN64}
          DetailData^.cbSize := 8;
          {$ELSE}
          DetailData^.cbSize := 6;
          {$ENDIF}

          if SetupDiGetDeviceInterfaceDetailW(DevInfo, IfaceData, DetailData, ReqSize, nil, nil) then
          begin
            Path := PWideChar(@DetailData^.DevicePath[0]);
            ParseVidPid(Path, Item.VID, Item.PID);

            // If enumerating generic USB devices, ignore non-phone devices (mouse, keyboard, etc.)
            if not IsGenericClass or IsAndroidVendor(Item.VID) then
            begin
              Item.DevicePath := Path;
              Item.InterfaceType := 'USB';
              Item.IsSocketBased := False;
              Item.Serial := '';

              // Quick probe to identify ADB ($01) vs Fastboot ($03)
              Probe := TGWTWinUsbTransport.Create;
              try
                if Probe.Open(Path, 600) then
                begin
                  if Probe.InterfaceProtocol = USB_PROTOCOL_FASTBOOT then
                    Item.InterfaceType := 'FASTBOOT'
                  else if Probe.InterfaceProtocol = USB_PROTOCOL_ADB then
                    Item.InterfaceType := 'ADB';
                  Probe.Close;
                end;
              finally
                Probe.Free;
              end;

              Item.FriendlyName := Format('[%s] VID_%.4X PID_%.4X (WinUSB)',
                [Item.InterfaceType, Item.VID, Item.PID]);

              SetLength(List, Length(List) + 1);
              List[High(List)] := Item;
            end;
          end;
        finally
          FreeMem(DetailData);
        end;
      end;
      Inc(Index);
    end;
    Result := List;
  finally
    SetupDiDestroyDeviceInfoList(DevInfo);
  end;
end;

class function TGWTWinUsbTransport.EnumerateAllAndroidDevices: TArray<TUsbDeviceInfo>;
var
  Guids: TArray<TGUID>;
  G: TGUID;
  Devs: TArray<TUsbDeviceInfo>;
  Item: TUsbDeviceInfo;
  Found: Boolean;
  I: NativeInt;
begin
  SetLength(Result, 0);
  Guids := CandidateGuids;

  for G in Guids do
  begin
    Devs := EnumerateDevices(G);
    for Item in Devs do
    begin
      Found := False;
      for I := 0 to High(Result) do
      begin
        if SameText(Result[I].DevicePath, Item.DevicePath) then
        begin
          Found := True;
          Break;
        end;
      end;
      if not Found then
      begin
        SetLength(Result, Length(Result) + 1);
        Result[High(Result)] := Item;
      end;
    end;
  end;
end;

procedure TGWTWinUsbTransport.ConfigurePipeTimeouts(ATimeoutMs: Cardinal);
var
  TimeoutVal: ULONG;
  AutoClear: Byte;
begin
  TimeoutVal := ATimeoutMs;
  AutoClear := 1;
  if FPipeInId <> 0 then
  begin
    WinUsb_SetPipePolicy(FWinUsbHandle, FPipeInId, PIPE_TRANSFER_TIMEOUT, SizeOf(TimeoutVal), @TimeoutVal);
    WinUsb_SetPipePolicy(FWinUsbHandle, FPipeInId, AUTO_CLEAR_STALL, SizeOf(AutoClear), @AutoClear);
  end;
  if FPipeOutId <> 0 then
  begin
    WinUsb_SetPipePolicy(FWinUsbHandle, FPipeOutId, PIPE_TRANSFER_TIMEOUT, SizeOf(TimeoutVal), @TimeoutVal);
    WinUsb_SetPipePolicy(FWinUsbHandle, FPipeOutId, AUTO_CLEAR_STALL, SizeOf(AutoClear), @AutoClear);
  end;
end;

function TGWTWinUsbTransport.Open(const ADevicePath: string; ATimeoutMs: Cardinal): Boolean;
var
  IfaceDesc: USB_INTERFACE_DESCRIPTOR;
  PipeInfo: WINUSB_PIPE_INFORMATION;
  I: Integer;
begin
  Close;
  Result := False;

  FDeviceHandle := CreateFileW(PWideChar(ADevicePath),
    GENERIC_READ or GENERIC_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE,
    nil, OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL or FILE_FLAG_OVERLAPPED, 0);

  if FDeviceHandle = INVALID_HANDLE_VALUE then
    Exit;

  if not WinUsb_Initialize(FDeviceHandle, FWinUsbHandle) then
  begin
    Close;
    Exit;
  end;

  if not WinUsb_QueryInterfaceSettings(FWinUsbHandle, 0, IfaceDesc) then
  begin
    Close;
    Exit;
  end;

  // Validate Android Vendor-Specific ADB/Fastboot Interface
  // Note: Some bootloaders report Class $FF with SubClass 0 or $42 and Protocol $03
  if (IfaceDesc.bInterfaceClass <> USB_CLASS_VENDOR_SPEC) and
     (IfaceDesc.bInterfaceClass <> 0) then
  begin
    Close;
    Exit;
  end;

  FInterfaceProtocol := IfaceDesc.bInterfaceProtocol;

  for I := 0 to IfaceDesc.bNumEndpoints - 1 do
  begin
    if WinUsb_QueryPipe(FWinUsbHandle, 0, Byte(I), PipeInfo) then
    begin
      if PipeInfo.PipeType = UsbdPipeTypeBulk then
      begin
        if (PipeInfo.PipeId and $80) <> 0 then
          FPipeInId := Byte(PipeInfo.PipeId)
        else
        begin
          FPipeOutId := Byte(PipeInfo.PipeId);
          if PipeInfo.MaximumPacketSize > 0 then
            FMaxPacketSize := PipeInfo.MaximumPacketSize;
        end;
      end;
    end;
  end;

  if (FPipeInId = 0) or (FPipeOutId = 0) then
  begin
    Close;
    Exit;
  end;

  FDevicePath := ADevicePath;
  ConfigurePipeTimeouts(ATimeoutMs);
  Result := True;
end;

procedure TGWTWinUsbTransport.Close;
begin
  if FWinUsbHandle <> nil then
  begin
    WinUsb_Free(FWinUsbHandle);
    FWinUsbHandle := nil;
  end;
  if FDeviceHandle <> INVALID_HANDLE_VALUE then
  begin
    CloseHandle(FDeviceHandle);
    FDeviceHandle := INVALID_HANDLE_VALUE;
  end;
  FPipeInId := 0;
  FPipeOutId := 0;
  FInterfaceProtocol := 0;
  FDevicePath := '';
end;

procedure TGWTWinUsbTransport.AbortIO;
begin
  if FWinUsbHandle <> nil then
  begin
    if FPipeInId <> 0 then WinUsb_AbortPipe(FWinUsbHandle, FPipeInId);
    if FPipeOutId <> 0 then WinUsb_AbortPipe(FWinUsbHandle, FPipeOutId);
  end;
end;

function TGWTWinUsbTransport.WriteRaw(const AData: TBytes; out ATransferred: Cardinal): Boolean;
begin
  if Length(AData) = 0 then
  begin
    ATransferred := 0;
    Exit(True);
  end;
  Result := WriteBuffer(@AData[0], Cardinal(Length(AData)), ATransferred);
end;

function TGWTWinUsbTransport.WriteBuffer(ABuffer: Pointer; ALength: Cardinal;
  out ATransferred: Cardinal): Boolean;
begin
  ATransferred := 0;
  if not IsOpen then Exit(False);
  Result := WinUsb_WritePipe(FWinUsbHandle, FPipeOutId, ABuffer, ALength, ATransferred, nil);
end;

function TGWTWinUsbTransport.ReadRaw(AMaxLen: Cardinal; out AData: TBytes): Boolean;
var
  Transferred: ULONG;
begin
  SetLength(AData, AMaxLen);
  if not IsOpen then
  begin
    SetLength(AData, 0);
    Exit(False);
  end;

  Result := WinUsb_ReadPipe(FWinUsbHandle, FPipeInId, @AData[0], AMaxLen, Transferred, nil);
  if Result then
    SetLength(AData, Transferred)
  else
    SetLength(AData, 0);
end;

end.
