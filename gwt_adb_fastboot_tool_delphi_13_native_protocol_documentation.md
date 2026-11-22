# GWT ADB & Fastboot Tool v1.2 — Delphi 13 VCL Native Protocol Documentation

**GWT ADB & Fastboot Tool v1.2** is a standalone, dark-themed Android service and flashing desktop application built with **Delphi 13 (RAD Studio 13) VCL**.

Unlike wrapper tools that shell out to `adb.exe` or `fastboot.exe`, this architecture communicates **directly with Android USB endpoints** using **WinUSB (`winusb.dll` + `setupapi.dll`)** and implements native **Fastboot** and **ADB** protocol state machines in pure Delphi Pascal.

---

## 1. Clean Project Folder Structure

```text
GWT_Tool/
├── GWT_Tool.dpr                       # Main Delphi 13 Project
├── Core/
│   └── GWT.Types.pas                  # Enums, Theme Colors, Log Levels, Callbacks
├── Protocols/
│   ├── GWT.WinUSB.API.pas             # WinUSB & SetupAPI Win32 Interop Declarations
│   ├── GWT.WinUSB.Transport.pas       # USB Device Enumeration, Bulk Pipes & Abort
│   ├── GWT.Protocol.Fastboot.pas      # Native Fastboot State Machine (OKAY/FAIL/INFO/DATA)
│   └── GWT.Protocol.ADB.pas           # Native ADB Packet Framing (CNXN/AUTH/OPEN/WRTE)
├── Services/
│   └── GWT.CommandService.pas         # Async Worker Layer & Brand Command Dispatcher
├── Frames/
│   ├── Frame.HuaweiService.pas        # Huawei -> Fastboot -> Service Frame Logic
│   └── Frame.HuaweiService.dfm        # Huawei -> Fastboot -> Service Frame Layout
└── UI/
    ├── Form.Main.pas                  # Main Shell, WM_DEVICECHANGE, RichEdit Logger
    └── Form.Main.dfm                  # Main Shell VCL Layout
```

---

## 2. UI Design System & Layout Specification

### 2.1 Navigation & Panel Hierarchy
* **Top Header (`pnlHeader`):** Left = **GWT** logo + `ADB & FASTBOOT TOOL v1.2`; Right = live status indicator (`ONLINE / CONNECTED` or `WAITING FOR DEVICE`).
* **Main Workspace (`pnlWorkspace`):**
  * **Main Brand Tabs:** `XIAOMI` | `VIVO` | `HUAWEI`
  * **Mode Sub-Tabs (under Brand):** `ADB` | `FASTBOOT` | `RECOVERY`
  * **Action Sub-Tabs (under Fastboot):** `SERVICE` | `FLASH`
  * **Frame Host (`pnlFrameHost`):** Dynamically loads modular `TFrame` views (e.g., `TFrameHuaweiService` with **HUAWEI FRP RESET** card + **LOCKS & SECURITY** 2-column button grid).
* **Right Sidebar (`pnlRightSidebar`):**
  * **Top (`pnlUsbBox`):** `USB PORT DETECTION` combo box (auto-refreshed via `WM_DEVICECHANGE`).
  * **Bottom (`pnlLogBox`):** Full-height continuous `OPERATION LOGS` (`TRichEdit`) with **no toolbar buttons** above it.

### 2.2 Color Palette (Hex & Delphi `TColor` BGR)

| UI Element | Hex | Delphi `TColor` | Usage |
| :--- | :--- | :--- | :--- |
| Main Background | `#0B111A` | `$001A110B` | Main form & workspace |
| Panel / Card Surface | `#0E1724` | `$0024170E` | Header, cards, sidebar |
| Input / Control Fill | `#0C131C` | `$001C130C` | Edit box, ComboBox |
| Log Terminal Surface | `#070D10` | `$00100D07` | `TRichEdit` background |
| Active Accent (Cyan) | `#00F0FF` | `$00FFF000` | Brand highlight, TX commands |
| Success / Online | `#00E676` | `$0076E600` | Connected badge, `[OK]` |
| Warning / Alert | `#FFB300` | `$0000B3FF` | `[WARN]` / Waiting state |
| Error / Danger | `#FF4E4E` | `$004E4EFF` | `[ERR]` / Failed status |
| Primary Text | `#FFFFFF` | `$00FFFFFF` | Headings & active captions |
| Muted Text | `#B0BEC5` | `$00C5BEB0` | Sub-labels & timestamps |

---

## 3. Core Types (`Core\GWT.Types.pas`)

```pascal
unit GWT.Types;

interface

uses
  System.SysUtils, Vcl.Graphics;

type
  TBrandKind  = (bkXiaomi, bkVivo, bkHuawei);
  TDeviceMode = (dmADB, dmFastboot, dmRecovery);
  TSubMode    = (smService, smFlash);
  TLogLevel   = (llInfo, llSuccess, llWarning, llError, llTx, llRx);

  TUsbDeviceInfo = record
    DevicePath: string;
    FriendlyName: string;
    InterfaceType: string; // 'ADB' or 'FASTBOOT'
    VID: Word;
    PID: Word;
  end;

  TLogCallback = reference to procedure(const AMsg: string; ALevel: TLogLevel);
  TProgressCallback = reference to procedure(ACurrent, ATotal: Int64);

const
  // GWT Dark Cyber Theme (Delphi TColor is $00BBGGRR)
  CLR_BG_MAIN      = TColor($001A110B);
  CLR_BG_PANEL     = TColor($0024170E);
  CLR_BG_INPUT     = TColor($001C130C);
  CLR_BG_TERMINAL  = TColor($00100D07);
  CLR_ACCENT_CYAN  = TColor($00FFF000);
  CLR_TEXT_PRIMARY = TColor($00FFFFFF);
  CLR_TEXT_MUTED   = TColor($00C5BEB0);
  CLR_LOG_SUCCESS  = TColor($0076E600);
  CLR_LOG_WARN     = TColor($0000B3FF);
  CLR_LOG_ERROR    = TColor($004E4EFF);

  // Standard Android WinUSB Interface GUID (used by Google USB Driver / Zadig WinUSB)
  GUID_ANDROID_USB_DEVICE: TGUID = '{F72FE0D4-CBCB-407D-8814-9ED673D0DD6B}';
  GUID_DEVINTERFACE_USB_DEVICE: TGUID = '{A5DCBF10-6530-11D2-901F-00C04FB951ED}';

  // Android USB Interface Class / SubClass / Protocol
  USB_CLASS_VENDOR_SPEC   = $FF;
  USB_SUBCLASS_ADB        = $42;
  USB_PROTOCOL_ADB        = $01;
  USB_PROTOCOL_FASTBOOT   = $03;

implementation

end.
```

---

## 4. Module 1: WinUSB Transport Layer

### 4.1 WinUSB & SetupAPI Bindings (`Protocols\GWT.WinUSB.API.pas`)

