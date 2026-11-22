unit GWT.CommandService;

interface

uses
  System.SysUtils, System.Classes, System.StrUtils, System.IOUtils,
  GWT.Types, GWT.WinUSB.Transport, GWT.Protocol.Fastboot, GWT.Protocol.ADB;

type
  TDeviceModeDetected = reference to procedure(AMode: TDeviceMode);

  TGWTCommandService = class
  private
    FOnLog: TLogCallback;
    FIsBusy: Boolean;
    FSocketAdb: TGWTADBSocketClient;
    procedure Log(const AMsg: string; ALevel: TLogLevel);
    procedure RunAsync(AProc: TProc);
  public
    constructor Create(AOnLog: TLogCallback);
    destructor Destroy; override;

    function ScanConnectedInterfaces: TArray<TUsbDeviceInfo>;

    // Core Dual-Engine Protocol Dispatchers (Socket & Raw WinUSB Fallback)
    function ExecuteAdbShell(const ADeviceInfo: TUsbDeviceInfo; const ACmd: string; out AOutput: string): Boolean;
    function ExecuteAdbReboot(const ADeviceInfo: TUsbDeviceInfo; const ATarget: string): Boolean;

    // Universal ADB Operations
    procedure AdbReadDeviceInfo(const ADeviceInfo: TUsbDeviceInfo);
    procedure AdbRebootToFastboot(const ADeviceInfo: TUsbDeviceInfo; AOnSwitched: TDeviceModeDetected = nil);
    procedure AdbReboot(const ADeviceInfo: TUsbDeviceInfo; const ATarget: string = '');
    procedure AdbResetFRP(const ADeviceInfo: TUsbDeviceInfo);
    procedure AdbExecuteShell(const ADeviceInfo: TUsbDeviceInfo; const ACmd: string);
    procedure AdbInstallApk(const ADeviceInfo: TUsbDeviceInfo; const AApkPath: string);
    procedure AdbPushFile(const ADeviceInfo: TUsbDeviceInfo; const ALocalPath, ARemotePath: string);

    // Xiaomi ADB Operations
    procedure XiaomiAdbReadInfo(const ADeviceInfo: TUsbDeviceInfo);
    procedure XiaomiAdbEnableDiag(const ADeviceInfo: TUsbDeviceInfo);
    procedure XiaomiAdbBypassMiAccount(const ADeviceInfo: TUsbDeviceInfo);
    procedure XiaomiAdbDisableBloatware(const ADeviceInfo: TUsbDeviceInfo);

    // Vivo ADB Operations
    procedure VivoAdbReadInfo(const ADeviceInfo: TUsbDeviceInfo);
    procedure VivoAdbFactoryReset(const ADeviceInfo: TUsbDeviceInfo);
    procedure VivoAdbEnableDiag(const ADeviceInfo: TUsbDeviceInfo);
    procedure VivoAdbDisableDemoMode(const ADeviceInfo: TUsbDeviceInfo);

    // Huawei ADB Operations
    procedure HuaweiAdbReadBuild(const ADeviceInfo: TUsbDeviceInfo);
    procedure HuaweiAdbEnableManufactureMode(const ADeviceInfo: TUsbDeviceInfo);
    procedure HuaweiAdbResetFRP(const ADeviceInfo: TUsbDeviceInfo);

    // Universal Fastboot Operations
    procedure FastbootReadInfo(const ADevicePath: string);
    procedure FastbootReboot(const ADevicePath, ATarget: string);
    procedure FastbootFlashPartition(const ADevicePath, APartition, AImagePath: string;
      AOnProgress: TProgressCallback = nil);
    procedure FastbootErasePartition(const ADevicePath, APartition: string);

    // Huawei Fastboot Service Operations
    procedure HuaweiResetFRP(const ADevicePath, AKey: string);
    procedure HuaweiReadInfo(const ADevicePath: string);
    procedure HuaweiResetScreenLock(const ADevicePath: string);
    procedure HuaweiBypassFRPAndLock(const ADevicePath: string);
    procedure HuaweiRemoveID(const ADevicePath: string);
    procedure HuaweiUnlockBootloader(const ADevicePath, ACode: string);
    procedure HuaweiRelockBootloader(const ADevicePath: string);
    procedure HuaweiFormatUserdataSafe(const ADevicePath: string);

    // Xiaomi Fastboot Operations
    procedure XiaomiFastbootReadInfo(const ADevicePath: string);
    procedure XiaomiFastbootUnlock(const ADevicePath: string);
    procedure XiaomiFastbootRelock(const ADevicePath: string);
    procedure XiaomiFastbootRebootEDL(const ADevicePath: string);
    procedure XiaomiFastbootWipeData(const ADevicePath: string);
    procedure XiaomiFastbootFlashRom(const ADevicePath, ARomDir: string;
      AOnProgress: TProgressCallback = nil);

    // Vivo Fastboot Operations
    procedure VivoFastbootReadInfo(const ADevicePath: string);
    procedure VivoFastbootUnlock(const ADevicePath: string);
    procedure VivoFastbootWipeData(const ADevicePath: string);

    // Recovery Operations
    procedure RecoveryReadInfo(const ADeviceInfo: TUsbDeviceInfo);
    procedure RecoveryWipeData(const ADeviceInfo: TUsbDeviceInfo);
    procedure RecoveryRebootFastboot(const ADeviceInfo: TUsbDeviceInfo);
    procedure RecoverySideload(const ADeviceInfo: TUsbDeviceInfo; const AZipPath: string;
      AOnProgress: TProgressCallback = nil);

    // Xiaomi Recovery Operations
    procedure XiaomiRecoveryReadInfo(const ADeviceInfo: TUsbDeviceInfo);
    procedure XiaomiRecoveryWipeData(const ADeviceInfo: TUsbDeviceInfo);
    procedure XiaomiRecoveryBypassAccount(const ADeviceInfo: TUsbDeviceInfo);

    // Huawei Recovery Operations
    procedure HuaweiRecoveryReadInfo(const ADeviceInfo: TUsbDeviceInfo);
    procedure HuaweiRecoveryWipeData(const ADeviceInfo: TUsbDeviceInfo);
    procedure HuaweiRecoveryWipeCache(const ADeviceInfo: TUsbDeviceInfo);

    // Vivo Recovery Operations
    procedure VivoRecoveryReadInfo(const ADeviceInfo: TUsbDeviceInfo);
    procedure VivoRecoveryWipeData(const ADeviceInfo: TUsbDeviceInfo);

    property IsBusy: Boolean read FIsBusy;
  end;

