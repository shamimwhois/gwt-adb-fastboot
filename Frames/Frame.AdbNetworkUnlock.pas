unit Frame.AdbNetworkUnlock;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.UITypes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls,
  GWT.Types, GWT.CommandService;

type
  TDeviceGetter = reference to function: TUsbDeviceInfo;

  TFrameAdbNetworkUnlock = class(TFrame)
    sbContainer: TScrollBox;

    // Brand & Model Selection Bar
    pnlBrandModelBar: TPanel;
    lblBrand: TLabel;
    lblModel: TLabel;
    lblMethod: TLabel;
    cbBrand: TComboBox;
    cbModel: TComboBox;
    cbMethod: TComboBox;

    // Card 1: IMEI Repair
    pnlImeiCard: TPanel;
    lblImeiHeader: TLabel;
    lblImeiSub: TLabel;
    lblImei1: TLabel;
    lblImei1Status: TLabel;
    lblImei2: TLabel;
    lblImei2Status: TLabel;
    edtImei1: TEdit;
    edtImei2: TEdit;
    gpImeiButtons: TGridPanel;
    btnReadImei: TButton;
    btnCalcLuhn: TButton;
    btnGenTestImei: TButton;
    btnWriteImei: TButton;

    // Card 2: Network / SIM Unlock
    pnlUnlockCard: TPanel;
    lblUnlockHeader: TLabel;
    lblUnlockSub: TLabel;
    gpUnlockButtons: TGridPanel;
    btnCheckSimlock: TButton;
    btnDirectUnlock: TButton;
    btnRestoreLock: TButton;
    btnRepairBaseband: TButton;

    // Card 3: EFS & NVRAM Security
    pnlSecurityCard: TPanel;
    lblSecurityHeader: TLabel;
    lblSecuritySub: TLabel;
    gpSecurityButtons: TGridPanel;
    btnBackupSecurity: TButton;
    btnRestoreSecurity: TButton;
    btnRestartRil: TButton;

    // Card 4: Diag Port
    pnlDiagCard: TPanel;
    lblDiagHeader: TLabel;
    lblDiagSub: TLabel;
    gpDiagButtons: TGridPanel;
    btnEnableDiag: TButton;
    btnOpenSecretDialer: TButton;

    procedure cbBrandChange(Sender: TObject);
    procedure edtImei1Change(Sender: TObject);
    procedure edtImei2Change(Sender: TObject);

    procedure btnReadImeiClick(Sender: TObject);
    procedure btnCalcLuhnClick(Sender: TObject);
    procedure btnGenTestImeiClick(Sender: TObject);
    procedure btnWriteImeiClick(Sender: TObject);

    procedure btnCheckSimlockClick(Sender: TObject);
    procedure btnDirectUnlockClick(Sender: TObject);
    procedure btnRestoreLockClick(Sender: TObject);
    procedure btnRepairBasebandClick(Sender: TObject);

    procedure btnBackupSecurityClick(Sender: TObject);
    procedure btnRestoreSecurityClick(Sender: TObject);
    procedure btnRestartRilClick(Sender: TObject);

    procedure btnEnableDiagClick(Sender: TObject);
    procedure btnOpenSecretDialerClick(Sender: TObject);

  private
    FService: TGWTCommandService;
    FDeviceFunc: TDeviceGetter;
    FOnModeSwitch: TDeviceModeDetected;
    function GetDevice: TUsbDeviceInfo;
    function ValidateDevice: Boolean;
    function GetSelectedBrand: TBrandCategory;
    procedure UpdateImeiStatus(AEdit: TEdit; AStatusLabel: TLabel);
  public
    procedure BindService(AService: TGWTCommandService; ADeviceFunc: TDeviceGetter;
      AOnModeSwitch: TDeviceModeDetected = nil);
  end;

implementation

{$R *.dfm}

procedure TFrameAdbNetworkUnlock.BindService(AService: TGWTCommandService;
  ADeviceFunc: TDeviceGetter; AOnModeSwitch: TDeviceModeDetected);
begin
  FService := AService;
  FDeviceFunc := ADeviceFunc;
  FOnModeSwitch := AOnModeSwitch;
  cbBrandChange(Self);
end;

function TFrameAdbNetworkUnlock.GetDevice: TUsbDeviceInfo;
begin
  Result := Default(TUsbDeviceInfo);
  if Assigned(FDeviceFunc) then
    Result := FDeviceFunc();
end;

function TFrameAdbNetworkUnlock.ValidateDevice: Boolean;
var
  Dev: TUsbDeviceInfo;