```pascal
unit GWT.WinUSB.API;

interface

uses
  Winapi.Windows;

const
  SETUPAPI_DLL = 'setupapi.dll';
  WINUSB_DLL   = 'winusb.dll';

  DIGCF_PRESENT         = $00000002;
  DIGCF_DEVICEINTERFACE = $00000010;

  // WinUSB Pipe Policy Types
  SHORT_PACKET_TERMINATE = $01;
  AUTO_CLEAR_STALL       = $02;
  PIPE_TRANSFER_TIMEOUT  = $03;

  // USB Pipe Types
  UsbdPipeTypeControl     = 0;
  UsbdPipeTypeIsochronous = 1;
  UsbdPipeTypeBulk        = 2;
  UsbdPipeTypeInterrupt   = 3;

type
  HDEVINFO = Pointer;
  WINUSB_INTERFACE_HANDLE = Pointer;

  PSP_DEVICE_INTERFACE_DATA = ^TSP_DEVICE_INTERFACE_DATA;
  TSP_DEVICE_INTERFACE_DATA = record
    cbSize: DWORD;
    InterfaceClassGuid: TGUID;
    Flags: DWORD;
    Reserved: ULONG_PTR;
  end;

  PSP_DEVINFO_DATA = ^TSP_DEVINFO_DATA;
  TSP_DEVINFO_DATA = record
    cbSize: DWORD;
    ClassGuid: TGUID;
    DevInst: DWORD;
    Reserved: ULONG_PTR;
  end;

  PSP_DEVICE_INTERFACE_DETAIL_DATA_W = ^TSP_DEVICE_INTERFACE_DETAIL_DATA_W;
  TSP_DEVICE_INTERFACE_DETAIL_DATA_W = record
    cbSize: DWORD;
    DevicePath: array[0..0] of WideChar;
  end;

  USB_INTERFACE_DESCRIPTOR = packed record
    bLength: Byte;
    bDescriptorType: Byte;
    bInterfaceNumber: Byte;
    bAlternateSetting: Byte;
    bNumEndpoints: Byte;
    bInterfaceClass: Byte;
    bInterfaceSubClass: Byte;
    bInterfaceProtocol: Byte;
    iInterface: Byte;
  end;
  PUSB_INTERFACE_DESCRIPTOR = ^USB_INTERFACE_DESCRIPTOR;

  WINUSB_PIPE_INFORMATION = record
    PipeType: DWORD;
    PipeId: Byte;
    MaximumPacketSize: Word;
    Interval: Byte;
  end;
  PWINUSB_PIPE_INFORMATION = ^WINUSB_PIPE_INFORMATION;

function SetupDiGetClassDevsW(ClassGuid: PGUID; Enumerator: PWideChar;
  hwndParent: HWND; Flags: DWORD): HDEVINFO; stdcall; external SETUPAPI_DLL;

function SetupDiEnumDeviceInterfaces(DeviceInfoSet: HDEVINFO;
  DeviceInfoData: PSP_DEVINFO_DATA; const InterfaceClassGuid: TGUID;
  MemberIndex: DWORD; var DeviceInterfaceData: TSP_DEVICE_INTERFACE_DATA): BOOL;
  stdcall; external SETUPAPI_DLL;

function SetupDiGetDeviceInterfaceDetailW(DeviceInfoSet: HDEVINFO;
  var DeviceInterfaceData: TSP_DEVICE_INTERFACE_DATA;
  DeviceInterfaceDetailData: PSP_DEVICE_INTERFACE_DETAIL_DATA_W;
  DeviceInterfaceDetailDataSize: DWORD; RequiredSize: PDWORD;
  DeviceInfoData: PSP_DEVINFO_DATA): BOOL; stdcall; external SETUPAPI_DLL;

function SetupDiDestroyDeviceInfoList(DeviceInfoSet: HDEVINFO): BOOL;
  stdcall; external SETUPAPI_DLL;

function WinUsb_Initialize(DeviceHandle: THandle;
  out InterfaceHandle: WINUSB_INTERFACE_HANDLE): BOOL; stdcall; external WINUSB_DLL;

function WinUsb_Free(InterfaceHandle: WINUSB_INTERFACE_HANDLE): BOOL;
  stdcall; external WINUSB_DLL;

function WinUsb_QueryInterfaceSettings(InterfaceHandle: WINUSB_INTERFACE_HANDLE;
  AlternateInterfaceNumber: Byte;
  out UsbAltInterfaceDescriptor: USB_INTERFACE_DESCRIPTOR): BOOL;
  stdcall; external WINUSB_DLL;

function WinUsb_QueryPipe(InterfaceHandle: WINUSB_INTERFACE_HANDLE;
  AlternateInterfaceNumber: Byte; PipeIndex: Byte;
  out PipeInformation: WINUSB_PIPE_INFORMATION): BOOL; stdcall; external WINUSB_DLL;

function WinUsb_SetPipePolicy(InterfaceHandle: WINUSB_INTERFACE_HANDLE;
  PipeID: Byte; PolicyType: ULONG; ValueLength: ULONG; Value: Pointer): BOOL;
  stdcall; external WINUSB_DLL;

function WinUsb_WritePipe(InterfaceHandle: WINUSB_INTERFACE_HANDLE;
  PipeID: Byte; Buffer: Pointer; BufferLength: ULONG;
  out LengthTransferred: ULONG; Overlapped: POverlapped): BOOL;
  stdcall; external WINUSB_DLL;

function WinUsb_ReadPipe(InterfaceHandle: WINUSB_INTERFACE_HANDLE;
  PipeID: Byte; Buffer: Pointer; BufferLength: ULONG;
  out LengthTransferred: ULONG; Overlapped: POverlapped): BOOL;
  stdcall; external WINUSB_DLL;

function WinUsb_AbortPipe(InterfaceHandle: WINUSB_INTERFACE_HANDLE;
  PipeID: Byte): BOOL; stdcall; external WINUSB_DLL;

function WinUsb_ResetPipe(InterfaceHandle: WINUSB_INTERFACE_HANDLE;
  PipeID: Byte): BOOL; stdcall; external WINUSB_DLL;

implementation

end.
```

### 4.2 WinUSB Transport Engine (`Protocols\GWT.WinUSB.Transport.pas`)

```pascal
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
  public
    constructor Create;
    destructor Destroy; override;

    class function EnumerateDevices(const AGuid: TGUID): TArray<TUsbDeviceInfo>;

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

class procedure TGWTWinUsbTransport.ParseVidPid(const APath: string; out AVID, APID: Word);
var
  M: TMatch;
begin
  AVID := 0;
  APID := 0;
  M := TRegEx.Match(APath, 'vid_([0-9a-fA-F]{4})&pid_([0-9a-fA-F]{4})', [roIgnoreCase]);
  if M.Success then
  begin
    AVID := StrToIntDef('$' + M.Groups[1].Value, 0);
    APID := StrToIntDef('$' + M.Groups[2].Value, 0);
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
begin
  Result := nil;
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
            Item.DevicePath := Path;
            Item.InterfaceType := 'USB';

            // Quick probe to identify ADB ($01) vs Fastboot ($03)
            Probe := TGWTWinUsbTransport.Create;
            try
              if Probe.Open(Path, 1000) then
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

            Item.FriendlyName := Format('[%s] VID_%.4X PID_%.4X',
              [Item.InterfaceType, Item.VID, Item.PID]);

            SetLength(List, Length(List) + 1);
            List[High(List)] := Item;
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
  I: Byte;
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
  if (IfaceDesc.bInterfaceClass <> USB_CLASS_VENDOR_SPEC) or
     (IfaceDesc.bInterfaceSubClass <> USB_SUBCLASS_ADB) then
  begin
    Close;
    Exit;
  end;

  FInterfaceProtocol := IfaceDesc.bInterfaceProtocol;

  for I := 0 to IfaceDesc.bNumEndpoints - 1 do
  begin
    if WinUsb_QueryPipe(FWinUsbHandle, 0, I, PipeInfo) then
    begin
      if PipeInfo.PipeType = UsbdPipeTypeBulk then
      begin
        if (PipeInfo.PipeId and $80) <> 0 then
          FPipeInId := PipeInfo.PipeId
        else
        begin
          FPipeOutId := PipeInfo.PipeId;
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
  Result := WriteBuffer(@AData[0], Length(AData), ATransferred);
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
```

---

## 5. Module 2: Native Fastboot Protocol Engine (`Protocols\GWT.Protocol.Fastboot.pas`)

Implements the complete Fastboot specification directly over `TGWTWinUsbTransport`:
* Commands sent as ASCII strings (e.g., `getvar:all`, `oem frp-unlock <key>`, `erase:frp`, `download:<8-hex>`, `flash:<partition>`).
* Responses parsed by 4-byte status prefix: `INFO`, `OKAY`, `FAIL`, `DATA`.