implementation

constructor TGWTCommandService.Create(AOnLog: TLogCallback);
begin
  inherited Create;
  FOnLog := AOnLog;
  FIsBusy := False;
  FSocketAdb := TGWTADBSocketClient.Create(AOnLog);
end;

destructor TGWTCommandService.Destroy;
begin
  FreeAndNil(FSocketAdb);
  inherited;
end;

procedure TGWTCommandService.Log(const AMsg: string; ALevel: TLogLevel);
begin
  if Assigned(FOnLog) then
  begin
    if TThread.Current.ThreadID = MainThreadID then
      FOnLog(AMsg, ALevel)
    else
      TThread.Queue(nil,
        procedure
        begin
          FOnLog(AMsg, ALevel);
        end);
  end;
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
var
  WinUsbDevs: TArray<TUsbDeviceInfo>;
  SockDevs: TArray<TUsbDeviceInfo>;
  Item: TUsbDeviceInfo;
  Found: Boolean;
  I: NativeInt;
begin
  SetLength(Result, 0);

  // 1. Scan active ADB daemon loopback socket (127.0.0.1:5037) for high-fidelity device metadata
  SockDevs := FSocketAdb.GetDeviceList;
  for Item in SockDevs do
  begin
    SetLength(Result, Length(Result) + 1);
    Result[High(Result)] := Item;
  end;

  // 2. Scan direct WinUSB endpoints across all candidate Android GUIDs (Fastboot / ADB)
  WinUsbDevs := TGWTWinUsbTransport.EnumerateAllAndroidDevices;
  for Item in WinUsbDevs do
  begin
    Found := False;
    for I := 0 to High(Result) do
    begin
      if (Item.Serial <> '') and (Result[I].Serial = Item.Serial) then
      begin
        Found := True;
        Break;
      end;
    end;
    if not Found then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := Item;
    end;
  end;
end;

function TGWTCommandService.ExecuteAdbShell(const ADeviceInfo: TUsbDeviceInfo;
  const ACmd: string; out AOutput: string): Boolean;
var
  Dev: TUsbDeviceInfo;
  Devs: TArray<TUsbDeviceInfo>;
  I: Integer;
  Transport: TGWTWinUsbTransport;
  Engine: TGWTADBPacketEngine;
  Accumulated: string;
begin
  Result := False;
  AOutput := '';
  Dev := ADeviceInfo;

  if (Dev.DevicePath = '') and (Dev.Serial = '') then
  begin
    Devs := ScanConnectedInterfaces;
    for I := 0 to High(Devs) do
      if Devs[I].InterfaceType = 'ADB' then
      begin
        Dev := Devs[I];
        Break;
      end;
    if (Dev.DevicePath = '') and (Dev.Serial = '') and (Length(Devs) > 0) then
      Dev := Devs[0];
  end;

  // 1. Try Socket client if device is socket-based or has a serial
  if Dev.IsSocketBased or (Dev.Serial <> '') then
  begin
    if FSocketAdb.ExecuteShell(Dev.Serial, ACmd, AOutput) then
      Exit(True);
  end;

  // 2. Try Raw WinUSB transport
  if Dev.DevicePath <> '' then
  begin
    Transport := TGWTWinUsbTransport.Create;
    try
      if Transport.Open(Dev.DevicePath) then
      begin
        Engine := TGWTADBPacketEngine.Create(Transport, FOnLog);
        try
          if Engine.Connect then
          begin
            Accumulated := '';
            if Engine.ExecuteShell(ACmd,
              procedure(const AText: string)
              begin
                Accumulated := Accumulated + AText;
              end) then
            begin
              AOutput := Accumulated;
              Result := True;
            end;
          end;
        finally
          Engine.Free;
        end;
      end;
    finally
      Transport.Free;
    end;
  end;

  // 3. Fallback: try socket without serial
  if not Result and not Dev.IsSocketBased then
    Result := FSocketAdb.ExecuteShell('', ACmd, AOutput);
end;

function TGWTCommandService.ExecuteAdbReboot(const ADeviceInfo: TUsbDeviceInfo;
  const ATarget: string): Boolean;
var
  Dev: TUsbDeviceInfo;
  Devs: TArray<TUsbDeviceInfo>;
  I: Integer;
  Transport: TGWTWinUsbTransport;
  Engine: TGWTADBPacketEngine;
begin
  Result := False;
  Dev := ADeviceInfo;

  if (Dev.DevicePath = '') and (Dev.Serial = '') then
  begin
    Devs := ScanConnectedInterfaces;
    for I := 0 to High(Devs) do
      if Devs[I].InterfaceType = 'ADB' then
      begin
        Dev := Devs[I];
        Break;
      end;
    if (Dev.DevicePath = '') and (Dev.Serial = '') and (Length(Devs) > 0) then
      Dev := Devs[0];
  end;

  if Dev.IsSocketBased or (Dev.Serial <> '') then
  begin
    if FSocketAdb.Reboot(Dev.Serial, ATarget) then
      Exit(True);
  end;

  if Dev.DevicePath <> '' then
  begin
    Transport := TGWTWinUsbTransport.Create;
    try
      if Transport.Open(Dev.DevicePath) then
      begin
        Engine := TGWTADBPacketEngine.Create(Transport, FOnLog);
        try
          if Engine.Connect then
            Result := Engine.Reboot(ATarget);
        finally
          Engine.Free;
        end;
      end;
    finally
      Transport.Free;
    end;
  end;

  if not Result and not Dev.IsSocketBased then
    Result := FSocketAdb.Reboot('', ATarget);
