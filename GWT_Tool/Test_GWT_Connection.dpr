program Test_GWT_Connection;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  GWT.Types in 'Core\GWT.Types.pas',
  GWT.WinUSB.API in 'Protocols\GWT.WinUSB.API.pas',
  GWT.WinUSB.Transport in 'Protocols\GWT.WinUSB.Transport.pas',
  GWT.Protocol.Fastboot in 'Protocols\GWT.Protocol.Fastboot.pas',
  GWT.Protocol.ADB in 'Protocols\GWT.Protocol.ADB.pas',
  GWT.CommandService in 'Services\GWT.CommandService.pas';

procedure ConsoleLogger(const AMsg: string; ALevel: TLogLevel);
var
  Tag: string;
begin
  case ALevel of
    llSuccess: Tag := '[OK] ';
    llWarning: Tag := '[WARN] ';
    llError:   Tag := '[ERR] ';
    llTx:      Tag := '[TX >>] ';
    llRx:      Tag := '[RX <<] ';
    llCommand: Tag := '[CMD] ';
  else
    Tag := '[INFO] ';
  end;
  Writeln(Format('[%s] %s%s', [FormatDateTime('hh:nn:ss', Now), Tag, AMsg]));
end;

procedure PumpEvents(ADurationMs: Integer);
var
  Start: Cardinal;
begin
  Start := TThread.GetTickCount;
  while (TThread.GetTickCount - Start) < Cardinal(ADurationMs) do
  begin
    CheckSynchronize(20);
    Sleep(20);
  end;
end;

var
  CmdSvc: TGWTCommandService;
  Devices: TArray<TUsbDeviceInfo>;
  I: NativeInt;
  Dev: TUsbDeviceInfo;
  HadAdb, HadFastboot: Boolean;
begin
  try
    Writeln('====================================================');
    Writeln(' GWT Tool v1.2 - Live Device Connection Tester');
    Writeln('====================================================');

    CmdSvc := TGWTCommandService.Create(ConsoleLogger);
    try
      Writeln('Scanning connected Android interfaces (WinUSB + ADB Socket)...');
      Devices := CmdSvc.ScanConnectedInterfaces;

      Writeln(Format('Found %d device(s):', [Length(Devices)]));
      for I := 0 to High(Devices) do
      begin
        Dev := Devices[I];
        Writeln(Format(' [%d] %s | Type: %s | Serial: %s | Path: %s',
          [I, Dev.FriendlyName, Dev.InterfaceType, Dev.Serial, Dev.DevicePath]));
      end;

      HadAdb := False;
      HadFastboot := False;

      for I := 0 to High(Devices) do
      begin
        Dev := Devices[I];
        if Dev.InterfaceType = 'ADB' then
        begin
          HadAdb := True;
          Writeln('');
          Writeln('>>> Testing ADB Device: ' + Dev.FriendlyName);
          CmdSvc.AdbReadDeviceInfo(Dev);
          PumpEvents(2000);
        end
        else if Dev.InterfaceType = 'FASTBOOT' then
        begin
          HadFastboot := True;
          Writeln('');
          Writeln('>>> Testing Fastboot Device: ' + Dev.FriendlyName);
          CmdSvc.FastbootReadInfo(Dev.DevicePath);
          PumpEvents(2000);
        end;
      end;

      if not HadAdb and not HadFastboot then
      begin
        Writeln('');
        Writeln('No Android device currently in active ADB or Fastboot communication.');
        Writeln('Hardware check:');
        Writeln(' - Make sure phone USB cable is firmly connected.');
        Writeln(' - On Android: Enable Developer Options -> USB Debugging (and accept RSA prompt).');
        Writeln(' - If phone is off or in bootloader: Hold Vol Down + Power to enter Fastboot.');
      end;

    finally
      CmdSvc.Free;
    end;

    Writeln('');
    Writeln('Test completed successfully.');
  except
    on E: Exception do
      Writeln('FATAL ERROR: ' + E.ClassName + ': ' + E.Message);
  end;
end.