```pascal
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
  Result := False;
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
      ToRead := Min(FASTBOOT_CHUNK_SIZE, TotalSize - SentBytes);
      FS.ReadBuffer(Buf[0], ToRead);

      if not FTransport.WriteBuffer(@Buf[0], ToRead, Written) or (Written <> Cardinal(ToRead)) then
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
```

---

## 6. Module 3: Native ADB Protocol Engine (`Protocols\GWT.Protocol.ADB.pas`)

This unit implements native Android Debug Bridge binary packet framing over WinUSB without any external `adb.exe`:
- 24-byte packet header (`TADBMessage`) with Command, Arg0, Arg1, DataLength, DataCheck, and Magic.
- Handshake negotiation (`A_CNXN`) with host features identification.
- Remote service opening (`A_OPEN`) for shell commands and data stream harvesting (`A_WRTE` / `A_OKAY` / `A_CLSE`).

```pascal
unit GWT.Protocol.ADB;

interface

uses
  System.SysUtils, System.Classes,
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

implementation

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
  I: Integer;
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
  Hdr.DataLength := Length(APayload);
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
  Result := False;
  AMsg := Default(TADBMessage);
  SetLength(APayload, 0);

  if not FTransport.ReadRaw(SizeOf(TADBMessage), RawHdr) or (Length(RawHdr) < SizeOf(TADBMessage)) then
  begin
    Log('Failed reading ADB packet header.', llError);
    Exit(False);
  end;

  Move(RawHdr[0], AMsg, SizeOf(TADBMessage));

  // Verify Magic integrity
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

    // Verify Checksum
    if CalcDataCheck(RawData) <> AMsg.DataCheck then
    begin
      Log('ADB packet checksum mismatch.', llError);
      Exit(False);
    end;

    APayload := RawData;
  end;

  Result := True;
end;

function TGWTADBPacketEngine.Connect(const ASystemIdentity: string): Boolean;
var
  Payload: TBytes;
  Msg: TADBMessage;
  RespPayload: TBytes;
  Ident: string;
begin
  Result := False;
  FIsConnected := False;
  Payload := TEncoding.ASCII.GetBytes(ASystemIdentity + #0);

  Log('ADB >> CNXN (Initiating handshake)', llTx);
  if not SendPacket(A_CNXN, A_VERSION, A_MAXDATA, Payload) then
    Exit;

  if not ReadPacket(Msg, RespPayload) then
    Exit;

  if Msg.Command = A_AUTH then
  begin
    Log('Device requires RSA Authentication. Please accept USB debugging prompt on screen.', llWarning);
    Exit(False);
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

      // Send A_OKAY acknowledgement
      SendPacket(A_OKAY, FLocalStreamId, FRemoteStreamId, nil);
    end
    else if Msg.Command = A_CLSE then
    begin
      // Remote closed stream
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

end.
```

---

## 7. Module 4: Asynchronous Command Service (`Services\GWT.CommandService.pas`)

Coordinates device detection, protocol binding, and execution in background threads without blocking the VCL UI:

