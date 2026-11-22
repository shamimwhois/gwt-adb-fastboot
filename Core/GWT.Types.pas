unit GWT.Types;

interface

uses
  System.SysUtils, Vcl.Graphics;

type
  TBrandKind  = (bkXiaomi, bkVivo, bkHuawei);
  TDeviceMode = (dmADB, dmFastboot, dmRecovery);
  TSubMode    = (smService, smFlash);
  TLogLevel   = (llInfo, llSuccess, llWarning, llError, llTx, llRx, llCommand);

  TUsbDeviceInfo = record
    DevicePath: string;
    FriendlyName: string;
    InterfaceType: string; // 'ADB' or 'FASTBOOT'
    Serial: string;
    VID: Word;
    PID: Word;
    IsSocketBased: Boolean;
  end;

  TLogCallback = reference to procedure(const AMsg: string; ALevel: TLogLevel);
  TProgressCallback = reference to procedure(ACurrent, ATotal: Int64);

const
  // GWT Dark Cyber Theme (Delphi TColor is $00BBGGRR)
  CLR_BG_MAIN      = TColor($001A110B); // #0B111A
  CLR_BG_PANEL     = TColor($0024170E); // #0E1724
  CLR_BG_CARD      = TColor($00302014); // #142030
  CLR_BG_INPUT     = TColor($001C130C); // #0C131C
  CLR_BG_TERMINAL  = TColor($00100D07); // #070D10
  CLR_ACCENT_CYAN  = TColor($00FFF000); // #00F0FF
  CLR_TEXT_PRIMARY = TColor($00FFFFFF); // #FFFFFF
  CLR_TEXT_MUTED   = TColor($00C5BEB0); // #B0BEC5
  CLR_LOG_SUCCESS  = TColor($0076E600); // #00E676
  CLR_LOG_WARN     = TColor($0000B3FF); // #FFB300
  CLR_LOG_ERROR    = TColor($004E4EFF); // #FF4E4E

  // Standard Android WinUSB & USB Interface GUIDs
  GUID_ANDROID_USB_DEVICE:     TGUID = '{F72FE0D4-CBCB-407D-8814-9ED673D0DD6B}';
  GUID_ANDROID_USB_DEVICE_ALT: TGUID = '{F72DE06D-F0E7-460B-BE60-DE66B3ED4962}';
  GUID_FASTBOOT_DEVICE:        TGUID = '{9D399F9B-BDFE-4C6C-BB4B-A1C1A2EDE1E7}';
  GUID_ANDROID_ADB_CERT:       TGUID = '{3F966BD9-FA04-4EC5-991C-D326973B5128}';
  GUID_WINUSB_GENERIC:         TGUID = '{DEE824EF-729B-4A0E-9C14-B7117D33A817}';
  GUID_WINUSB_LIBWDI:          TGUID = '{88BAE032-5A81-49F0-BC3D-A4FF138216D6}';
  GUID_DEVINTERFACE_USB_DEVICE: TGUID = '{A5DCBF10-6530-11D2-901F-00C04FB951ED}';

  // Android USB Interface Class / SubClass / Protocol
  USB_CLASS_VENDOR_SPEC   = $FF;
  USB_SUBCLASS_ADB        = $42;
  USB_PROTOCOL_ADB        = $01;
  USB_PROTOCOL_FASTBOOT   = $03;

implementation

end.
