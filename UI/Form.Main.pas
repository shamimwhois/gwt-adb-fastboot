unit Form.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls,
  GWT.Types, GWT.CommandService,
  Frame.AdbService,
  Frame.FastbootService, Frame.FastbootFlash,
  Frame.RecoveryService, Frame.RecoveryFlash;

const
  DBT_DEVICEARRIVAL           = $8000;
  DBT_DEVICEREMOVECOMPLETE    = $8004;
  DBT_DEVTYP_DEVICEINTERFACE  = $00000005;
  DEVICE_NOTIFY_ALL_INTERFACE_CLASSES = 4;

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
    btnScanDevices: TButton;
    pnlLogBox: TPanel;
    lblLogTitle: TLabel;
    redLogs: TRichEdit;
    pnlWorkspace: TPanel;
    gpModeTabs: TGridPanel;
    btnModeADB: TButton;
    btnModeFastboot: TButton;
    btnModeRecovery: TButton;
    pnlSubTabs: TPanel;
    btnSubService: TButton;
    btnSubFlash: TButton;
    pnlFrameHost: TPanel;
    tmrAutoDetect: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ModeTabClick(Sender: TObject);
    procedure SubTabClick(Sender: TObject);
    procedure btnScanDevicesClick(Sender: TObject);
    procedure tmrAutoDetectTimer(Sender: TObject);
  private
    FCommandService: TGWTCommandService;
    FActiveMode: TDeviceMode;
    FActiveSubMode: TSubMode;
    FCurrentFrame: TFrame;
    FUsbNotifyHandle: HDEVNOTIFY;
    FDiscoveredDevices: TArray<TUsbDeviceInfo>;
    FLastDeviceCount: Integer;

    procedure AppendLog(const AMsg: string; ALevel: TLogLevel);
    procedure UpdateNavigationUI;
    procedure LoadActiveFrame;
    procedure RefreshUsbDevicesAsync(AAutoSwitchMode: Boolean = False);
    procedure RegisterUsbNotifications;
    procedure UnregisterUsbNotifications;
    function GetSelectedDevicePath: string;
    function GetSelectedDeviceInfo: TUsbDeviceInfo;
    procedure HandleModeSwitched(AMode: TDeviceMode);
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
  FLastDeviceCount := -1;

  // Default state: start in ADB mode
  FActiveMode := dmADB;
  FActiveSubMode := smService;

  RegisterUsbNotifications;
  UpdateNavigationUI;
  LoadActiveFrame;

  AppendLog('====================================================', llInfo);
  AppendLog('GWT ADB & Fastboot Tool v1.0 Initialized', llSuccess);
  AppendLog('Real-time USB & Socket Auto-Detection Engine Active', llSuccess);
  AppendLog('====================================================', llInfo);

  RefreshUsbDevicesAsync(True);
  tmrAutoDetect.Interval := 2000;
  tmrAutoDetect.Enabled := True;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  tmrAutoDetect.Enabled := False;
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

  // Use DEVICE_NOTIFY_ALL_INTERFACE_CLASSES to catch all USB arrivals/removals
  FUsbNotifyHandle := RegisterDeviceNotification(Handle, @Filter,
    DEVICE_NOTIFY_WINDOW_HANDLE or DEVICE_NOTIFY_ALL_INTERFACE_CLASSES);
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
    RefreshUsbDevicesAsync(True);
end;

procedure TFormMain.tmrAutoDetectTimer(Sender: TObject);
begin
  // Background polling to catch ADB state changes or USB drops
  RefreshUsbDevicesAsync(False);
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

function TFormMain.GetSelectedDeviceInfo: TUsbDeviceInfo;
var
  Idx: Integer;
begin
  Result := Default(TUsbDeviceInfo);
  Idx := cbUSBDevices.ItemIndex;
  if (Idx >= 0) and (Idx < Length(FDiscoveredDevices)) then
    Result := FDiscoveredDevices[Idx];
end;

procedure TFormMain.HandleModeSwitched(AMode: TDeviceMode);
begin
  FActiveMode := AMode;
  UpdateNavigationUI;
  LoadActiveFrame;
  RefreshUsbDevicesAsync(True);
end;

procedure TFormMain.btnScanDevicesClick(Sender: TObject);
begin
  AppendLog('Scanning USB and ADB sockets...', llInfo);
  RefreshUsbDevicesAsync(True);
end;