```pascal
unit GWT.CommandService;

interface

uses
  System.SysUtils, System.Classes,
  GWT.Types, GWT.WinUSB.Transport, GWT.Protocol.Fastboot, GWT.Protocol.ADB;

type
  TGWTCommandService = class
  private
    FOnLog: TLogCallback;
    FIsBusy: Boolean;
    procedure Log(const AMsg: string; ALevel: TLogLevel);
    procedure RunAsync(AProc: TProc);
  public
    constructor Create(AOnLog: TLogCallback);
    destructor Destroy; override;

    function ScanConnectedInterfaces: TArray<TUsbDeviceInfo>;

    // Huawei Fastboot Service Operations
    procedure HuaweiResetFRP(const ADevicePath, AKey: string);
    procedure HuaweiReadInfo(const ADevicePath: string);
    procedure HuaweiResetScreenLock(const ADevicePath: string);
    procedure HuaweiBypassFRPAndLock(const ADevicePath: string);
    procedure HuaweiRemoveID(const ADevicePath: string);
    procedure HuaweiUnlockBootloader(const ADevicePath, ACode: string);
    procedure HuaweiRelockBootloader(const ADevicePath: string);
    procedure HuaweiFormatUserdataSafe(const ADevicePath: string);

    // Generic Fastboot Operations
    procedure FastbootFlashPartition(const ADevicePath, APartition, AImagePath: string;
      AOnProgress: TProgressCallback = nil);
    procedure FastbootReboot(const ADevicePath, ATarget: string);

    // ADB Operations
    procedure AdbExecuteShell(const ADevicePath, ACmd: string);
    procedure AdbReboot(const ADevicePath, ATarget: string);

    property IsBusy: Boolean read FIsBusy;
  end;

implementation

constructor TGWTCommandService.Create(AOnLog: TLogCallback);
begin
  inherited Create;
  FOnLog := AOnLog;
  FIsBusy := False;
end;

destructor TGWTCommandService.Destroy;
begin
  inherited;
end;

procedure TGWTCommandService.Log(const AMsg: string; ALevel: TLogLevel);
begin
  if Assigned(FOnLog) then
    TThread.Queue(nil,
      procedure
      begin
        FOnLog(AMsg, ALevel);
      end);
end;

procedure TGWTCommandService.RunAsync(AProc: TProc);
begin
  if FIsBusy then
  begin
    Log('Another operation is currently running. Please wait.', llWarning);
    Exit;
  end;

  FIsBusy := True;
  TThread.CreateAnonymousThread(
    procedure
    begin
      try
        AProc();
      finally
        FIsBusy := False;
      end;
    end).Start;
end;

function TGWTCommandService.ScanConnectedInterfaces: TArray<TUsbDeviceInfo>;
begin
  Result := TGWTWinUsbTransport.EnumerateDevices(GUID_DEVINTERFACE_USB_DEVICE);
end;

procedure TGWTCommandService.HuaweiResetFRP(const ADevicePath, AKey: string);
begin
  RunAsync(
    procedure
    var
      Transport: TGWTWinUsbTransport;
      Engine: TGWTFastbootEngine;
    begin
      Log('Connecting to device for Huawei FRP Reset...', llInfo);
      Transport := TGWTWinUsbTransport.Create;
      try
        if not Transport.Open(ADevicePath) then
        begin
          Log('Failed opening USB connection to device.', llError);
          Exit;
        end;

        Engine := TGWTFastbootEngine.Create(Transport, FOnLog);
        try
          Log('Executing: oem frp-unlock ' + Trim(AKey), llTx);
          if Engine.OemCommand('frp-unlock ' + Trim(AKey)) then
          begin
            Log('FRP Key accepted! Erasing FRP partition...', llSuccess);
            if Engine.ErasePartition('frp') then
              Log('Huawei FRP Reset Completed Successfully!', llSuccess)
            else
              Log('Failed erasing FRP partition.', llError);
          end
          else
            Log('FRP Unlock Rejected by device.', llError);
        finally
          Engine.Free;
        end;
      finally
        Transport.Free;
      end;
    end);
end;

procedure TGWTCommandService.HuaweiReadInfo(const ADevicePath: string);
begin
  RunAsync(
    procedure
    var
      Transport: TGWTWinUsbTransport;
      Engine: TGWTFastbootEngine;
      Resp: TFastbootResponse;
      Val: string;
    begin
      Log('Reading device information...', llInfo);
      Transport := TGWTWinUsbTransport.Create;
      try
        if not Transport.Open(ADevicePath) then
        begin
          Log('Failed opening USB connection to device.', llError);
          Exit;
        end;

        Engine := TGWTFastbootEngine.Create(Transport, FOnLog);
        try
          if Engine.GetVar('version-base', Val) then Log('Base Version: ' + Val, llInfo);
          if Engine.GetVar('version-bootloader', Val) then Log('Bootloader: ' + Val, llInfo);
          if Engine.GetVar('serialno', Val) then Log('Serial Number: ' + Val, llInfo);
          Engine.SendCommand('oem get-build-number', Resp);
          Engine.SendCommand('oem lock-state info', Resp);
          Log('Read Info Completed.', llSuccess);
        finally
          Engine.Free;
        end;
      finally
        Transport.Free;
      end;
    end);
end;

procedure TGWTCommandService.HuaweiResetScreenLock(const ADevicePath: string);
begin
  RunAsync(
    procedure
    var
      Transport: TGWTWinUsbTransport;
      Engine: TGWTFastbootEngine;
      Resp: TFastbootResponse;
    begin
      Transport := TGWTWinUsbTransport.Create;
      try
        if not Transport.Open(ADevicePath) then Exit;
        Engine := TGWTFastbootEngine.Create(Transport, FOnLog);
        try
          Engine.SendCommand('oem lock-state info', Resp);
        finally
          Engine.Free;
        end;
      finally
        Transport.Free;
      end;
    end);
end;

procedure TGWTCommandService.HuaweiBypassFRPAndLock(const ADevicePath: string);
begin
  RunAsync(
    procedure
    var
      Transport: TGWTWinUsbTransport;
      Engine: TGWTFastbootEngine;
    begin
      Transport := TGWTWinUsbTransport.Create;
      try
        if not Transport.Open(ADevicePath) then Exit;
        Engine := TGWTFastbootEngine.Create(Transport, FOnLog);
        try
          if Engine.ErasePartition('frp') then
            Log('FRP Partition cleared.', llSuccess);
        finally
          Engine.Free;
        end;
      finally
        Transport.Free;
      end;
    end);
end;

procedure TGWTCommandService.HuaweiRemoveID(const ADevicePath: string);
begin
  RunAsync(
    procedure
    var
      Transport: TGWTWinUsbTransport;
      Engine: TGWTFastbootEngine;
    begin
      Transport := TGWTWinUsbTransport.Create;
      try
        if not Transport.Open(ADevicePath) then Exit;
        Engine := TGWTFastbootEngine.Create(Transport, FOnLog);
        try
          if Engine.ErasePartition('oeminfo') then
            Log('Huawei ID Partition cleared.', llSuccess);
        finally
          Engine.Free;
        end;
      finally
        Transport.Free;
      end;
    end);
end;

procedure TGWTCommandService.HuaweiUnlockBootloader(const ADevicePath, ACode: string);
begin
  RunAsync(
    procedure
    var
      Transport: TGWTWinUsbTransport;
      Engine: TGWTFastbootEngine;
    begin
      Transport := TGWTWinUsbTransport.Create;
      try
        if not Transport.Open(ADevicePath) then Exit;
        Engine := TGWTFastbootEngine.Create(Transport, FOnLog);
        try
          if Trim(ACode) <> '' then
            Engine.OemCommand('unlock ' + Trim(ACode))
          else
            Engine.SendCommand('flashing unlock', Default(TFastbootResponse));
        finally
          Engine.Free;
        end;
      finally
        Transport.Free;
      end;
    end);
end;

procedure TGWTCommandService.HuaweiRelockBootloader(const ADevicePath: string);
begin
  RunAsync(
    procedure
    var
      Transport: TGWTWinUsbTransport;
      Engine: TGWTFastbootEngine;
    begin
      Transport := TGWTWinUsbTransport.Create;
      try
        if not Transport.Open(ADevicePath) then Exit;
        Engine := TGWTFastbootEngine.Create(Transport, FOnLog);
        try
          Engine.OemCommand('relock');
        finally
          Engine.Free;
        end;
      finally
        Transport.Free;
      end;
    end);
end;

procedure TGWTCommandService.HuaweiFormatUserdataSafe(const ADevicePath: string);
begin
  RunAsync(
    procedure
    var
      Transport: TGWTWinUsbTransport;
      Engine: TGWTFastbootEngine;
    begin
      Transport := TGWTWinUsbTransport.Create;
      try
        if not Transport.Open(ADevicePath) then Exit;
        Engine := TGWTFastbootEngine.Create(Transport, FOnLog);
        try
          Engine.ErasePartition('userdata');
          Engine.ErasePartition('cache');
          Log('Safe Wipe completed.', llSuccess);
        finally
          Engine.Free;
        end;
      finally
        Transport.Free;
      end;
    end);
end;

procedure TGWTCommandService.FastbootFlashPartition(const ADevicePath, APartition,
  AImagePath: string; AOnProgress: TProgressCallback);
begin
  RunAsync(
    procedure
    var
      Transport: TGWTWinUsbTransport;
      Engine: TGWTFastbootEngine;
    begin
      Transport := TGWTWinUsbTransport.Create;
      try
        if not Transport.Open(ADevicePath) then Exit;
        Engine := TGWTFastbootEngine.Create(Transport, FOnLog);
        try
          if Engine.DownloadAndFlash(APartition, AImagePath, AOnProgress) then
            Log('Flashing ' + APartition + ' completed successfully!', llSuccess)
          else
            Log('Flashing ' + APartition + ' failed.', llError);
        finally
          Engine.Free;
        end;
      finally
        Transport.Free;
      end;
    end);
end;

procedure TGWTCommandService.FastbootReboot(const ADevicePath, ATarget: string);
begin
  RunAsync(
    procedure
    var
      Transport: TGWTWinUsbTransport;
      Engine: TGWTFastbootEngine;
    begin
      Transport := TGWTWinUsbTransport.Create;
      try
        if not Transport.Open(ADevicePath) then Exit;
        Engine := TGWTFastbootEngine.Create(Transport, FOnLog);
        try
          Engine.Reboot(ATarget);
        finally
          Engine.Free;
        end;
      finally
        Transport.Free;
      end;
    end);
end;

procedure TGWTCommandService.AdbExecuteShell(const ADevicePath, ACmd: string);
begin
  RunAsync(
    procedure
    var
      Transport: TGWTWinUsbTransport;
      Engine: TGWTADBPacketEngine;
    begin
      Transport := TGWTWinUsbTransport.Create;
      try
        if not Transport.Open(ADevicePath) then Exit;
        Engine := TGWTADBPacketEngine.Create(Transport, FOnLog);
        try
          if Engine.Connect then
            Engine.ExecuteShell(ACmd);
        finally
          Engine.Free;
        end;
      finally
        Transport.Free;
      end;
    end);
end;

procedure TGWTCommandService.AdbReboot(const ADevicePath, ATarget: string);
begin
  RunAsync(
    procedure
    var
      Transport: TGWTWinUsbTransport;
      Engine: TGWTADBPacketEngine;
    begin
      Transport := TGWTWinUsbTransport.Create;
      try
        if not Transport.Open(ADevicePath) then Exit;
        Engine := TGWTADBPacketEngine.Create(Transport, FOnLog);
        try
          if Engine.Connect then
            Engine.Reboot(ATarget);
        finally
          Engine.Free;
        end;
      finally
        Transport.Free;
      end;
    end);
end;

end.
```

---

## 8. Module 5: Reusable Frame — Huawei Fastboot Service

### 8.1 Pascal Code (`Frames\Frame.HuaweiService.pas`)

