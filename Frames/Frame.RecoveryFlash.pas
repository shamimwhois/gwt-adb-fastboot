unit Frame.RecoveryFlash;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.UITypes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls,
  GWT.Types, GWT.CommandService;

type
  TDeviceGetter = reference to function: TUsbDeviceInfo;

  TFrameRecoveryFlash = class(TFrame)
    sbContainer: TScrollBox;
    pnlFlashCard: TPanel;
    lblFlashHeader: TLabel;
    lblFlashSub: TLabel;
    lblZipFile: TLabel;
    edtZipPath: TEdit;
    btnBrowseZip: TButton;
    btnSideloadZip: TButton;
    btnRebootSystem: TButton;
    pnlProgressCard: TPanel;
    lblProgressHeader: TLabel;
    lblProgressStatus: TLabel;
    pbProgress: TProgressBar;
    dlgOpenZip: TOpenDialog;

    procedure btnBrowseZipClick(Sender: TObject);
    procedure btnSideloadZipClick(Sender: TObject);
    procedure btnRebootSystemClick(Sender: TObject);
  private
    FService: TGWTCommandService;
    FDeviceFunc: TDeviceGetter;
    function GetDevice: TUsbDeviceInfo;
    function ValidateDevice: Boolean;
    procedure HandleProgress(ACurrent, ATotal: Int64);
  public
    procedure BindService(AService: TGWTCommandService; ADeviceFunc: TDeviceGetter);
  end;

implementation

{$R *.dfm}

procedure TFrameRecoveryFlash.BindService(AService: TGWTCommandService; ADeviceFunc: TDeviceGetter);
begin
  FService := AService;
  FDeviceFunc := ADeviceFunc;
end;

function TFrameRecoveryFlash.GetDevice: TUsbDeviceInfo;
begin
  Result := Default(TUsbDeviceInfo);
  if Assigned(FDeviceFunc) then
    Result := FDeviceFunc();
end;

function TFrameRecoveryFlash.ValidateDevice: Boolean;
var
  Dev: TUsbDeviceInfo;
begin
  Result := False;
  if not Assigned(FService) then Exit;
  Dev := GetDevice;
  if (Dev.DevicePath = '') and not Dev.IsSocketBased then
  begin
    MessageDlg('Please connect an Android device in Sideload / Recovery mode.', mtWarning, [mbOK], 0);
    Exit;
  end;
  Result := True;
end;

procedure TFrameRecoveryFlash.btnBrowseZipClick(Sender: TObject);
begin
  if dlgOpenZip.Execute then
    edtZipPath.Text := dlgOpenZip.FileName;
end;

procedure TFrameRecoveryFlash.HandleProgress(ACurrent, ATotal: Int64);
var
  Pct: Integer;
begin
  if ATotal > 0 then
    Pct := Integer(Trunc((ACurrent / ATotal) * 100))
  else
    Pct := 0;

  TThread.Queue(nil,
    procedure
    begin
      pbProgress.Position := Pct;
      lblProgressStatus.Caption := Format('Transferred: %d%%', [Pct]);
    end);
end;

procedure TFrameRecoveryFlash.btnSideloadZipClick(Sender: TObject);
var
  ZipPath: string;
begin
  if not ValidateDevice then Exit;
  ZipPath := Trim(edtZipPath.Text);
  if (ZipPath = '') or not FileExists(ZipPath) then
  begin
    MessageDlg('Please select a valid recovery update ZIP package first.', mtWarning, [mbOK], 0);
    Exit;
  end;

  pbProgress.Position := 0;
  lblProgressStatus.Caption := 'Sideloading OTA Package...';
  FService.RecoverySideload(GetDevice, ZipPath, HandleProgress);
end;

procedure TFrameRecoveryFlash.btnRebootSystemClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.AdbReboot(GetDevice, '');
end;

end.