procedure TFormMain.RefreshUsbDevicesAsync(AAutoSwitchMode: Boolean);
begin
  TThread.CreateAnonymousThread(
    procedure
    var
      Devs: TArray<TUsbDeviceInfo>;
    begin
      Devs := FCommandService.ScanConnectedInterfaces;

      TThread.Queue(nil,
        procedure
        var
          I: Integer;
          DevChanged: Boolean;
          TopMode: string;
        begin
          if (csDestroying in ComponentState) or Application.Terminated then
            Exit;

          DevChanged := (Integer(Length(Devs)) <> FLastDeviceCount);
          FLastDeviceCount := Integer(Length(Devs));
          FDiscoveredDevices := Devs;

          cbUSBDevices.Items.BeginUpdate;
          try
            cbUSBDevices.Items.Clear;
            if Length(Devs) = 0 then
            begin
              cbUSBDevices.Items.Add('[-] Waiting for device (ADB / Fastboot)...');
              lblConnStatus.Caption := #$25CF + ' WAITING FOR DEVICE';
              lblConnStatus.Font.Color := CLR_LOG_WARN;

              if AAutoSwitchMode then
              begin
                AppendLog('No active Android device detected on USB or Socket.', llWarning);
                AppendLog('Please check:', llInfo);
                AppendLog(' 1. Connect a USB Data Cable firmly to phone and PC (rear motherboard port).', llInfo);
                AppendLog(' 2. Unlock phone screen and select "File Transfer (MTP)".', llInfo);
                AppendLog(' 3. In Developer Options: Toggle USB Debugging ON.', llInfo);
                AppendLog(' 4. Look at phone screen for "Allow USB debugging?" and tap ALLOW.', llInfo);
                AppendLog(' 5. If phone is powered off, hold Vol Down + Power to enter Fastboot.', llInfo);
              end;
            end
            else
            begin
              for I := 0 to Integer(High(Devs)) do
                cbUSBDevices.Items.Add(Devs[I].FriendlyName);

              TopMode := Devs[0].InterfaceType;
              lblConnStatus.Caption := Format('%s ONLINE (%s)', [#$25CF, TopMode]);
              lblConnStatus.Font.Color := CLR_LOG_SUCCESS;

              if DevChanged or AAutoSwitchMode then
                AppendLog(Format('Device Detected: %s', [Devs[0].FriendlyName]), llSuccess);

              if Pos('UNAUTHORIZED', UpperCase(Devs[0].FriendlyName)) > 0 then
              begin
                AppendLog('ACTION REQUIRED: Phone is in UNAUTHORIZED state!', llWarning);
                AppendLog('Please unlock your phone screen and tap "ALLOW" on the RSA authorization popup.', llWarning);
              end;

              // Auto-switch UI tab if mode changed (e.g. rebooted to Fastboot)
              if AAutoSwitchMode and (TopMode = 'FASTBOOT') and (FActiveMode <> dmFastboot) then
              begin
                AppendLog('Detected Fastboot mode! Switching workspace to FASTBOOT...', llInfo);
                FActiveMode := dmFastboot;
                UpdateNavigationUI;
                LoadActiveFrame;
                FCommandService.FastbootReadInfo(Devs[0].DevicePath);
              end;
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
  btnModeADB.Font.Style := [];
  btnModeFastboot.Font.Style := [];
  btnModeRecovery.Font.Style := [];
  case FActiveMode of
    dmADB:      btnModeADB.Font.Style := [fsBold, fsUnderline];
    dmFastboot: btnModeFastboot.Font.Style := [fsBold, fsUnderline];
    dmRecovery: btnModeRecovery.Font.Style := [fsBold, fsUnderline];
  end;

  // In ADB mode, NO service or flash sub-tabs!
  // Fastboot and Recovery have SERVICE and FLASH sub-tabs
  pnlSubTabs.Visible := (FActiveMode in [dmFastboot, dmRecovery]);

  btnSubService.Font.Style := [];
  btnSubFlash.Font.Style := [];
  if FActiveSubMode = smService then
    btnSubService.Font.Style := [fsBold, fsUnderline]
  else
    btnSubFlash.Font.Style := [fsBold, fsUnderline];
end;

procedure TFormMain.LoadActiveFrame;
var
  AdbSvc: TFrameAdbService;
  FbSvc: TFrameFastbootService;
  FbFl: TFrameFastbootFlash;
  RecSvc: TFrameRecoveryService;
  RecFl: TFrameRecoveryFlash;
begin
  FreeAndNil(FCurrentFrame);

  case FActiveMode of
    dmADB:
      begin
        // Single direct ADB workspace with prominent Read Info button
        AdbSvc := TFrameAdbService.Create(Self);
        AdbSvc.Parent := pnlFrameHost;
        AdbSvc.Align := alClient;
        AdbSvc.BindService(FCommandService, GetSelectedDeviceInfo, HandleModeSwitched);
        FCurrentFrame := AdbSvc;
      end;

    dmFastboot:
      begin
        if FActiveSubMode = smService then
        begin
          FbSvc := TFrameFastbootService.Create(Self);
          FbSvc.Parent := pnlFrameHost;
          FbSvc.Align := alClient;
          FbSvc.BindService(FCommandService, GetSelectedDevicePath);
          FCurrentFrame := FbSvc;
        end
        else
        begin
          FbFl := TFrameFastbootFlash.Create(Self);
          FbFl.Parent := pnlFrameHost;
          FbFl.Align := alClient;
          FbFl.BindService(FCommandService, GetSelectedDevicePath);
          FCurrentFrame := FbFl;
        end;
      end;

    dmRecovery:
      begin
        if FActiveSubMode = smService then
        begin
          RecSvc := TFrameRecoveryService.Create(Self);
          RecSvc.Parent := pnlFrameHost;
          RecSvc.Align := alClient;
          RecSvc.BindService(FCommandService, GetSelectedDeviceInfo);
          FCurrentFrame := RecSvc;
        end
        else
        begin
          RecFl := TFrameRecoveryFlash.Create(Self);
          RecFl.Parent := pnlFrameHost;
          RecFl.Align := alClient;
          RecFl.BindService(FCommandService, GetSelectedDeviceInfo);
          FCurrentFrame := RecFl;
        end;
      end;
  end;
end;

end.