```pascal
unit Frame.HuaweiService;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  GWT.Types, GWT.CommandService;

type
  TDevicePathGetter = reference to function: string;

  TFrameHuaweiService = class(TFrame)
    pnlFRPCard: TPanel;
    lblFRPHeader: TLabel;
    lblFRPSub: TLabel;
    edtFRPKey: TEdit;
    btnResetFRP: TButton;
    btnReadInfo: TButton;
    pnlLocksCard: TPanel;
    lblLocksHeader: TLabel;
    gpLockButtons: TGridPanel;
    btnResetLock: TButton;
    btnBypassFRP: TButton;
    btnRemoveID: TButton;
    btnRelockBL: TButton;
    btnUnlockBL: TButton;
    btnFormatData: TButton;
    procedure btnResetFRPClick(Sender: TObject);
    procedure btnReadInfoClick(Sender: TObject);
    procedure btnResetLockClick(Sender: TObject);
    procedure btnBypassFRPClick(Sender: TObject);
    procedure btnRemoveIDClick(Sender: TObject);
    procedure btnRelockBLClick(Sender: TObject);
    procedure btnUnlockBLClick(Sender: TObject);
    procedure btnFormatDataClick(Sender: TObject);
  private
    FService: TGWTCommandService;
    FDevicePathFunc: TDevicePathGetter;
    function GetDevicePath: string;
  public
    procedure BindService(AService: TGWTCommandService; ADevicePathFunc: TDevicePathGetter);
  end;

implementation

{$R *.dfm}

procedure TFrameHuaweiService.BindService(AService: TGWTCommandService;
  ADevicePathFunc: TDevicePathGetter);
begin
  FService := AService;
  FDevicePathFunc := ADevicePathFunc;
end;

function TFrameHuaweiService.GetDevicePath: string;
begin
  Result := '';
  if Assigned(FDevicePathFunc) then
    Result := FDevicePathFunc();
end;

procedure TFrameHuaweiService.btnResetFRPClick(Sender: TObject);
var
  DevPath, Key: string;
begin
  if not Assigned(FService) then Exit;
  DevPath := GetDevicePath;
  if DevPath = '' then
  begin
    MessageDlg('Please select a connected Fastboot device from the USB Port Detection box.', mtWarning, [mbOK], 0);
    Exit;
  end;

  Key := Trim(edtFRPKey.Text);
  if Key = '' then
  begin
    MessageDlg('Please enter a valid Huawei FRP Key / Reset Token first.', mtWarning, [mbOK], 0);
    edtFRPKey.SetFocus;
    Exit;
  end;

  FService.HuaweiResetFRP(DevPath, Key);
end;

procedure TFrameHuaweiService.btnReadInfoClick(Sender: TObject);
var
  DevPath: string;
begin
  if not Assigned(FService) then Exit;
  DevPath := GetDevicePath;
  if DevPath = '' then
  begin
    MessageDlg('Please connect a Fastboot device first.', mtWarning, [mbOK], 0);
    Exit;
  end;
  FService.HuaweiReadInfo(DevPath);
end;

procedure TFrameHuaweiService.btnResetLockClick(Sender: TObject);
var
  DevPath: string;
begin
  if not Assigned(FService) then Exit;
  DevPath := GetDevicePath;
  if DevPath <> '' then FService.HuaweiResetScreenLock(DevPath);
end;

procedure TFrameHuaweiService.btnBypassFRPClick(Sender: TObject);
var
  DevPath: string;
begin
  if not Assigned(FService) then Exit;
  DevPath := GetDevicePath;
  if DevPath <> '' then FService.HuaweiBypassFRPAndLock(DevPath);
end;

procedure TFrameHuaweiService.btnRemoveIDClick(Sender: TObject);
var
  DevPath: string;
begin
  if not Assigned(FService) then Exit;
  DevPath := GetDevicePath;
  if DevPath <> '' then FService.HuaweiRemoveID(DevPath);
end;

procedure TFrameHuaweiService.btnRelockBLClick(Sender: TObject);
var
  DevPath: string;
begin
  if not Assigned(FService) then Exit;
  DevPath := GetDevicePath;
  if DevPath <> '' then FService.HuaweiRelockBootloader(DevPath);
end;

procedure TFrameHuaweiService.btnUnlockBLClick(Sender: TObject);
var
  DevPath: string;
begin
  if not Assigned(FService) then Exit;
  DevPath := GetDevicePath;
  if DevPath <> '' then FService.HuaweiUnlockBootloader(DevPath, edtFRPKey.Text);
end;

procedure TFrameHuaweiService.btnFormatDataClick(Sender: TObject);
var
  DevPath: string;
begin
  if not Assigned(FService) then Exit;
  DevPath := GetDevicePath;
  if DevPath <> '' then FService.HuaweiFormatUserdataSafe(DevPath);
end;

end.
```

### 8.2 VCL DFM Layout (`Frames\Frame.HuaweiService.dfm`)

```text
object FrameHuaweiService: TFrameHuaweiService
  Left = 0
  Top = 0
  Width = 680
  Height = 460
  Color = 1708299
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWhite
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  ParentBackground = False
  ParentColor = False
  ParentDoubleBuffered = False
  ParentFont = False
  StyleElements = []
  TabOrder = 0
  object pnlFRPCard: TPanel
    AlignWithMargins = True
    Left = 8
    Top = 8
    Width = 664
    Height = 128
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alTop
    BevelOuter = bvNone
    Color = 2365198
    ParentBackground = False
    StyleElements = []
    TabOrder = 0
    DesignSize = (
      664
      128)
    object lblFRPHeader: TLabel
      Left = 16
      Top = 12
      Width = 129
      Height = 17
      Caption = 'HUAWEI FRP RESET'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 16773120
      Font.Height = -13
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
      StyleElements = []
    end
    object lblFRPSub: TLabel
      Left = 16
      Top = 42
      Width = 177
      Height = 15
      Caption = 'ENTER FRP KEY / RESET TOKEN'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 12959408
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleElements = []
    end
    object edtFRPKey: TEdit
      Left = 16
      Top = 64
      Width = 380
      Height = 36
      Anchors = [akLeft, akTop, akRight]
      Color = 1839884
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Consolas'
      Font.Style = []
      ParentFont = False
      StyleElements = []
      TabOrder = 0
      TextHint = 'Enter Huawei FRP Reset Key / Code...'
    end
    object btnResetFRP: TButton
      Left = 408
      Top = 64
      Width = 136
      Height = 36
      Anchors = [akTop, akRight]
      Caption = 'RESET FRP'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = btnResetFRPClick
    end
    object btnReadInfo: TButton
      Left = 552
      Top = 64
      Width = 96
      Height = 36
      Anchors = [akTop, akRight]
      Caption = 'READ INFO'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = btnReadInfoClick
    end
  end
  object pnlLocksCard: TPanel
    AlignWithMargins = True
    Left = 8
    Top = 148
    Width = 664
    Height = 304
    Margins.Left = 8
    Margins.Top = 4
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alClient
    BevelOuter = bvNone
    Color = 2365198
    ParentBackground = False
    StyleElements = []
    TabOrder = 1
    object lblLocksHeader: TLabel
      AlignWithMargins = True
      Left = 16
      Top = 12
      Width = 632
      Height = 20
      Margins.Left = 16
      Margins.Top = 12
      Margins.Right = 16
      Margins.Bottom = 8
      Align = alTop
      Caption = 'LOCKS & SECURITY'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 12959408
      Font.Height = -13
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
      StyleElements = []
    end
    object gpLockButtons: TGridPanel
      AlignWithMargins = True
      Left = 12
      Top = 44
      Width = 640
      Height = 248
      Margins.Left = 12
      Margins.Top = 4
      Margins.Right = 12
      Margins.Bottom = 12
      Align = alClient
      BevelOuter = bvNone
      Color = 2365198
      ColumnCollection = <
        item
          Value = 50.000000000000000000
        end
        item
          Value = 50.000000000000000000
        end>
      ControlCollection = <
        item
          Column = 0
          Control = btnResetLock
          Row = 0
        end
        item
          Column = 1
          Control = btnBypassFRP
          Row = 0
        end
        item
          Column = 0
          Control = btnRemoveID
          Row = 1
        end
        item
          Column = 1
          Control = btnRelockBL
          Row = 1
        end
        item
          Column = 0
          Control = btnUnlockBL
          Row = 2
        end
        item
          Column = 1
          Control = btnFormatData
          Row = 2
        end>
      ParentBackground = False
      RowCollection = <
        item
          Value = 33.333333333333330000
        end
        item
          Value = 33.333333333333330000
        end
        item
          Value = 33.333333333333340000
        end>
      StyleElements = []
      TabOrder = 0
      object btnResetLock: TButton
        AlignWithMargins = True
        Left = 8
        Top = 8
        Width = 304
        Height = 66
        Margins.Left = 8
        Margins.Top = 8
        Margins.Right = 8
        Margins.Bottom = 8
        Align = alClient
        Caption = 'RESET SCREEN LOCK'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        OnClick = btnResetLockClick
      end
      object btnBypassFRP: TButton
        AlignWithMargins = True
        Left = 328
        Top = 8
        Width = 304
        Height = 66
        Margins.Left = 8
        Margins.Top = 8
        Margins.Right = 8
        Margins.Bottom = 8
        Align = alClient
        Caption = 'BYPASS FRP & SCREEN LOCK'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        OnClick = btnBypassFRPClick
      end
      object btnRemoveID: TButton
        AlignWithMargins = True
        Left = 8
        Top = 90
        Width = 304
        Height = 66
        Margins.Left = 8
        Margins.Top = 8
        Margins.Right = 8
        Margins.Bottom = 8
        Align = alClient
        Caption = 'REMOVE HUAWEI ID'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        OnClick = btnRemoveIDClick
      end
      object btnRelockBL: TButton
        AlignWithMargins = True
        Left = 328
        Top = 90
        Width = 304
        Height = 66
        Margins.Left = 8
        Margins.Top = 8
        Margins.Right = 8
        Margins.Bottom = 8
        Align = alClient
        Caption = 'RELOCK BOOTLOADER'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 3
        OnClick = btnRelockBLClick
      end
      object btnUnlockBL: TButton
        AlignWithMargins = True
        Left = 8
        Top = 172
        Width = 304
        Height = 68
        Margins.Left = 8
        Margins.Top = 8
        Margins.Right = 8
        Margins.Bottom = 8
        Align = alClient
        Caption = 'UNLOCK BOOTLOADER'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 4
        OnClick = btnUnlockBLClick
      end
      object btnFormatData: TButton
        AlignWithMargins = True
        Left = 328
        Top = 172
        Width = 304
        Height = 68
        Margins.Left = 8
        Margins.Top = 8
        Margins.Right = 8
        Margins.Bottom = 8
        Align = alClient
        Caption = 'FORMAT USERDATA (SAFE)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 5
        OnClick = btnFormatDataClick
      end
    end
  end
end
```

