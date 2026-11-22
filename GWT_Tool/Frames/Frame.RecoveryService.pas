unit Frame.RecoveryService;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.UITypes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls,
  GWT.Types, GWT.CommandService;

type
  TDeviceGetter = reference to function: TUsbDeviceInfo;

  TFrameRecoveryService = class(TFrame)
    sbContainer: TScrollBox;
    pnlXiaomiCard: TPanel;
    lblXiaomiHeader: TLabel;
    lblXiaomiSub: TLabel;
    gpXiaomiButtons: TGridPanel;
    btnXiaomiReadInfo: TButton;
    btnXiaomiSafeWipe: TButton;
    btnXiaomiBypassMi: TButton;

    pnlHuaweiCard: TPanel;
    lblHuaweiHeader: TLabel;
    lblHuaweiSub: TLabel;
    gpHuaweiButtons: TGridPanel;
    btnHuaweiReadInfo: TButton;
    btnHuaweiWipeData: TButton;
    btnHuaweiWipeCache: TButton;

    pnlVivoCard: TPanel;
    lblVivoHeader: TLabel;
    lblVivoSub: TLabel;
    gpVivoButtons: TGridPanel;
    btnVivoReadInfo: TButton;
    btnVivoWipeData: TButton;

    pnlGeneralCard: TPanel;
    lblGeneralHeader: TLabel;
    lblGeneralSub: TLabel;
    gpGeneralButtons: TGridPanel;
    btnGeneralRebootSystem: TButton;
    btnGeneralRebootFastboot: TButton;
    btnGeneralPowerOff: TButton;

    procedure btnXiaomiReadInfoClick(Sender: TObject);
    procedure btnXiaomiSafeWipeClick(Sender: TObject);
    procedure btnXiaomiBypassMiClick(Sender: TObject);

    procedure btnHuaweiReadInfoClick(Sender: TObject);
    procedure btnHuaweiWipeDataClick(Sender: TObject);
    procedure btnHuaweiWipeCacheClick(Sender: TObject);

    procedure btnVivoReadInfoClick(Sender: TObject);
    procedure btnVivoWipeDataClick(Sender: TObject);

    procedure btnGeneralRebootSystemClick(Sender: TObject);
    procedure btnGeneralRebootFastbootClick(Sender: TObject);
    procedure btnGeneralPowerOffClick(Sender: TObject);
  private
    FService: TGWTCommandService;
    FDeviceFunc: TDeviceGetter;
    function GetDevice: TUsbDeviceInfo;
    function ValidateDevice: Boolean;
  public
    procedure BindService(AService: TGWTCommandService; ADeviceFunc: TDeviceGetter);
  end;

implementation

{$R *.dfm}

procedure TFrameRecoveryService.BindService(AService: TGWTCommandService; ADeviceFunc: TDeviceGetter);
begin
  FService := AService;
  FDeviceFunc := ADeviceFunc;
end;

function TFrameRecoveryService.GetDevice: TUsbDeviceInfo;
begin
  Result := Default(TUsbDeviceInfo);
  if Assigned(FDeviceFunc) then
    Result := FDeviceFunc();
end;

function TFrameRecoveryService.ValidateDevice: Boolean;
var
  Dev: TUsbDeviceInfo;
begin
  Result := False;
  if not Assigned(FService) then Exit;
  Dev := GetDevice;
  if (Dev.DevicePath = '') and not Dev.IsSocketBased then
  begin
    MessageDlg('Please connect an Android device in Recovery or Sideload mode.', mtWarning, [mbOK], 0);
    Exit;
  end;
  Result := True;
end;

procedure TFrameRecoveryService.btnXiaomiReadInfoClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.XiaomiRecoveryReadInfo(GetDevice);
end;

procedure TFrameRecoveryService.btnXiaomiSafeWipeClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.XiaomiRecoveryWipeData(GetDevice);
end;

procedure TFrameRecoveryService.btnXiaomiBypassMiClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.XiaomiRecoveryBypassAccount(GetDevice);
end;

procedure TFrameRecoveryService.btnHuaweiReadInfoClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.HuaweiRecoveryReadInfo(GetDevice);
end;

procedure TFrameRecoveryService.btnHuaweiWipeDataClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.HuaweiRecoveryWipeData(GetDevice);
end;

procedure TFrameRecoveryService.btnHuaweiWipeCacheClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.HuaweiRecoveryWipeCache(GetDevice);
end;

procedure TFrameRecoveryService.btnVivoReadInfoClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.VivoRecoveryReadInfo(GetDevice);
end;

procedure TFrameRecoveryService.btnVivoWipeDataClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.VivoRecoveryWipeData(GetDevice);
end;

procedure TFrameRecoveryService.btnGeneralRebootSystemClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.AdbReboot(GetDevice, '');
end;

procedure TFrameRecoveryService.btnGeneralRebootFastbootClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.RecoveryRebootFastboot(GetDevice);
end;

procedure TFrameRecoveryService.btnGeneralPowerOffClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.AdbExecuteShell(GetDevice, 'reboot -p');
end;

end.