begin
  Result := False;
  if not Assigned(FService) then Exit;
  Dev := GetDevice;
  if (Dev.DevicePath = '') and (Dev.Serial = '') then
  begin
    MessageDlg('No active Android ADB device detected!' + sLineBreak +
      'Please connect phone via USB, enable USB Debugging, and authorize PC.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  Result := True;
end;

function TFrameAdbNetworkUnlock.GetSelectedBrand: TBrandCategory;
begin
  case cbBrand.ItemIndex of
    1: Result := bcSamsung;
    2: Result := bcXiaomi;
    3: Result := bcVivo;
    4: Result := bcHuawei;
    5: Result := bcOppoRealme;
    6: Result := bcTranssion;
    7: Result := bcMtkGeneric;
    8: Result := bcQcomGeneric;
    9: Result := bcUnisocGeneric;
  else
    Result := bcUniversal;
  end;
end;

procedure TFrameAdbNetworkUnlock.cbBrandChange(Sender: TObject);
begin
  cbModel.Items.BeginUpdate;
  try
    cbModel.Items.Clear;
    cbModel.Items.Add('[Auto-Detect / Universal]');

    case GetSelectedBrand of
      bcSamsung:
        begin
          cbModel.Items.Add('Galaxy A Series (A03, A12, A14, A23, A34, A54)');
          cbModel.Items.Add('Galaxy M Series (M12, M14, M33, M53)');
          cbModel.Items.Add('Galaxy S Series (S20, S21, S22, S23, S24)');
          cbModel.Items.Add('Galaxy Note / Z Fold / Z Flip Series');
          cbModel.Items.Add('Samsung Exynos Platform (Universal)');
          cbModel.Items.Add('Samsung Qualcomm Platform (Universal)');
        end;

      bcXiaomi:
        begin
          cbModel.Items.Add('Redmi 9 / 9A / 9C / 10 / 10C / 12 / 13');
          cbModel.Items.Add('Redmi Note 10 / 11 / 12 / 13 (4G / 5G / Pro)');
          cbModel.Items.Add('POCO X3 / X4 / X5 / X6 / M4 / M5 / F4 / F5');
          cbModel.Items.Add('Xiaomi 11 / 12 / 13 / 14 Series');
          cbModel.Items.Add('Xiaomi MediaTek Dimensity / Helio');
          cbModel.Items.Add('Xiaomi Qualcomm Snapdragon');
        end;

      bcVivo:
        begin
          cbModel.Items.Add('Vivo Y Series (Y02, Y12, Y16, Y20, Y22, Y36, Y100)');
          cbModel.Items.Add('Vivo V Series (V20, V21, V23, V27, V29, V30)');
          cbModel.Items.Add('Vivo T / iQOO Series (Z6, Z7, Neo, Neo7, 9, 11)');
          cbModel.Items.Add('Vivo MTK (Direct / Meta)');
          cbModel.Items.Add('Vivo Qualcomm (Diag / 9008)');
        end;

      bcHuawei:
        begin
          cbModel.Items.Add('Huawei Y5 / Y6 / Y7 / Y9 Series');
          cbModel.Items.Add('Huawei Nova 7 / 8 / 9 / 10 / 11 Series');
          cbModel.Items.Add('Huawei P30 / P40 / P50 / P60 / Mate 30 / 40 / 50');
          cbModel.Items.Add('Honor X7 / X8 / X9 / Magic Series');
          cbModel.Items.Add('Huawei HiSilicon Kirin Platform');
        end;

      bcOppoRealme:
        begin
          cbModel.Items.Add('Oppo A15 / A16 / A17 / A53 / A54 / A57 / A78');
          cbModel.Items.Add('Oppo Reno 6 / 7 / 8 / 10 / 11 Series');
          cbModel.Items.Add('Realme C11 / C21 / C33 / C53 / C55 / C67');
          cbModel.Items.Add('Realme 8 / 9 / 10 / 11 / 12 / GT Series');
          cbModel.Items.Add('OnePlus Nord / 8 / 9 / 10 / 11 / 12 Series');
        end;

      bcTranssion:
        begin
          cbModel.Items.Add('Tecno Spark 6 / 7 / 8 / 9 / 10 / 20 Series');
          cbModel.Items.Add('Tecno Camon 17 / 18 / 19 / 20 / 30 Series');
          cbModel.Items.Add('Tecno Pova 2 / 3 / 4 / 5 / 6 / Neo Series');
          cbModel.Items.Add('Tecno CM6 / MT6789 (Connected Device)');
          cbModel.Items.Add('Infinix Hot 10 / 11 / 12 / 20 / 30 / 40 Series');
          cbModel.Items.Add('Infinix Note 10 / 11 / 12 / 30 / 40 Series');
          cbModel.Items.Add('Infinix Zero 5G / Ultra / X Pro Series');
          cbModel.Items.Add('Itel A / P / S Series (A60, P40, S23)');
        end;

      bcMtkGeneric:
        begin
          cbModel.Items.Add('MT6580 / MT6582 / MT6592 (Legacy 32-bit)');
          cbModel.Items.Add('MT6735 / MT6737 / MT6739 / MT6753');
          cbModel.Items.Add('MT6761 / MT6762 / MT6765 (Helio A22 / P22)');
          cbModel.Items.Add('MT6768 / MT6769 (Helio G70 / G80 / G85 / G88)');
          cbModel.Items.Add('MT6785 / MT6789 (Helio G90 / G95 / G96 / G99)');
          cbModel.Items.Add('MT6833 / MT6877 / MT6893 (Dimensity 700 / 900 / 1200)');
          cbModel.Items.Add('MT6983 / MT6985 (Dimensity 9000 / 9200)');
        end;

      bcQcomGeneric:
        begin
          cbModel.Items.Add('Snapdragon 400 / 410 / 425 / 439 / 450 / 460 / 4 Gen 1');
          cbModel.Items.Add('Snapdragon 625 / 636 / 660 / 665 / 675 / 680 / 695');
          cbModel.Items.Add('Snapdragon 710 / 720G / 730G / 750G / 778G / 7+ Gen 2');
          cbModel.Items.Add('Snapdragon 845 / 855 / 865 / 870 / 888 / 8 Gen 1/2/3');
        end;

      bcUnisocGeneric:
        begin
          cbModel.Items.Add('SC7731E / SC9832E (3G / Entry 4G)');
          cbModel.Items.Add('SC9863A (Octa-core 1.6GHz)');
          cbModel.Items.Add('Tiger T310 / T606 / T610 / T612 / T616');
          cbModel.Items.Add('Tiger T618 / T700 / T820 (5G Platform)');
        end;
    end;

    cbModel.ItemIndex := 0;
  finally
    cbModel.Items.EndUpdate;
  end;
end;

procedure TFrameAdbNetworkUnlock.UpdateImeiStatus(AEdit: TEdit; AStatusLabel: TLabel);
var
  CleanText: string;
  I: Integer;
begin
  CleanText := '';
  for I := 1 to Length(AEdit.Text) do
    if (AEdit.Text[I] >= '0') and (AEdit.Text[I] <= '9') then
      CleanText := CleanText + AEdit.Text[I];

  if CleanText = '' then
  begin
    AStatusLabel.Caption := '[Empty]';
    AStatusLabel.Font.Color := CLR_TEXT_MUTED;
  end
  else if Length(CleanText) < 14 then
  begin
    AStatusLabel.Caption := Format('[%d/15 digits]', [Length(CleanText)]);
    AStatusLabel.Font.Color := CLR_LOG_WARN;
  end
  else if Length(CleanText) = 14 then
  begin
    AStatusLabel.Caption := Format('[14d + CD: %d]', [CalculateLuhnCheckDigit(CleanText)]);
    AStatusLabel.Font.Color := CLR_ACCENT_CYAN;
  end
  else if Length(CleanText) = 15 then
  begin
    if IsValidImei(CleanText) then
    begin
      AStatusLabel.Caption := '[Luhn: VALID]';
      AStatusLabel.Font.Color := CLR_LOG_SUCCESS;
    end
    else
    begin
      AStatusLabel.Caption := '[Luhn: INVALID]';
      AStatusLabel.Font.Color := CLR_LOG_ERROR;
    end;
  end
  else
  begin
    AStatusLabel.Caption := '[Exceeds 15]';
    AStatusLabel.Font.Color := CLR_LOG_ERROR;
  end;
end;

procedure TFrameAdbNetworkUnlock.edtImei1Change(Sender: TObject);
begin
  UpdateImeiStatus(edtImei1, lblImei1Status);
end;

procedure TFrameAdbNetworkUnlock.edtImei2Change(Sender: TObject);
begin
  UpdateImeiStatus(edtImei2, lblImei2Status);
end;

procedure TFrameAdbNetworkUnlock.btnReadImeiClick(Sender: TObject);
begin
  if not ValidateDevice then Exit;
  FService.AdbReadImei(GetDevice,
    procedure(AImei1, AImei2: string)
    begin
      if AImei1 <> '' then edtImei1.Text := AImei1;
      if AImei2 <> '' then edtImei2.Text := AImei2;
    end);
end;

procedure TFrameAdbNetworkUnlock.btnCalcLuhnClick(Sender: TObject);
var
  T1, T2: string;
begin
  T1 := Trim(edtImei1.Text);
  if Length(T1) >= 14 then
  begin
    T1 := Copy(T1, 1, 14);
    edtImei1.Text := T1 + IntToStr(CalculateLuhnCheckDigit(T1));
  end;

  T2 := Trim(edtImei2.Text);
  if Length(T2) >= 14 then
  begin
    T2 := Copy(T2, 1, 14);
    edtImei2.Text := T2 + IntToStr(CalculateLuhnCheckDigit(T2));
  end;
end;

procedure TFrameAdbNetworkUnlock.btnGenTestImeiClick(Sender: TObject);
var
  Base14: string;
  I: Integer;
begin
  // Generate valid test TAC 35894109 (TECNO / Generic 4G) + 6 random digits + Luhn CD
  Randomize;
  Base14 := '35894109';
  for I := 1 to 6 do
    Base14 := Base14 + IntToStr(Random(10));
  edtImei1.Text := Base14 + IntToStr(CalculateLuhnCheckDigit(Base14));

  Base14 := '35894109';
  for I := 1 to 6 do
    Base14 := Base14 + IntToStr(Random(10));
  edtImei2.Text := Base14 + IntToStr(CalculateLuhnCheckDigit(Base14));
end;

procedure TFrameAdbNetworkUnlock.btnWriteImeiClick(Sender: TObject);
var
  I1, I2: string;
begin
  if not ValidateDevice then Exit;
  I1 := Trim(edtImei1.Text);
  I2 := Trim(edtImei2.Text);

  if (I1 = '') and (I2 = '') then
  begin
    MessageDlg('Please input at least one IMEI (IMEI 1 or IMEI 2) to repair.',
      mtError, [mbOK], 0);
    Exit;
  end;

  if MessageDlg(Format('ATTENTION / SAFETY WARNING:' + sLineBreak +
    'You are about to write/repair IMEI parameters on: %s' + sLineBreak +
    'Brand: %s | Model: %s' + sLineBreak +
    'IMEI 1: %s' + sLineBreak +
    'IMEI 2: %s' + sLineBreak + sLineBreak +
    'An automatic backup of your EFS/NVRAM partitions will be executed.' + sLineBreak +
    'Do you want to proceed?',
    [GetDevice.FriendlyName, cbBrand.Text, cbModel.Text, I1, I2]),
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  // Auto-backup first for safety
  FService.AdbBackupSecurity(GetDevice);
  // Dispatch write command
  FService.AdbWriteImei(GetDevice, GetSelectedBrand, I1, I2);
end;

procedure TFrameAdbNetworkUnlock.btnCheckSimlockClick(Sender: TObject);
begin
  if not ValidateDevice then Exit;
  FService.AdbCheckSimlock(GetDevice);
end;

procedure TFrameAdbNetworkUnlock.btnDirectUnlockClick(Sender: TObject);
begin
  if not ValidateDevice then Exit;
  if MessageDlg(Format('Direct Network / SIM Unlock:' + sLineBreak +
    'Device: %s' + sLineBreak +
    'Brand: %s' + sLineBreak + sLineBreak +
    'This will send de-personalization AT sequences and remove carrier lock flags.' + sLineBreak +
    'Continue?', [GetDevice.FriendlyName, cbBrand.Text]),
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    FService.AdbNetworkUnlock(GetDevice, GetSelectedBrand);
  end;
end;

procedure TFrameAdbNetworkUnlock.btnRestoreLockClick(Sender: TObject);
begin
  if not ValidateDevice then Exit;
  FService.AdbRestoreCarrierLock(GetDevice, GetSelectedBrand);
end;

procedure TFrameAdbNetworkUnlock.btnRepairBasebandClick(Sender: TObject);
begin
  if not ValidateDevice then Exit;
  FService.AdbRepairBaseband(GetDevice);
end;

procedure TFrameAdbNetworkUnlock.btnBackupSecurityClick(Sender: TObject);
begin
  if not ValidateDevice then Exit;
  FService.AdbBackupSecurity(GetDevice);
end;

procedure TFrameAdbNetworkUnlock.btnRestoreSecurityClick(Sender: TObject);
begin
  if not ValidateDevice then Exit;
  FService.AdbRestoreSecurity(GetDevice, '/sdcard/GWT_nvram.img');
end;

procedure TFrameAdbNetworkUnlock.btnRestartRilClick(Sender: TObject);
begin
  if not ValidateDevice then Exit;
  FService.AdbRestartModemRil(GetDevice);
end;

procedure TFrameAdbNetworkUnlock.btnEnableDiagClick(Sender: TObject);
begin
  if not ValidateDevice then Exit;
  FService.AdbEnableDiagPort(GetDevice, GetSelectedBrand);
end;

procedure TFrameAdbNetworkUnlock.btnOpenSecretDialerClick(Sender: TObject);
begin
  if not ValidateDevice then Exit;
  FService.AdbEnableDiagPort(GetDevice, GetSelectedBrand);
end;

end.