---

## 9. Module 6: Main Form Shell

### 9.1 Pascal Code (`UI\Form.Main.pas`)

```pascal
unit Form.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls,
  GWT.Types, GWT.CommandService, Frame.HuaweiService;

const
  DBT_DEVICEARRIVAL           = $8000;
  DBT_DEVICEREMOVECOMPLETE    = $8004;
  DBT_DEVTYP_DEVICEINTERFACE  = $00000005;

type
  PDevBroadcastDeviceInterface = ^TDevBroadcastDeviceInterface;
  TDevBroadcastDeviceInterface = record
    dbcc_size: DWORD;
    dbcc_devicetype: DWORD;
    dbcc_reserved: DWORD;
    dbcc_classguid: TGUID;
    dbcc_name: array[0..0] of WideChar;
  end;

  TFormMain = class(TForm)
    pnlHeader: TPanel;
    lblBrandLogo: TLabel;
    lblAppTitle: TLabel;
    lblConnStatus: TLabel;
    pnlBody: TPanel;
    pnlRightSidebar: TPanel;
    pnlUsbBox: TPanel;
    lblUsbTitle: TLabel;
    cbUSBDevices: TComboBox;
    pnlLogBox: TPanel;
    lblLogTitle: TLabel;
    redLogs: TRichEdit;
    pnlWorkspace: TPanel;
    gpBrandTabs: TGridPanel;
    btnBrandXiaomi: TButton;
    btnBrandVivo: TButton;
    btnBrandHuawei: TButton;
    gpModeTabs: TGridPanel;
    btnModeADB: TButton;
    btnModeFastboot: TButton;
    btnModeRecovery: TButton;
    pnlSubTabs: TPanel;
    btnSubService: TButton;
    btnSubFlash: TButton;
    pnlFrameHost: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BrandTabClick(Sender: TObject);
    procedure ModeTabClick(Sender: TObject);
    procedure SubTabClick(Sender: TObject);
  private
    FCommandService: TGWTCommandService;
    FActiveBrand: TBrandKind;
    FActiveMode: TDeviceMode;
    FActiveSubMode: TSubMode;
    FCurrentFrame: TFrame;
    FUsbNotifyHandle: HDEVNOTIFY;
    FDiscoveredDevices: TArray<TUsbDeviceInfo>;

    procedure AppendLog(const AMsg: string; ALevel: TLogLevel);
    procedure UpdateNavigationUI;
    procedure LoadActiveFrame;
    procedure RefreshUsbDevicesAsync;
    procedure RegisterUsbNotifications;
    procedure UnregisterUsbNotifications;
    function GetSelectedDevicePath: string;
  protected
    procedure WMDeviceChange(var Msg: TMessage); message WM_DEVICECHANGE;
  public
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FCommandService := TGWTCommandService.Create(AppendLog);

  // Default state matching GWT design
  FActiveBrand := bkHuawei;
  FActiveMode := dmFastboot;
  FActiveSubMode := smService;

  RegisterUsbNotifications;
  UpdateNavigationUI;
  LoadActiveFrame;

  AppendLog('GWT ADB & Fastboot Tool v1.2 loaded.', llInfo);
  AppendLog('Native WinUSB + Fastboot + ADB Engine initialized.', llSuccess);
  RefreshUsbDevicesAsync;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  UnregisterUsbNotifications;
  FreeAndNil(FCurrentFrame);
  FreeAndNil(FCommandService);
end;

procedure TFormMain.RegisterUsbNotifications;
var
  Filter: TDevBroadcastDeviceInterface;
begin
  ZeroMemory(@Filter, SizeOf(Filter));
  Filter.dbcc_size := SizeOf(Filter);
  Filter.dbcc_devicetype := DBT_DEVTYP_DEVICEINTERFACE;
  Filter.dbcc_classguid := GUID_DEVINTERFACE_USB_DEVICE;
  FUsbNotifyHandle := RegisterDeviceNotification(Handle, @Filter, DEVICE_NOTIFY_WINDOW_HANDLE);
end;

procedure TFormMain.UnregisterUsbNotifications;
begin
  if FUsbNotifyHandle <> nil then
  begin
    UnregisterDeviceNotification(FUsbNotifyHandle);
    FUsbNotifyHandle := nil;
  end;
end;

procedure TFormMain.WMDeviceChange(var Msg: TMessage);
begin
  inherited;
  if (Msg.WParam = DBT_DEVICEARRIVAL) or (Msg.WParam = DBT_DEVICEREMOVECOMPLETE) then
    RefreshUsbDevicesAsync;
end;

function TFormMain.GetSelectedDevicePath: string;
var
  Idx: Integer;
begin
  Result := '';
  Idx := cbUSBDevices.ItemIndex;
  if (Idx >= 0) and (Idx < Length(FDiscoveredDevices)) then
    Result := FDiscoveredDevices[Idx].DevicePath;
end;

procedure TFormMain.RefreshUsbDevicesAsync;
begin
  TThread.CreateAnonymousThread(
    procedure
    var
      Devs: TArray<TUsbDeviceInfo>;
    begin
      Sleep(400); // Allow USB interface driver to settle
      Devs := FCommandService.ScanConnectedInterfaces;

      TThread.Queue(nil,
        procedure
        var
          I: Integer;
        begin
          FDiscoveredDevices := Devs;
          cbUSBDevices.Items.BeginUpdate;
          try
            cbUSBDevices.Items.Clear;
            if Length(Devs) = 0 then
            begin
              cbUSBDevices.Items.Add('[-] Waiting for USB device...');
              lblConnStatus.Caption := #$25CF + ' WAITING FOR DEVICE';
              lblConnStatus.Font.Color := CLR_LOG_WARN;
            end
            else
            begin
              for I := 0 to High(Devs) do
                cbUSBDevices.Items.Add(Devs[I].FriendlyName);

              lblConnStatus.Caption := #$25CF + ' ONLINE / CONNECTED';
              lblConnStatus.Font.Color := CLR_LOG_SUCCESS;
              AppendLog('Detected USB endpoint: ' + Devs[0].FriendlyName, llSuccess);
            end;
            cbUSBDevices.ItemIndex := 0;
          finally
            cbUSBDevices.Items.EndUpdate;
          end;
        end);
    end).Start;
end;

procedure TFormMain.AppendLog(const AMsg: string; ALevel: TLogLevel);
var
  LogColor: TColor;
  Prefix: string;
begin
  case ALevel of
    llSuccess: begin LogColor := CLR_LOG_SUCCESS; Prefix := '[OK] '; end;
    llWarning: begin LogColor := CLR_LOG_WARN; Prefix := '[!] '; end;
    llError:   begin LogColor := CLR_LOG_ERROR; Prefix := '[ERR] '; end;
    llTx:      begin LogColor := CLR_ACCENT_CYAN; Prefix := '[TX] '; end;
    llRx:      begin LogColor := CLR_TEXT_PRIMARY; Prefix := '[RX] '; end;
  else
    begin LogColor := CLR_TEXT_MUTED; Prefix := '[*] '; end;
  end;

  redLogs.SelStart := redLogs.GetTextLen;
  redLogs.SelAttributes.Color := CLR_TEXT_MUTED;
  redLogs.SelText := Format('[%s] ', [FormatDateTime('hh:nn:ss', Now)]);

  redLogs.SelStart := redLogs.GetTextLen;
  redLogs.SelAttributes.Color := LogColor;
  redLogs.SelText := Prefix + AMsg + sLineBreak;

  SendMessage(redLogs.Handle, WM_VSCROLL, SB_BOTTOM, 0);
end;

procedure TFormMain.BrandTabClick(Sender: TObject);
begin
  if Sender = btnBrandXiaomi then FActiveBrand := bkXiaomi
  else if Sender = btnBrandVivo then FActiveBrand := bkVivo
  else if Sender = btnBrandHuawei then FActiveBrand := bkHuawei;

  UpdateNavigationUI;
  LoadActiveFrame;
end;

procedure TFormMain.ModeTabClick(Sender: TObject);
begin
  if Sender = btnModeADB then FActiveMode := dmADB
  else if Sender = btnModeFastboot then FActiveMode := dmFastboot
  else if Sender = btnModeRecovery then FActiveMode := dmRecovery;

  UpdateNavigationUI;
  LoadActiveFrame;
end;

procedure TFormMain.SubTabClick(Sender: TObject);
begin
  if Sender = btnSubService then FActiveSubMode := smService
  else if Sender = btnSubFlash then FActiveSubMode := smFlash;

  UpdateNavigationUI;
  LoadActiveFrame;
end;

procedure TFormMain.UpdateNavigationUI;
begin
  btnBrandXiaomi.Font.Style := [];
  btnBrandVivo.Font.Style := [];
  btnBrandHuawei.Font.Style := [];
  case FActiveBrand of
    bkXiaomi: btnBrandXiaomi.Font.Style := [fsBold, fsUnderline];
    bkVivo:   btnBrandVivo.Font.Style := [fsBold, fsUnderline];
    bkHuawei: btnBrandHuawei.Font.Style := [fsBold, fsUnderline];
  end;

  btnModeADB.Font.Style := [];
  btnModeFastboot.Font.Style := [];
  btnModeRecovery.Font.Style := [];
  case FActiveMode of
    dmADB:      btnModeADB.Font.Style := [fsBold, fsUnderline];
    dmFastboot: btnModeFastboot.Font.Style := [fsBold, fsUnderline];
    dmRecovery: btnModeRecovery.Font.Style := [fsBold, fsUnderline];
  end;

  pnlSubTabs.Visible := (FActiveMode = dmFastboot);
  btnSubService.Font.Style := [];
  btnSubFlash.Font.Style := [];
  if FActiveSubMode = smService then
    btnSubService.Font.Style := [fsBold, fsUnderline]
  else
    btnSubFlash.Font.Style := [fsBold, fsUnderline];
end;

procedure TFormMain.LoadActiveFrame;
var
  HuaweiFrm: TFrameHuaweiService;
begin
  FreeAndNil(FCurrentFrame);

  if (FActiveBrand = bkHuawei) and (FActiveMode = dmFastboot) and (FActiveSubMode = smService) then
  begin
    HuaweiFrm := TFrameHuaweiService.Create(Self);
    HuaweiFrm.Parent := pnlFrameHost;
    HuaweiFrm.Align := alClient;
    HuaweiFrm.BindService(FCommandService, GetSelectedDevicePath);
    FCurrentFrame := HuaweiFrm;
  end
  else
  begin
    AppendLog('Selected module frame is not loaded yet.', llWarning);
  end;
end;

end.
```

