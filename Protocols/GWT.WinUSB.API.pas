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
  TSP_DEVICE_INTERFACE_DETAIL_DATA_W = packed record
    cbSize: DWORD;
    DevicePath: array[0..MAX_PATH - 1] of WideChar;
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
