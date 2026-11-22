object FrameRecoveryFlash: TFrameRecoveryFlash
  Left = 0
  Top = 0
  Width = 720
  Height = 600
  Color = 1708299
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWhite
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  ParentBackground = False
  ParentColor = False
  ParentDoubleBuffered = False
  ParentFont = False
  StyleElements = []
  TabOrder = 0
  object sbContainer: TScrollBox
    Left = 0
    Top = 0
    Width = 720
    Height = 600
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = 1708299
    ParentBackground = False
    ParentColor = False
    StyleElements = []
    TabOrder = 0
    object pnlFlashCard: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 8
      Width = 688
      Height = 142
      Margins.Left = 8
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      Align = alTop
      BevelOuter = bvNone
      Color = 2365198
      ParentBackground = False
      StyleElements = []
      TabOrder = 0
      object lblFlashHeader: TLabel
        AlignWithMargins = True
        Left = 16
        Top = 10
        Width = 656
        Height = 18
        Margins.Left = 16
        Margins.Top = 10
        Margins.Right = 16
        Margins.Bottom = 2
        Align = alTop
        Caption = 'RECOVERY ADB SIDELOAD FLASHER'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16773120
        Font.Height = -13
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
        StyleElements = []
      end
      object lblFlashSub: TLabel
        AlignWithMargins = True
        Left = 16
        Top = 28
        Width = 656
        Height = 15
        Margins.Left = 16
        Margins.Top = 0
        Margins.Right = 16
        Margins.Bottom = 4
        Align = alTop
        Caption = 'Transmit signed OTA update packages, custom ROM zips, and Magisk root via Sideload'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        StyleElements = []
      end
      object lblZipFile: TLabel
        Left = 16
        Top = 48
        Width = 142
        Height = 15
        Caption = 'Recovery ZIP Update File:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        StyleElements = []
      end
      object edtZipPath: TEdit
        Left = 16
        Top = 66
        Width = 530
        Height = 25
        Color = 1839884
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        TextHint = 'D:\firmware\update.zip'
      end
      object btnBrowseZip: TButton
        Left = 556
        Top = 65
        Width = 115
        Height = 27
        Caption = 'BROWSE...'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnClick = btnBrowseZipClick
      end
      object btnSideloadZip: TButton
        Left = 16
        Top = 98
        Width = 180
        Height = 30
        Caption = '>> START ADB SIDELOAD <<'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        OnClick = btnSideloadZipClick
      end
      object btnRebootSystem: TButton
        Left = 204
        Top = 98
        Width = 140
        Height = 30
        Caption = 'REBOOT SYSTEM'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        OnClick = btnRebootSystemClick
      end
    end
    object pnlProgressCard: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 158
      Width = 688
      Height = 88
      Margins.Left = 8
      Margins.Top = 4
      Margins.Right = 8
      Margins.Bottom = 16
      Align = alTop
      BevelOuter = bvNone
      Color = 2365198
      ParentBackground = False
      StyleElements = []
      TabOrder = 1
      object lblProgressHeader: TLabel
        AlignWithMargins = True
        Left = 16
        Top = 10
        Width = 656
        Height = 18
        Margins.Left = 16
        Margins.Top = 10
        Margins.Right = 16
        Margins.Bottom = 2
        Align = alTop
        Caption = 'SIDELOAD TRANSFER STATUS'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16773120
        Font.Height = -13
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
        StyleElements = []
      end
      object lblProgressStatus: TLabel
        AlignWithMargins = True
        Left = 16
        Top = 28
        Width = 656
        Height = 15
        Margins.Left = 16
        Margins.Top = 0
        Margins.Right = 16
        Margins.Bottom = 4
        Align = alTop
        Caption = 'Ready. Select a ZIP package to begin sideloading.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        StyleElements = []
      end
      object pbProgress: TProgressBar
        Left = 16
        Top = 52
        Width = 656
        Height = 20
        TabOrder = 0
      end
    end
  end
  object dlgOpenZip: TOpenDialog
    Filter = 'Recovery ZIP Archives (*.zip)|*.zip|All Files (*.*)|*.*'
    Title = 'Select Recovery Update ZIP'
    Left = 480
    Top = 16
  end
end