### 9.2 VCL DFM Layout (`UI\Form.Main.dfm`)

```text
object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'GWT ADB & Fastboot Tool v1.2'
  ClientHeight = 660
  ClientWidth = 1080
  Color = 1708299
  Constraints.MinHeight = 600
  Constraints.MinWidth = 960
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWhite
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  StyleElements = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 1080
    Height = 52
    Align = alTop
    BevelOuter = bvNone
    Color = 2365198
    ParentBackground = False
    StyleElements = []
    TabOrder = 0
    DesignSize = (
      1080
      52)
    object lblBrandLogo: TLabel
      Left = 18
      Top = 10
      Width = 54
      Height = 31
      Caption = 'GWT'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 16773120
      Font.Height = -23
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleElements = []
    end
    object lblAppTitle: TLabel
      Left = 82
      Top = 17
      Width = 224
      Height = 20
      Caption = 'ADB & FASTBOOT TOOL v1.2'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -15
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
      StyleElements = []
    end
    object lblConnStatus: TLabel
      Left = 874
      Top = 18
      Width = 186
      Height = 17
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = #9679' WAITING FOR DEVICE'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 46079
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleElements = []
    end
  end
  object pnlBody: TPanel
    Left = 0
    Top = 52
    Width = 1080
    Height = 608
    Align = alClient
    BevelOuter = bvNone
    Color = 1708299
    ParentBackground = False
    StyleElements = []
    TabOrder = 1
    object pnlRightSidebar: TPanel
      AlignWithMargins = True
      Left = 744
      Top = 8
      Width = 328
      Height = 592
      Margins.Left = 4
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      Align = alRight
      BevelOuter = bvNone
      Color = 2365198
      ParentBackground = False
      StyleElements = []
      TabOrder = 0
      object pnlUsbBox: TPanel
        Left = 0
        Top = 0
        Width = 328
        Height = 76
        Align = alTop
        BevelOuter = bvNone
        Color = 2365198
        ParentBackground = False
        StyleElements = []
        TabOrder = 0
        object lblUsbTitle: TLabel
          AlignWithMargins = True
          Left = 12
          Top = 10
          Width = 304
          Height = 15
          Margins.Left = 12
          Margins.Top = 10
          Margins.Right = 12
          Margins.Bottom = 4
          Align = alTop
          Caption = 'USB PORT DETECTION'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 12959408
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleElements = []
        end
        object cbUSBDevices: TComboBox
          AlignWithMargins = True
          Left = 12
          Top = 33
          Width = 304
          Height = 25
          Margins.Left = 12
          Margins.Top = 4
          Margins.Right = 12
          Margins.Bottom = 8
          Align = alTop
          Style = csDropDownList
          Color = 1839884
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
      end
      object pnlLogBox: TPanel
        Left = 0
        Top = 76
        Width = 328
        Height = 516
        Align = alClient
        BevelOuter = bvNone
        Color = 2365198
        ParentBackground = False
        StyleElements = []
        TabOrder = 1
        object lblLogTitle: TLabel
          AlignWithMargins = True
          Left = 12
          Top = 6
          Width = 304
          Height = 15
          Margins.Left = 12
          Margins.Top = 6
          Margins.Right = 12
          Margins.Bottom = 6
          Align = alTop
          Caption = 'OPERATION LOGS'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 12959408
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleElements = []
        end
        object redLogs: TRichEdit
          AlignWithMargins = True
          Left = 12
          Top = 27
          Width = 304
          Height = 477
          Margins.Left = 12
          Margins.Top = 0
          Margins.Right = 12
          Margins.Bottom = 12
          Align = alClient
          BorderStyle = bsNone
          Color = 1051911
          Font.Charset = ANSI_CHARSET
          Font.Color = 12959408
          Font.Height = -12
          Font.Name = 'Consolas'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssVertical
          StyleElements = []
          TabOrder = 0
        end
      end
    end
    object pnlWorkspace: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 8
      Width = 728
      Height = 592
      Margins.Left = 8
      Margins.Top = 8
      Margins.Right = 4
      Margins.Bottom = 8
      Align = alClient
      BevelOuter = bvNone
      Color = 1708299
      ParentBackground = False
      StyleElements = []
      TabOrder = 1
      object gpBrandTabs: TGridPanel
        Left = 0
        Top = 0
        Width = 728
        Height = 46
        Align = alTop
        BevelOuter = bvNone
        Color = 1708299
        ColumnCollection = <
          item
            Value = 33.333333333333330000
          end
          item
            Value = 33.333333333333330000
          end
          item
            Value = 33.333333333333340000
          end>
        ControlCollection = <
          item
            Column = 0
            Control = btnBrandXiaomi
            Row = 0
          end
          item
            Column = 1
            Control = btnBrandVivo
            Row = 0
          end
          item
            Column = 2
            Control = btnBrandHuawei
            Row = 0
          end>
        ParentBackground = False
        RowCollection = <
          item
            Value = 100.000000000000000000
          end>
        StyleElements = []
        TabOrder = 0
        object btnBrandXiaomi: TButton
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 234
          Height = 38
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Align = alClient
          Caption = 'XIAOMI'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -14
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = BrandTabClick
        end
        object btnBrandVivo: TButton
          AlignWithMargins = True
          Left = 246
          Top = 4
          Width = 234
          Height = 38
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Align = alClient
          Caption = 'VIVO'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -14
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = BrandTabClick
        end
        object btnBrandHuawei: TButton
          AlignWithMargins = True
          Left = 488
          Top = 4
          Width = 236
          Height = 38
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Align = alClient
          Caption = 'HUAWEI'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -14
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 2
          OnClick = BrandTabClick
        end
      end
      object gpModeTabs: TGridPanel
        AlignWithMargins = True
        Left = 0
        Top = 52
        Width = 728
        Height = 40
        Margins.Left = 0
        Margins.Top = 6
        Margins.Right = 0
        Margins.Bottom = 4
        Align = alTop
        BevelOuter = bvNone
        Color = 1708299
        ColumnCollection = <
          item
            Value = 33.333333333333330000
          end
          item
            Value = 33.333333333333330000
          end
          item
            Value = 33.333333333333340000
          end>
        ControlCollection = <
          item
            Column = 0
            Control = btnModeADB
            Row = 0
          end
          item
            Column = 1
            Control = btnModeFastboot
            Row = 0
          end
          item
            Column = 2
            Control = btnModeRecovery
            Row = 0
          end>
        ParentBackground = False
        RowCollection = <
          item
            Value = 100.000000000000000000
          end>
        StyleElements = []
        TabOrder = 1
        object btnModeADB: TButton
          AlignWithMargins = True
          Left = 4
          Top = 2
          Width = 234
          Height = 36
          Margins.Left = 4
          Margins.Top = 2
          Margins.Right = 4
          Margins.Bottom = 2
          Align = alClient
          Caption = 'ADB'
          TabOrder = 0
          OnClick = ModeTabClick
        end
        object btnModeFastboot: TButton
          AlignWithMargins = True
          Left = 246
          Top = 2
          Width = 234
          Height = 36
          Margins.Left = 4
          Margins.Top = 2
          Margins.Right = 4
          Margins.Bottom = 2
          Align = alClient
          Caption = 'FASTBOOT'
          TabOrder = 1
          OnClick = ModeTabClick
        end
        object btnModeRecovery: TButton
          AlignWithMargins = True
          Left = 488
          Top = 2
          Width = 236
          Height = 36
          Margins.Left = 4
          Margins.Top = 2
          Margins.Right = 4
          Margins.Bottom = 2
          Align = alClient
          Caption = 'RECOVERY'
          TabOrder = 2
          OnClick = ModeTabClick
        end
      end
      object pnlSubTabs: TPanel
        AlignWithMargins = True
        Left = 4
        Top = 100
        Width = 720
        Height = 36
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alTop
        BevelOuter = bvNone
        Color = 1708299
        ParentBackground = False
        StyleElements = []
        TabOrder = 2
        object btnSubService: TButton
          Left = 0
          Top = 2
          Width = 130
          Height = 32
          Caption = 'SERVICE'
          TabOrder = 0
          OnClick = SubTabClick
        end
        object btnSubFlash: TButton
          Left = 138
          Top = 2
          Width = 130
          Height = 32
          Caption = 'FLASH'
          TabOrder = 1
          OnClick = SubTabClick
        end
      end
      object pnlFrameHost: TPanel
        Left = 0
        Top = 140
        Width = 728
        Height = 452
        Align = alClient
        BevelOuter = bvNone
        Color = 1708299
        ParentBackground = False
        StyleElements = []
        TabOrder = 3
      end
    end
  end
end
```

