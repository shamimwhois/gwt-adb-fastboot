unit Frame.FastbootService;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.UITypes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls,
  GWT.Types, GWT.CommandService;

type
  TDevicePathGetter = reference to function: string;

  TFrameFastbootService = class(TFrame)
    sbContainer: TScrollBox;
    pnlHuaweiCard: TPanel;
    lblHuaweiHeader: TLabel;
    lblHuaweiSub: TLabel;
    lblFRPPrompt: TLabel;
    edtFRPKey: TEdit;
    btnHuaweiResetFRP: TButton;
    btnHuaweiReadInfo: TButton;
    btnHuaweiRelockBL: TButton;

    pnlXiaomiCard: TPanel;
    lblXiaomiHeader: TLabel;
    lblXiaomiSub: TLabel;
    gpXiaomiButtons: TGridPanel;
    btnXiaomiReadInfo: TButton;
    btnXiaomiUnlockBL: TButton;
    btnXiaomiRelockBL: TButton;
    btnXiaomiRebootEDL: TButton;
    btnXiaomiSafeWipe: TButton;

    pnlVivoCard: TPanel;
    lblVivoHeader: TLabel;
    lblVivoSub: TLabel;
    gpVivoButtons: TGridPanel;
    btnVivoReadInfo: TButton;
    btnVivoUnlockBL: TButton;
    btnVivoFactoryReset: TButton;

    pnlGeneralCard: TPanel;
    lblGeneralHeader: TLabel;
    lblGeneralSub: TLabel;
    gpGeneralButtons: TGridPanel;
    btnGeneralResetFRP: TButton;
    btnGeneralFormatData: TButton;
    btnGeneralRebootSystem: TButton;
    btnGeneralRebootRecovery: TButton;

    procedure btnHuaweiResetFRPClick(Sender: TObject);
    procedure btnHuaweiReadInfoClick(Sender: TObject);
    procedure btnHuaweiRelockBLClick(Sender: TObject);

    procedure btnXiaomiReadInfoClick(Sender: TObject);
    procedure btnXiaomiUnlockBLClick(Sender: TObject);
    procedure btnXiaomiRelockBLClick(Sender: TObject);
    procedure btnXiaomiRebootEDLClick(Sender: TObject);
    procedure btnXiaomiSafeWipeClick(Sender: TObject);

    procedure btnVivoReadInfoClick(Sender: TObject);
    procedure btnVivoUnlockBLClick(Sender: TObject);
    procedure btnVivoFactoryResetClick(Sender: TObject);

    procedure btnGeneralResetFRPClick(Sender: TObject);
    procedure btnGeneralFormatDataClick(Sender: TObject);
    procedure btnGeneralRebootSystemClick(Sender: TObject);
    procedure btnGeneralRebootRecoveryClick(Sender: TObject);
  private
    FService: TGWTCommandService;
    FDevicePathFunc: TDevicePathGetter;
    function GetDevicePath: string;
    function ValidateDevice: Boolean;
  public
    procedure BindService(AService: TGWTCommandService; ADevicePathFunc: TDevicePathGetter);
  end;

implementation

{$R *.dfm}

procedure TFrameFastbootService.BindService(AService: TGWTCommandService;
  ADevicePathFunc: TDevicePathGetter);
begin
  FService := AService;
  FDevicePathFunc := ADevicePathFunc;
end;

function TFrameFastbootService.GetDevicePath: string;
begin
  Result := '';
  if Assigned(FDevicePathFunc) then
    Result := FDevicePathFunc();
end;

function TFrameFastbootService.ValidateDevice: Boolean;
var
  DevPath: string;
begin
  Result := False;
  if not Assigned(FService) then Exit;
  DevPath := GetDevicePath;
  if DevPath = '' then
  begin
    MessageDlg('Please select a connected Fastboot device from the USB Port Detection box.', mtWarning, [mbOK], 0);
    Exit;
  end;
  Result := True;
end;

procedure TFrameFastbootService.btnHuaweiResetFRPClick(Sender: TObject);
var
  Key: string;
begin
  if not ValidateDevice then Exit;
  Key := Trim(edtFRPKey.Text);
  if Key = '' then
  begin
    MessageDlg('Please enter a valid 16-character Huawei FRP Key first.', mtWarning, [mbOK], 0);
    edtFRPKey.SetFocus;
    Exit;
  end;
  FService.HuaweiResetFRP(GetDevicePath, Key);
end;

procedure TFrameFastbootService.btnHuaweiReadInfoClick(Sender: TObject);
begin
  if Assigned(FService) then
    FService.HuaweiReadInfo(GetDevicePath);
end;

procedure TFrameFastbootService.btnHuaweiRelockBLClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.HuaweiRelockBootloader(GetDevicePath);
end;

procedure TFrameFastbootService.btnXiaomiReadInfoClick(Sender: TObject);
begin
  if Assigned(FService) then
    FService.XiaomiFastbootReadInfo(GetDevicePath);
end;

procedure TFrameFastbootService.btnXiaomiUnlockBLClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.XiaomiFastbootUnlock(GetDevicePath);
end;

procedure TFrameFastbootService.btnXiaomiRelockBLClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.XiaomiFastbootRelock(GetDevicePath);
end;

procedure TFrameFastbootService.btnXiaomiRebootEDLClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.XiaomiFastbootRebootEDL(GetDevicePath);
end;

procedure TFrameFastbootService.btnXiaomiSafeWipeClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.XiaomiFastbootWipeData(GetDevicePath);
end;

procedure TFrameFastbootService.btnVivoReadInfoClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.VivoFastbootReadInfo(GetDevicePath);
end;

procedure TFrameFastbootService.btnVivoUnlockBLClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.VivoFastbootUnlock(GetDevicePath);
end;

procedure TFrameFastbootService.btnVivoFactoryResetClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.VivoFastbootWipeData(GetDevicePath);
end;

procedure TFrameFastbootService.btnGeneralResetFRPClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.HuaweiBypassFRPAndLock(GetDevicePath);
end;

procedure TFrameFastbootService.btnGeneralFormatDataClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.FastbootErasePartition(GetDevicePath, 'userdata');
end;

procedure TFrameFastbootService.btnGeneralRebootSystemClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.FastbootReboot(GetDevicePath, '');
end;

procedure TFrameFastbootService.btnGeneralRebootRecoveryClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.FastbootReboot(GetDevicePath, 'recovery');
end;

end.