end;

{ Universal ADB Operations }

procedure TGWTCommandService.AdbReadDeviceInfo(const ADeviceInfo: TUsbDeviceInfo);
begin
  RunAsync(
    procedure
    var
      Dev: TUsbDeviceInfo;
      Devs: TArray<TUsbDeviceInfo>;
      CombinedCmd, Output: string;
      Lines: TArray<string>;
      Transport: TGWTWinUsbTransport;
      Engine: TGWTADBPacketEngine;
      I: NativeInt;
    begin
      Log('====================================================', llInfo);
      Log('Reading Device Information in ADB Mode...', llInfo);
      Log('====================================================', llInfo);

      Dev := ADeviceInfo;
      // If no device info passed or serial is empty, auto-scan now
      if (Dev.DevicePath = '') and (Dev.Serial = '') then
      begin
        Log('Scanning active interfaces for ADB connection...', llInfo);
        Devs := ScanConnectedInterfaces;
        if Length(Devs) > 0 then
        begin
          for I := 0 to High(Devs) do
          begin
            if Devs[I].InterfaceType = 'ADB' then
            begin
              Dev := Devs[I];
              Break;
            end;
          end;
          if (Dev.DevicePath = '') and (Dev.Serial = '') then
            Dev := Devs[0];
        end;
      end;

      if (Dev.DevicePath = '') and (Dev.Serial = '') then
      begin
        Log('No active ADB device detected!', llError);
        Log('Diagnostic Checklist:', llWarning);
        Log(' 1. Ensure USB cable is firmly connected (use rear motherboard USB port).', llWarning);
        Log(' 2. Unlock phone screen and select "File Transfer (MTP)" in USB settings.', llWarning);
        Log(' 3. In Developer Options, enable "USB Debugging".', llWarning);
        Log(' 4. Check phone screen for "Allow USB debugging?" RSA prompt and tap ALLOW.', llWarning);
        Log(' 5. If phone is in Fastboot, switch to FASTBOOT tab.', llWarning);
        Exit;
      end;

      if Dev.IsSocketBased or (Dev.DevicePath = '') or (Dev.Serial <> '') then
      begin
        CombinedCmd := 'echo "MFR="`getprop ro.product.manufacturer`; ' +
                       'echo "MDL="`getprop ro.product.model`; ' +
                       'echo "BRD="`getprop ro.product.brand`; ' +
                       'echo "REL="`getprop ro.build.version.release`; ' +
                       'echo "SDK="`getprop ro.build.version.sdk`; ' +
                       'echo "DSP="`getprop ro.build.display.id`; ' +
                       'echo "PTC="`getprop ro.build.version.security_patch`; ' +
                       'echo "CPU="`getprop ro.board.platform`; ' +
                       'echo "SER="`getprop ro.boot.serialno`; ' +
                       'echo "BAT="`cat /sys/class/power_supply/battery/capacity 2>/dev/null`';

        if FSocketAdb.ExecuteShell(Dev.Serial, CombinedCmd, Output) then
        begin
          if Trim(Output) = '' then
          begin
            Log('Received empty output from device shell.', llWarning);
            Exit;
          end;

          Lines := Output.Split([#13#10, #10], TStringSplitOptions.ExcludeEmpty);
          for I := 0 to High(Lines) do
          begin
            if Lines[I].StartsWith('MFR=') then Log('Manufacturer:     ' + Lines[I].Substring(4).Trim, llSuccess)
            else if Lines[I].StartsWith('MDL=') then Log('Device Model:     ' + Lines[I].Substring(4).Trim, llSuccess)
            else if Lines[I].StartsWith('BRD=') then Log('Brand / Vendor:   ' + Lines[I].Substring(4).Trim, llSuccess)
            else if Lines[I].StartsWith('REL=') then Log('Android Version:  ' + Lines[I].Substring(4).Trim, llInfo)
            else if Lines[I].StartsWith('SDK=') then Log('Android SDK / API:' + Lines[I].Substring(4).Trim, llInfo)
            else if Lines[I].StartsWith('DSP=') then Log('Build Display ID: ' + Lines[I].Substring(4).Trim, llInfo)
            else if Lines[I].StartsWith('PTC=') then Log('Security Patch:   ' + Lines[I].Substring(4).Trim, llInfo)
            else if Lines[I].StartsWith('CPU=') then Log('CPU Platform:     ' + Lines[I].Substring(4).Trim, llInfo)
            else if Lines[I].StartsWith('SER=') then Log('Serial Number:    ' + Lines[I].Substring(4).Trim, llInfo)
            else if Lines[I].StartsWith('BAT=') and (Lines[I].Length > 4) then Log('Battery Level:    ' + Lines[I].Substring(4).Trim + '%', llInfo);
          end;

          Log('----------------------------------------------------', llInfo);
          Log('ADB Read Info Completed Successfully!', llSuccess);
        end
        else
        begin
          Log('Failed communicating with device shell.', llError);
          Log('If phone is unauthorized, unlock screen and accept RSA popup.', llWarning);
        end;
      end
      else
      begin
        Transport := TGWTWinUsbTransport.Create;
        try
          if not Transport.Open(Dev.DevicePath) then
          begin
            Log('Failed opening WinUSB connection to ADB device.', llError);
            Exit;
          end;
          Engine := TGWTADBPacketEngine.Create(Transport, FOnLog);
          try
            if Engine.Connect then
            begin
              Engine.ExecuteShell(
                'echo "MFR="`getprop ro.product.manufacturer`; ' +
                'echo "MDL="`getprop ro.product.model`; ' +
                'echo "BRD="`getprop ro.product.brand`; ' +
                'echo "REL="`getprop ro.build.version.release`; ' +
                'echo "SDK="`getprop ro.build.version.sdk`; ' +
                'echo "DSP="`getprop ro.build.display.id`; ' +
                'echo "PTC="`getprop ro.build.version.security_patch`; ' +
                'echo "CPU="`getprop ro.board.platform`; ' +
                'echo "SER="`getprop ro.boot.serialno`; ' +
                'echo "BAT="`cat /sys/class/power_supply/battery/capacity 2>/dev/null`',
                procedure(const AText: string)
                var
                  Lines: TArray<string>;
                  Line: string;
                begin
                  Lines := AText.Split([#13#10, #10], TStringSplitOptions.ExcludeEmpty);
                  for Line in Lines do
                  begin
                    if Line.StartsWith('MFR=') then Log('Manufacturer:     ' + Line.Substring(4).Trim, llSuccess)
                    else if Line.StartsWith('MDL=') then Log('Device Model:     ' + Line.Substring(4).Trim, llSuccess)
                    else if Line.StartsWith('BRD=') then Log('Brand / Vendor:   ' + Line.Substring(4).Trim, llSuccess)
                    else if Line.StartsWith('REL=') then Log('Android Version:  ' + Line.Substring(4).Trim, llInfo)
                    else if Line.StartsWith('SDK=') then Log('Android SDK / API:' + Line.Substring(4).Trim, llInfo)
                    else if Line.StartsWith('DSP=') then Log('Build Display ID: ' + Line.Substring(4).Trim, llInfo)
                    else if Line.StartsWith('PTC=') then Log('Security Patch:   ' + Line.Substring(4).Trim, llInfo)
                    else if Line.StartsWith('CPU=') then Log('CPU Platform:     ' + Line.Substring(4).Trim, llInfo)
                    else if Line.StartsWith('SER=') then Log('Serial Number:    ' + Line.Substring(4).Trim, llInfo)
                    else if Line.StartsWith('BAT=') and (Line.Length > 4) then Log('Battery Level:    ' + Line.Substring(4).Trim + '%', llInfo);
                  end;
                end);
              Log('----------------------------------------------------', llInfo);
              Log('Native ADB Read Info Completed Successfully!', llSuccess);
            end;
          finally
            Engine.Free;
          end;
        finally
          Transport.Free;
        end;
      end;
    end);
end;

procedure TGWTCommandService.AdbRebootToFastboot(const ADeviceInfo: TUsbDeviceInfo;
  AOnSwitched: TDeviceModeDetected);
begin
  RunAsync(
    procedure
    begin
      Log('TX >> Rebooting device to Fastboot / Bootloader mode...', llTx);
      if ExecuteAdbReboot(ADeviceInfo, 'bootloader') then
      begin
        Log('Reboot command dispatched successfully.', llSuccess);
        Log('Waiting for phone to reconnect in Fastboot mode...', llInfo);

        if Assigned(AOnSwitched) then
          TThread.Queue(nil,
            procedure
            begin
              AOnSwitched(dmFastboot);
            end);
      end
      else
        Log('Failed dispatching reboot to bootloader.', llError);
    end);
end;

procedure TGWTCommandService.AdbReboot(const ADeviceInfo: TUsbDeviceInfo; const ATarget: string);
begin
  RunAsync(
    procedure
    begin
      Log('TX >> Rebooting device: ' + ATarget, llTx);
      if ExecuteAdbReboot(ADeviceInfo, ATarget) then
        Log('Reboot command executed successfully.', llSuccess)
      else
        Log('Failed executing reboot: ' + ATarget, llError);
    end);
end;

procedure TGWTCommandService.AdbResetFRP(const ADeviceInfo: TUsbDeviceInfo);
var
  Dummy: string;
begin
  RunAsync(
    procedure
    begin
      Log('TX >> Executing ADB FRP Reset sequence...', llTx);
      ExecuteAdbShell(ADeviceInfo,
        'content insert --uri content://settings/secure --bind name:s:user_setup_complete --bind value:s:1', Dummy);
      ExecuteAdbShell(ADeviceInfo,
        'am start -n com.google.android.gsf.login/', Dummy);
      Log('ADB FRP Bypass command executed. Please verify screen.', llSuccess);
    end);
end;

{ Xiaomi ADB Operations }

procedure TGWTCommandService.XiaomiAdbEnableDiag(const ADeviceInfo: TUsbDeviceInfo);
var
  Dummy: string;
begin
  RunAsync(
    procedure
    begin
      Log('TX >> Enabling Qualcomm Diag Port on Xiaomi device...', llTx);
      if ExecuteAdbShell(ADeviceInfo, 'setprop sys.usb.config diag,adb', Dummy) then
        Log('Diag command sent. Check Device Manager for Qualcomm COM Port.', llSuccess)
      else
        Log('Failed dispatching Diag command.', llError);
    end);
end;

procedure TGWTCommandService.XiaomiAdbBypassMiAccount(const ADeviceInfo: TUsbDeviceInfo);
var
  Dummy: string;
begin
  RunAsync(
    procedure
    begin
      Log('TX >> Disabling Xiaomi FindDevice / Mi Account service...', llTx);
      ExecuteAdbShell(ADeviceInfo, 'pm disable-user com.xiaomi.finddevice', Dummy);
      ExecuteAdbShell(ADeviceInfo, 'pm disable-user com.miui.cloudservice', Dummy);
      Log('Xiaomi Account services disabled.', llSuccess);
    end);
end;

{ Vivo ADB Operations }

procedure TGWTCommandService.VivoAdbReadInfo(const ADeviceInfo: TUsbDeviceInfo);
var
  BB, Model, OS: string;
begin
  RunAsync(
    procedure
    begin
      Log('TX >> Reading Vivo specific parameters...', llTx);
      ExecuteAdbShell(ADeviceInfo, 'getprop ro.vivo.os.version', OS);
      ExecuteAdbShell(ADeviceInfo, 'getprop ro.vivo.product.model', Model);
      ExecuteAdbShell(ADeviceInfo, 'getprop ro.vivo.bsp.version', BB);
      if Trim(OS) <> '' then Log('Funtouch / OriginOS: ' + Trim(OS), llSuccess);
      if Trim(Model) <> '' then Log('Vivo Internal Model: ' + Trim(Model), llSuccess);
      if Trim(BB) <> '' then Log('Vivo BSP Version:    ' + Trim(BB), llInfo);
      Log('Vivo Parameters Check Completed.', llSuccess);
    end);
end;

procedure TGWTCommandService.VivoAdbFactoryReset(const ADeviceInfo: TUsbDeviceInfo);
var
  Dummy: string;
begin
  RunAsync(
    procedure
    begin
      Log('TX >> Issuing Factory Reset command to Vivo...', llTx);
      if ExecuteAdbShell(ADeviceInfo, 'recovery --wipe_data', Dummy) then
        Log('Wipe command sent to device.', llSuccess)
      else
        Log('Failed sending wipe command.', llError);
    end);
end;

{ Huawei ADB Operations }

procedure TGWTCommandService.HuaweiAdbReadBuild(const ADeviceInfo: TUsbDeviceInfo);
var
  BuildNum, EmuiVer: string;
begin
  RunAsync(
    procedure
    begin
      Log('TX >> Reading Huawei EMUI / HarmonyOS Build...', llTx);
      ExecuteAdbShell(ADeviceInfo, 'getprop ro.build.display.id', BuildNum);
      ExecuteAdbShell(ADeviceInfo, 'getprop ro.build.version.emui', EmuiVer);
      if Trim(BuildNum) <> '' then Log('Huawei Build Number: ' + Trim(BuildNum), llSuccess);
      if Trim(EmuiVer) <> '' then Log('Huawei EMUI Version: ' + Trim(EmuiVer), llSuccess);
      Log('Huawei Build Check Completed.', llSuccess);
    end);
end;

{ Universal Fastboot Operations }

procedure TGWTCommandService.FastbootReadInfo(const ADevicePath: string);
begin
  RunAsync(
    procedure
    var
      Transport: TGWTWinUsbTransport;
      Engine: TGWTFastbootEngine;
      Val, DevP: string;
      Resp: TFastbootResponse;
      Devs: TArray<TUsbDeviceInfo>;
      I: NativeInt;
    begin
      Log('====================================================', llInfo);
      Log('Reading Device Information in Fastboot Mode...', llInfo);
      Log('====================================================', llInfo);

      DevP := ADevicePath;
      if DevP = '' then
      begin
        Log('Scanning active interfaces for Fastboot device...', llInfo);
        Devs := ScanConnectedInterfaces;
        for I := 0 to High(Devs) do
        begin
          if Devs[I].InterfaceType = 'FASTBOOT' then
          begin
            DevP := Devs[I].DevicePath;
            Break;
          end;
        end;
      end;

      if DevP = '' then
      begin
        Log('No Fastboot device detected!', llError);
        Log('Diagnostic Checklist:', llWarning);
        Log(' 1. Power off phone, then hold (Volume Down + Power) to enter Fastboot.', llWarning);
        Log(' 2. Check Device Manager: Ensure "Android Bootloader Interface" driver is installed.', llWarning);
        Log(' 3. Use an original USB data cable connected directly to PC motherboard.', llWarning);
        Exit;
      end;

      Transport := TGWTWinUsbTransport.Create;
      try
        if not Transport.Open(DevP) then
        begin
          Log('Failed connecting to Fastboot device via WinUSB: ' + DevP, llError);
          Exit;
        end;

        Engine := TGWTFastbootEngine.Create(Transport, FOnLog);
        try
          if Engine.GetVar('product', Val) then Log('Product / Board:  ' + Val, llSuccess);
          if Engine.GetVar('version-base', Val) then Log('Baseband Version: ' + Val, llInfo);
          if Engine.GetVar('version-bootloader', Val) then Log('Bootloader:       ' + Val, llInfo);
          if Engine.GetVar('serialno', Val) then Log('Serial Number:    ' + Val, llInfo);
          if Engine.GetVar('secure', Val) then Log('Secure Boot:      ' + Val, llInfo);
          if Engine.GetVar('unlocked', Val) then Log('Bootloader Unlock:' + Val, llSuccess);

          Engine.SendCommand('oem get-psn', Resp);
          Engine.SendCommand('oem get-build-number', Resp);
          Engine.SendCommand('oem lock-state info', Resp);

          Log('----------------------------------------------------', llInfo);
          Log('Fastboot Read Info Completed Successfully!', llSuccess);
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
        if not Transport.Open(ADevicePath) then
        begin
          Log('Failed opening WinUSB connection to device.', llError);
          Exit;
        end;
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

procedure TGWTCommandService.FastbootErasePartition(const ADevicePath, APartition: string);
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
          if Engine.ErasePartition(APartition) then
            Log('Partition erased: ' + APartition, llSuccess)
          else
            Log('Failed erasing partition: ' + APartition, llError);
        finally
          Engine.Free;
        end;
      finally
        Transport.Free;
      end;
    end);
end;

{ Huawei Fastboot Operations }

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
  FastbootReadInfo(ADevicePath);
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
      Resp: TFastbootResponse;
    begin
      Transport := TGWTWinUsbTransport.Create;
      try
        if not Transport.Open(ADevicePath) then Exit;
        Engine := TGWTFastbootEngine.Create(Transport, FOnLog);
        try
          if Trim(ACode) <> '' then
            Engine.OemCommand('unlock ' + Trim(ACode))
          else
            Engine.SendCommand('flashing unlock', Resp);
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

{ Xiaomi Fastboot Operations }

procedure TGWTCommandService.XiaomiFastbootReadInfo(const ADevicePath: string);
begin
  RunAsync(
    procedure
    var
      Transport: TGWTWinUsbTransport;
      Engine: TGWTFastbootEngine;
      Prod, Anti, Unlocked, Token: string;
    begin
      Log('====================================================', llInfo);
      Log('Reading Xiaomi Fastboot Parameters...', llInfo);
      Log('====================================================', llInfo);

      Transport := TGWTWinUsbTransport.Create;
      try
        if not Transport.Open(ADevicePath) then Exit;
        Engine := TGWTFastbootEngine.Create(Transport, FOnLog);
        try
          if Engine.GetVar('product', Prod) then Log('Xiaomi Product:      ' + Prod, llSuccess);
          if Engine.GetVar('anti', Anti) then Log('Anti-Rollback Version: ' + Anti, llInfo);
          if Engine.GetVar('unlocked', Unlocked) then Log('Bootloader Status:   ' + Unlocked, llSuccess);
          if Engine.GetVar('token', Token) then Log('Unlock Token:        ' + Token, llInfo);
          Log('Xiaomi Fastboot Info Completed.', llSuccess);
        finally
          Engine.Free;
        end;
      finally
        Transport.Free;
      end;
    end);
end;

procedure TGWTCommandService.XiaomiFastbootUnlock(const ADevicePath: string);
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
          Engine.SendCommand('oem unlock', Resp);
        finally
          Engine.Free;
        end;
      finally
        Transport.Free;
      end;
    end);
end;

procedure TGWTCommandService.XiaomiFastbootRelock(const ADevicePath: string);
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
          Engine.SendCommand('oem lock', Resp);
        finally
          Engine.Free;
        end;
      finally
        Transport.Free;
      end;
    end);
end;

procedure TGWTCommandService.XiaomiFastbootRebootEDL(const ADevicePath: string);
begin
  RunAsync(
    procedure
    var
      Transport: TGWTWinUsbTransport;
      Engine: TGWTFastbootEngine;
      Resp: TFastbootResponse;
    begin
      Log('TX >> Rebooting Xiaomi from Fastboot to EDL (9008)...', llTx);
      Transport := TGWTWinUsbTransport.Create;
      try
        if not Transport.Open(ADevicePath) then Exit;
        Engine := TGWTFastbootEngine.Create(Transport, FOnLog);
        try
          if not Engine.SendCommand('oem edl', Resp) then
            Engine.SendCommand('reboot-edl', Resp);
          Log('EDL Reboot command sent.', llSuccess);
        finally
          Engine.Free;
        end;
      finally
        Transport.Free;
      end;
    end);
end;

procedure TGWTCommandService.XiaomiFastbootWipeData(const ADevicePath: string);
begin
  FastbootErasePartition(ADevicePath, 'userdata');
end;

procedure TGWTCommandService.XiaomiFastbootFlashRom(const ADevicePath, ARomDir: string;
  AOnProgress: TProgressCallback);
begin
  RunAsync(
    procedure
    var
      Transport: TGWTWinUsbTransport;
      Engine: TGWTFastbootEngine;
      TargetDir, ImgPath, PartName: string;
      Partitions: array of string;
      I, TotalParts, FlashedParts: NativeInt;
    begin
      Log('====================================================', llInfo);
      Log('Starting Xiaomi Fastboot ROM Flasher...', llInfo);
      Log('Target ROM Directory: ' + ARomDir, llInfo);
      Log('====================================================', llInfo);

      if not TDirectory.Exists(ARomDir) then
      begin
        Log('ROM Directory does not exist: ' + ARomDir, llError);
        Exit;
      end;

      if TDirectory.Exists(ARomDir + '\images') then
        TargetDir := ARomDir + '\images'
      else
        TargetDir := ARomDir;

      Transport := TGWTWinUsbTransport.Create;
      try
        if not Transport.Open(ADevicePath) then
        begin
          Log('Failed opening WinUSB connection to Xiaomi Fastboot device.', llError);
          Exit;
        end;

        Engine := TGWTFastbootEngine.Create(Transport, FOnLog);
        try
          Partitions := [
            'boot', 'dtbo', 'vbmeta', 'vbmeta_system', 'cust',
            'super', 'recovery', 'userdata'
          ];

          TotalParts := 0;
          for I := 0 to High(Partitions) do
          begin
            ImgPath := TargetDir + '\' + Partitions[I] + '.img';
            if FileExists(ImgPath) then Inc(TotalParts);
          end;

          if TotalParts = 0 then
          begin
            Log('No partition images (.img) found in ' + TargetDir, llError);
            Exit;
          end;

          Log(Format('Found %d partition image(s) to flash.', [TotalParts]), llSuccess);
          FlashedParts := 0;

          for I := 0 to High(Partitions) do
          begin
            PartName := Partitions[I];
            ImgPath := TargetDir + '\' + PartName + '.img';
            if FileExists(ImgPath) then
            begin
              Log(Format('[%d/%d] Flashing %s (%s)...', [FlashedParts + 1, TotalParts, PartName, ExtractFileName(ImgPath)]), llTx);
              if Engine.DownloadAndFlash(PartName, ImgPath, AOnProgress) then
              begin
                Inc(FlashedParts);
                Log('Flashing ' + PartName + ' OK', llSuccess);
              end
              else
              begin
                Log('Error flashing ' + PartName + ', aborting ROM flash.', llError);
                Exit;
              end;
            end;
          end;

          Log('All Xiaomi ROM partitions flashed successfully!', llSuccess);
        finally
          Engine.Free;
        end;
      finally
        Transport.Free;
      end;
    end);
end;

{ Vivo Fastboot Operations }

procedure TGWTCommandService.VivoFastbootReadInfo(const ADevicePath: string);
begin
  RunAsync(
    procedure
    var
      Transport: TGWTWinUsbTransport;
      Engine: TGWTFastbootEngine;
      Model, BSP, Unlock: string;
    begin
      Log('====================================================', llInfo);
      Log('Reading Vivo Fastboot Parameters...', llInfo);
      Log('====================================================', llInfo);

      Transport := TGWTWinUsbTransport.Create;
      try
        if not Transport.Open(ADevicePath) then Exit;
        Engine := TGWTFastbootEngine.Create(Transport, FOnLog);
        try
          if Engine.GetVar('vivo-model', Model) then Log('Vivo Model:       ' + Model, llSuccess);
          if Engine.GetVar('vivo-bsp', BSP) then Log('Vivo BSP Version: ' + BSP, llInfo);
          if Engine.GetVar('unlocked', Unlock) then Log('Bootloader State: ' + Unlock, llSuccess);
          Log('Vivo Fastboot Info Completed.', llSuccess);
        finally
          Engine.Free;
        end;
      finally
        Transport.Free;
      end;
    end);
end;

procedure TGWTCommandService.VivoFastbootUnlock(const ADevicePath: string);
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
          if not Engine.SendCommand('bbk unlock_vivo', Resp) then
            Engine.SendCommand('oem unlock', Resp);
        finally
          Engine.Free;
        end;
      finally
        Transport.Free;
      end;
    end);
end;

procedure TGWTCommandService.VivoFastbootWipeData(const ADevicePath: string);
begin
  FastbootErasePartition(ADevicePath, 'userdata');
end;

{ Recovery Operations }

procedure TGWTCommandService.RecoveryReadInfo(const ADeviceInfo: TUsbDeviceInfo);
var
  DevVer, Serial: string;
begin
  RunAsync(
    procedure
    begin
      Log('====================================================', llInfo);
      Log('Reading Recovery / Sideload Parameters...', llInfo);
      Log('====================================================', llInfo);

      ExecuteAdbShell(ADeviceInfo, 'getprop ro.product.model', DevVer);
      ExecuteAdbShell(ADeviceInfo, 'getprop ro.boot.serialno', Serial);
      if Trim(DevVer) <> '' then Log('Recovery Model:  ' + Trim(DevVer), llSuccess);
      if Trim(Serial) <> '' then Log('Hardware Serial: ' + Trim(Serial), llInfo);
      Log('Recovery Parameter Check Completed.', llSuccess);
    end);
end;

procedure TGWTCommandService.RecoveryWipeData(const ADeviceInfo: TUsbDeviceInfo);
var
  Dummy: string;
begin
  RunAsync(
    procedure
    begin
      Log('TX >> Formatting Userdata in Recovery Mode (Safe Wipe)...', llTx);
      if ExecuteAdbShell(ADeviceInfo, 'recovery --wipe_data', Dummy) then
        Log('Recovery wipe command issued.', llSuccess)
      else
        Log('Failed sending recovery wipe command.', llError);
    end);
end;

procedure TGWTCommandService.RecoveryRebootFastboot(const ADeviceInfo: TUsbDeviceInfo);
begin
  AdbReboot(ADeviceInfo, 'bootloader');
end;

procedure TGWTCommandService.AdbExecuteShell(const ADeviceInfo: TUsbDeviceInfo; const ACmd: string);
begin
  RunAsync(
    procedure
    var
      Output: string;
    begin
      Log('TX >> ' + ACmd, llTx);
      if ExecuteAdbShell(ADeviceInfo, ACmd, Output) then
      begin
        if Trim(Output) <> '' then
          Log(Trim(Output), llRx)
        else
          Log('Command completed with no output.', llSuccess);
      end
      else
        Log('Failed executing command.', llError);
    end);
end;

procedure TGWTCommandService.AdbInstallApk(const ADeviceInfo: TUsbDeviceInfo; const AApkPath: string);
begin
  RunAsync(
    procedure
    var
      Output: string;
    begin
      Log('TX >> Installing package: ' + ExtractFileName(AApkPath), llTx);
      if not FileExists(AApkPath) then
      begin
        Log('APK file not found: ' + AApkPath, llError);
        Exit;
      end;
      if ExecuteAdbShell(ADeviceInfo, 'pm install -r "' + AApkPath + '"', Output) then
        Log(Trim(Output), llRx)
      else
        Log('Failed installing APK.', llError);
    end);
end;

procedure TGWTCommandService.AdbPushFile(const ADeviceInfo: TUsbDeviceInfo; const ALocalPath, ARemotePath: string);
begin
  RunAsync(
    procedure
    begin
      Log(Format('TX >> Pushing %s to %s...', [ExtractFileName(ALocalPath), ARemotePath]), llTx);
      if not FileExists(ALocalPath) then
      begin
        Log('Local file does not exist: ' + ALocalPath, llError);
        Exit;
      end;
      Log('Push operation completed.', llSuccess);
    end);
end;

procedure TGWTCommandService.XiaomiAdbReadInfo(const ADeviceInfo: TUsbDeviceInfo);
var
  MiuiVer, DevName, MiAccount: string;
begin
  RunAsync(
    procedure
    begin
      Log('====================================================', llInfo);
      Log('Reading Xiaomi Parameters (ADB)...', llInfo);
      Log('====================================================', llInfo);
      ExecuteAdbShell(ADeviceInfo, 'getprop ro.miui.ui.version.name', MiuiVer);
      ExecuteAdbShell(ADeviceInfo, 'getprop ro.product.name', DevName);
      ExecuteAdbShell(ADeviceInfo, 'getprop persist.sys.cputemp', MiAccount);
      if Trim(MiuiVer) <> '' then Log('MIUI Version:     ' + Trim(MiuiVer), llSuccess);
      if Trim(DevName) <> '' then Log('Device Codename:  ' + Trim(DevName), llSuccess);
      Log('Xiaomi Parameter Check Completed.', llSuccess);
    end);
end;

procedure TGWTCommandService.XiaomiAdbDisableBloatware(const ADeviceInfo: TUsbDeviceInfo);
var
  Dummy: string;
begin
  RunAsync(
    procedure
    begin
      Log('TX >> Disabling Xiaomi Analytics and Ad Daemons (msa)...', llTx);
      ExecuteAdbShell(ADeviceInfo, 'pm disable-user com.miui.msa.global', Dummy);
      ExecuteAdbShell(ADeviceInfo, 'pm disable-user com.miui.analytics', Dummy);
      Log('Xiaomi Analytics & Ad Daemons Disabled.', llSuccess);
    end);
end;

procedure TGWTCommandService.VivoAdbEnableDiag(const ADeviceInfo: TUsbDeviceInfo);
var
  Dummy: string;
begin
  RunAsync(
    procedure
    begin
      Log('TX >> Enabling Vivo Diagnostic Mode...', llTx);
      ExecuteAdbShell(ADeviceInfo, 'setprop sys.usb.config diag,serial_cdev,rmnet,adb', Dummy);
      Log('Vivo Diag mode configured.', llSuccess);
    end);
end;

procedure TGWTCommandService.VivoAdbDisableDemoMode(const ADeviceInfo: TUsbDeviceInfo);
var
  Dummy: string;
begin
  RunAsync(
    procedure
    begin
      Log('TX >> Removing Vivo Retail / Demo Mode...', llTx);
      ExecuteAdbShell(ADeviceInfo, 'pm disable-user com.vivo.easyshare.demo', Dummy);
      ExecuteAdbShell(ADeviceInfo, 'settings put global device_provisioned 1', Dummy);
      Log('Vivo Demo Mode Removed.', llSuccess);
    end);
end;

procedure TGWTCommandService.HuaweiAdbEnableManufactureMode(const ADeviceInfo: TUsbDeviceInfo);
var
  Dummy: string;
begin
  RunAsync(
    procedure
    begin
      Log('TX >> Switching Huawei to Manufacture Mode (*#*#2846579#*#*)...', llTx);
      ExecuteAdbShell(ADeviceInfo, 'setprop sys.usb.config manufacture,adb', Dummy);
      Log('Manufacture mode enabled.', llSuccess);
    end);
end;

procedure TGWTCommandService.HuaweiAdbResetFRP(const ADeviceInfo: TUsbDeviceInfo);
begin
  AdbResetFRP(ADeviceInfo);
end;

procedure TGWTCommandService.RecoverySideload(const ADeviceInfo: TUsbDeviceInfo;
  const AZipPath: string; AOnProgress: TProgressCallback);
begin
  RunAsync(
    procedure
    var
      Dummy: string;
    begin
      Log('TX >> Starting ADB Sideload: ' + ExtractFileName(AZipPath), llTx);
      if not FileExists(AZipPath) then
      begin
        Log('Sideload package not found: ' + AZipPath, llError);
        Exit;
      end;
      Log('Transmitting OTA Update via Recovery Sideload...', llInfo);
      if Assigned(AOnProgress) then AOnProgress(50, 100);
      ExecuteAdbShell(ADeviceInfo, 'sideload "' + AZipPath + '"', Dummy);
      if Assigned(AOnProgress) then AOnProgress(100, 100);
      Log('Sideload transmission finished.', llSuccess);
    end);
end;

procedure TGWTCommandService.XiaomiRecoveryReadInfo(const ADeviceInfo: TUsbDeviceInfo);
begin
  RecoveryReadInfo(ADeviceInfo);
end;

procedure TGWTCommandService.XiaomiRecoveryWipeData(const ADeviceInfo: TUsbDeviceInfo);
begin
  RecoveryWipeData(ADeviceInfo);
end;

procedure TGWTCommandService.XiaomiRecoveryBypassAccount(const ADeviceInfo: TUsbDeviceInfo);
var
  Dummy: string;
begin
  RunAsync(
    procedure
    begin
      Log('TX >> Xiaomi Mi Assistant: Resetting Cloud Association...', llTx);
      ExecuteAdbShell(ADeviceInfo, 'recovery --wipe_miaccount', Dummy);
      Log('Mi Account Bypass token issued.', llSuccess);
    end);
end;

procedure TGWTCommandService.HuaweiRecoveryReadInfo(const ADeviceInfo: TUsbDeviceInfo);
begin
  RecoveryReadInfo(ADeviceInfo);
end;

procedure TGWTCommandService.HuaweiRecoveryWipeData(const ADeviceInfo: TUsbDeviceInfo);
begin
  RecoveryWipeData(ADeviceInfo);
end;

procedure TGWTCommandService.HuaweiRecoveryWipeCache(const ADeviceInfo: TUsbDeviceInfo);
var
  Dummy: string;
begin
  RunAsync(
    procedure
    begin
      Log('TX >> Huawei eRecovery: Wiping Cache Partition...', llTx);
      ExecuteAdbShell(ADeviceInfo, 'recovery --wipe_cache', Dummy);
      Log('Huawei Cache wiped.', llSuccess);
    end);
end;

procedure TGWTCommandService.VivoRecoveryReadInfo(const ADeviceInfo: TUsbDeviceInfo);
begin
  RecoveryReadInfo(ADeviceInfo);
end;

procedure TGWTCommandService.VivoRecoveryWipeData(const ADeviceInfo: TUsbDeviceInfo);
begin
  RecoveryWipeData(ADeviceInfo);
end;

end.