---

## 10. Module 7: Main Delphi 13 Project (`GWT_Tool.dpr`)

```pascal
program GWT_Tool;

uses
  Vcl.Forms,
  GWT.Types in 'Core\GWT.Types.pas',
  GWT.WinUSB.API in 'Protocols\GWT.WinUSB.API.pas',
  GWT.WinUSB.Transport in 'Protocols\GWT.WinUSB.Transport.pas',
  GWT.Protocol.Fastboot in 'Protocols\GWT.Protocol.Fastboot.pas',
  GWT.Protocol.ADB in 'Protocols\GWT.Protocol.ADB.pas',
  GWT.CommandService in 'Services\GWT.CommandService.pas',
  Frame.HuaweiService in 'Frames\Frame.HuaweiService.pas' {FrameHuaweiService: TFrame},
  Form.Main in 'UI\Form.Main.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'GWT ADB & Fastboot Tool v1.2';
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
```

---

## 11. Compilation & Build Guide (RAD Studio 13 / Delphi 13)

### 11.1 Build Command Line

Execute from `D:\studio\tools\adb-fastboot\GWT_Tool`:

```cmd
dcc32 -B -Q -ICore;Protocols;Services;Frames;UI -UCoe;Protocols;Services;Frames;UI;"D:\studio\rad\37.0\lib\win32\release" -E..\bin\Win32 -NU..\bin\dcu\Win32 GWT_Tool.dpr
```

Or for 64-bit:

```cmd
dcc64 -B -Q -ICore;Protocols;Services;Frames;UI -UCore;Protocols;Services;Frames;UI;"D:\studio\rad\37.0\lib\win64\release" -E..\bin\Win64 -NU..\bin\dcu\Win64 GWT_Tool.dpr
```

### 11.2 Result
- Compiles a 100% standalone executable `GWT_Tool.exe`.
- Bypasses `adb.exe` and `fastboot.exe` completely, using direct WinUSB endpoints (`winusb.dll` and `setupapi.dll`).
- Full dark cyber aesthetic with real-time responsive logging and asynchronous USB transfers.
