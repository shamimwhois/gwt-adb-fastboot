program GWT_Tool;

uses
  Vcl.Forms,
  GWT.Types in 'Core\GWT.Types.pas',
  GWT.WinUSB.API in 'Protocols\GWT.WinUSB.API.pas',
  GWT.WinUSB.Transport in 'Protocols\GWT.WinUSB.Transport.pas',
  GWT.Protocol.Fastboot in 'Protocols\GWT.Protocol.Fastboot.pas',
  GWT.Protocol.ADB in 'Protocols\GWT.Protocol.ADB.pas',
  GWT.CommandService in 'Services\GWT.CommandService.pas',
  Frame.AdbService in 'Frames\Frame.AdbService.pas' {FrameAdbService: TFrame},
  Frame.FastbootService in 'Frames\Frame.FastbootService.pas' {FrameFastbootService: TFrame},
  Frame.FastbootFlash in 'Frames\Frame.FastbootFlash.pas' {FrameFastbootFlash: TFrame},
  Frame.RecoveryService in 'Frames\Frame.RecoveryService.pas' {FrameRecoveryService: TFrame},
  Frame.RecoveryFlash in 'Frames\Frame.RecoveryFlash.pas' {FrameRecoveryFlash: TFrame},
  Form.Main in 'UI\Form.Main.pas' {FormMain},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'GWT ADB & Fastboot Tool v1.0';
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
