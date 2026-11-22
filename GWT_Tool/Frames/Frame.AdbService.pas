unit Frame.AdbService;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.UITypes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls,
  GWT.Types, GWT.CommandService;

type
  TDeviceGetter = reference to function: TUsbDeviceInfo;

  TFrameAdbService = class(TFrame)
    sbContainer: TScrollBox;
    pnlUniversalCard: TPanel;
    lblUniversalHeader: TLabel;
    lblUniversalSub: TLabel;
    gpUniversalButtons: TGridPanel;
    btnReadInfo: TButton;
    btnResetFRP: TButton;
    btnRebootFastboot: TButton;
    btnRebootRecovery: TButton;
    btnRebootEDL: TButton;
    btnRebootSystem: TButton;

    pnlXiaomiCard: TPanel;
    lblXiaomiHeader: TLabel;
    lblXiaomiSub: TLabel;
    gpXiaomiButtons: TGridPanel;
    btnXiaomiReadInfo: TButton;
    btnXiaomiBypassMi: TButton;
    btnXiaomiEnableDiag: TButton;
    btnXiaomiDisableAds: TButton;

    pnlVivoCard: TPanel;
    lblVivoHeader: TLabel;
    lblVivoSub: TLabel;
    gpVivoButtons: TGridPanel;
    btnVivoReadInfo: TButton;
    btnVivoFactoryReset: TButton;
    btnVivoEnableDiag: TButton;
    btnVivoRemoveDemo: TButton;

    pnlHuaweiCard: TPanel;
    lblHuaweiHeader: TLabel;
    lblHuaweiSub: TLabel;
    gpHuaweiButtons: TGridPanel;
    btnHuaweiReadBuild: TButton;
    btnHuaweiManufacture: TButton;
    btnHuaweiResetFRP: TButton;

    procedure btnReadInfoClick(Sender: TObject);
    procedure btnResetFRPClick(Sender: TObject);
    procedure btnRebootFastbootClick(Sender: TObject);
    procedure btnRebootRecoveryClick(Sender: TObject);
    procedure btnRebootEDLClick(Sender: TObject);
    procedure btnRebootSystemClick(Sender: TObject);

    procedure btnXiaomiReadInfoClick(Sender: TObject);
    procedure btnXiaomiBypassMiClick(Sender: TObject);
    procedure btnXiaomiEnableDiagClick(Sender: TObject);
    procedure btnXiaomiDisableAdsClick(Sender: TObject);

    procedure btnVivoReadInfoClick(Sender: TObject);
    procedure btnVivoFactoryResetClick(Sender: TObject);
    procedure btnVivoEnableDiagClick(Sender: TObject);
    procedure btnVivoRemoveDemoClick(Sender: TObject);

    procedure btnHuaweiReadBuildClick(Sender: TObject);
    procedure btnHuaweiManufactureClick(Sender: TObject);
    procedure btnHuaweiResetFRPClick(Sender: TObject);
  private
    FService: TGWTCommandService;
    FDeviceFunc: TDeviceGetter;
    FOnModeSwitch: TDeviceModeDetected;
    function GetDevice: TUsbDeviceInfo;
    function ValidateDevice: Boolean;
  public
    procedure BindService(AService: TGWTCommandService; ADeviceFunc: TDeviceGetter;
      AOnModeSwitch: TDeviceModeDetected = nil);
  end;

implementation

{$R *.dfm}

procedure TFrameAdbService.BindService(AService: TGWTCommandService;
  ADeviceFunc: TDeviceGetter; AOnModeSwitch: TDeviceModeDetected);
begin
  FService := AService;
  FDeviceFunc := ADeviceFunc;
  FOnModeSwitch := AOnModeSwitch;
end;

function TFrameAdbService.GetDevice: TUsbDeviceInfo;
begin
  Result := Default(TUsbDeviceInfo);
  if Assigned(FDeviceFunc) then
    Result := FDeviceFunc();
end;

function TFrameAdbService.ValidateDevice: Boolean;
var
  Dev: TUsbDeviceInfo;
begin
  Result := False;
  if not Assigned(FService) then Exit;
  Dev := GetDevice;
  if (Dev.DevicePath = '') and not Dev.IsSocketBased then
  begin
    MessageDlg('Please connect an Android device with USB debugging enabled.', mtWarning, [mbOK], 0);
    Exit;
  end;
  Result := True;
end;

procedure TFrameAdbService.btnReadInfoClick(Sender: TObject);
begin
  if Assigned(FService) then
    FService.AdbReadDeviceInfo(GetDevice);
end;

procedure TFrameAdbService.btnResetFRPClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.AdbResetFRP(GetDevice);
end;

procedure TFrameAdbService.btnRebootFastbootClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.AdbRebootToFastboot(GetDevice, FOnModeSwitch);
end;

procedure TFrameAdbService.btnRebootRecoveryClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.AdbReboot(GetDevice, 'recovery');
end;

procedure TFrameAdbService.btnRebootEDLClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.AdbReboot(GetDevice, 'edl');
end;

procedure TFrameAdbService.btnRebootSystemClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.AdbReboot(GetDevice, '');
end;

procedure TFrameAdbService.btnXiaomiReadInfoClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.XiaomiAdbReadInfo(GetDevice);
end;

procedure TFrameAdbService.btnXiaomiBypassMiClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.XiaomiAdbBypassMiAccount(GetDevice);
end;

procedure TFrameAdbService.btnXiaomiEnableDiagClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.XiaomiAdbEnableDiag(GetDevice);
end;

procedure TFrameAdbService.btnXiaomiDisableAdsClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.XiaomiAdbDisableBloatware(GetDevice);
end;

procedure TFrameAdbService.btnVivoReadInfoClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.VivoAdbReadInfo(GetDevice);
end;

procedure TFrameAdbService.btnVivoFactoryResetClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.VivoAdbFactoryReset(GetDevice);
end;

procedure TFrameAdbService.btnVivoEnableDiagClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.VivoAdbEnableDiag(GetDevice);
end;

procedure TFrameAdbService.btnVivoRemoveDemoClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.VivoAdbDisableDemoMode(GetDevice);
end;

procedure TFrameAdbService.btnHuaweiReadBuildClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.HuaweiAdbReadBuild(GetDevice);
end;

procedure TFrameAdbService.btnHuaweiManufactureClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.HuaweiAdbEnableManufactureMode(GetDevice);
end;

procedure TFrameAdbService.btnHuaweiResetFRPClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.HuaweiAdbResetFRP(GetDevice);
end;

end.
