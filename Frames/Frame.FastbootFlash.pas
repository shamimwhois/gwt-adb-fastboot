unit Frame.FastbootFlash;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.UITypes, System.IOUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.FileCtrl,
  GWT.Types, GWT.CommandService;

type
  TDevicePathGetter = reference to function: string;

  TFrameFastbootFlash = class(TFrame)
    sbContainer: TScrollBox;

    pnlXiaomiRomCard: TPanel;
    lblXiaomiRomHeader: TLabel;
    lblXiaomiRomSub: TLabel;
    lblRomDir: TLabel;
    edtRomPath: TEdit;
    btnBrowseRom: TButton;
    btnFlashXiaomiRom: TButton;

    pnlFlashCard: TPanel;
    lblFlashHeader: TLabel;
    lblFlashSub: TLabel;
    lblPartition: TLabel;
    cbPartition: TComboBox;
    lblImageFile: TLabel;
    edtImagePath: TEdit;
    btnBrowseImage: TButton;
    btnFlashPartition: TButton;
    btnErasePartition: TButton;
    btnRebootSystem: TButton;

    pnlProgressCard: TPanel;
    lblProgressHeader: TLabel;
    pbProgress: TProgressBar;
    lblProgressStatus: TLabel;

    dlgOpenImage: TOpenDialog;

    procedure btnBrowseImageClick(Sender: TObject);
    procedure btnFlashPartitionClick(Sender: TObject);
    procedure btnErasePartitionClick(Sender: TObject);
    procedure btnRebootSystemClick(Sender: TObject);
    procedure btnBrowseRomClick(Sender: TObject);
    procedure btnFlashXiaomiRomClick(Sender: TObject);
  private
    FService: TGWTCommandService;
    FDevicePathFunc: TDevicePathGetter;
    function GetDevicePath: string;
    function ValidateDevice: Boolean;
    procedure HandleProgress(ACurrent, ATotal: Int64);
  public
    procedure BindService(AService: TGWTCommandService; ADevicePathFunc: TDevicePathGetter);
  end;

implementation

{$R *.dfm}

procedure TFrameFastbootFlash.BindService(AService: TGWTCommandService;
  ADevicePathFunc: TDevicePathGetter);
begin
  FService := AService;
  FDevicePathFunc := ADevicePathFunc;
end;

function TFrameFastbootFlash.GetDevicePath: string;
begin
  Result := '';
  if Assigned(FDevicePathFunc) then
    Result := FDevicePathFunc();
end;

function TFrameFastbootFlash.ValidateDevice: Boolean;
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

procedure TFrameFastbootFlash.btnBrowseImageClick(Sender: TObject);
begin
  if dlgOpenImage.Execute then
    edtImagePath.Text := dlgOpenImage.FileName;
end;

procedure TFrameFastbootFlash.btnBrowseRomClick(Sender: TObject);
var
  ChosenDir: string;
begin
  ChosenDir := edtRomPath.Text;
  if SelectDirectory('Select Xiaomi Fastboot ROM Directory', '', ChosenDir) then
    edtRomPath.Text := ChosenDir;
end;

procedure TFrameFastbootFlash.HandleProgress(ACurrent, ATotal: Int64);
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
      lblProgressStatus.Caption := Format('Transferred: %d KB / %d KB (%d%%)',
        [ACurrent div 1024, ATotal div 1024, Pct]);
    end);
end;

procedure TFrameFastbootFlash.btnFlashPartitionClick(Sender: TObject);
var
  Part, ImgPath: string;
begin
  if not ValidateDevice then Exit;
  Part := Trim(cbPartition.Text);
  ImgPath := Trim(edtImagePath.Text);

  if Part = '' then
  begin
    MessageDlg('Please select or enter a target partition name.', mtWarning, [mbOK], 0);
    cbPartition.SetFocus;
    Exit;
  end;

  if (ImgPath = '') or not FileExists(ImgPath) then
  begin
    MessageDlg('Please select a valid image file (*.img, *.bin) to flash.', mtWarning, [mbOK], 0);
    edtImagePath.SetFocus;
    Exit;
  end;

  pbProgress.Position := 0;
  lblProgressStatus.Caption := Format('Flashing %s partition...', [Part]);
  FService.FastbootFlashPartition(GetDevicePath, Part, ImgPath, HandleProgress);
end;

procedure TFrameFastbootFlash.btnFlashXiaomiRomClick(Sender: TObject);
var
  RomDir: string;
begin
  if not ValidateDevice then Exit;
  RomDir := Trim(edtRomPath.Text);
  if (RomDir = '') or not TDirectory.Exists(RomDir) then
  begin
    MessageDlg('Please select a valid Xiaomi Fastboot ROM folder containing images.', mtWarning, [mbOK], 0);
    Exit;
  end;

  pbProgress.Position := 0;
  lblProgressStatus.Caption := 'Starting Xiaomi Fastboot ROM Flash...';
  FService.XiaomiFastbootFlashRom(GetDevicePath, RomDir, HandleProgress);
end;

procedure TFrameFastbootFlash.btnErasePartitionClick(Sender: TObject);
var
  Part: string;
begin
  if not ValidateDevice then Exit;
  Part := Trim(cbPartition.Text);
  if Part = '' then
  begin
    MessageDlg('Please select or enter a partition name to erase.', mtWarning, [mbOK], 0);
    Exit;
  end;

  if MessageDlg(Format('Are you sure you want to erase the "%s" partition?', [Part]),
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    FService.FastbootErasePartition(GetDevicePath, Part);
  end;
end;

procedure TFrameFastbootFlash.btnRebootSystemClick(Sender: TObject);
begin
  if ValidateDevice then
    FService.FastbootReboot(GetDevicePath, '');
end;

end.
