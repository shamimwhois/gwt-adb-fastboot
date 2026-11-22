object FrameFastbootFlash: TFrameFastbootFlash
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
    object pnlXiaomiRomCard: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 8
      Width = 688
      Height = 138
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
      object lblXiaomiRomHeader: TLabel
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
        Caption = 'XIAOMI FASTBOOT ROM FLASHER'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16773120
        Font.Height = -13
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
        StyleElements = []
      end
      object lblXiaomiRomSub: TLabel
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
        Caption = 'Flash complete Xiaomi Fastboot ROM (boot, vbmeta, super, recovery, cust) automatically'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        StyleElements = []
      end
      object lblRomDir: TLabel
        Left = 16
        Top = 48
        Width = 265
        Height = 15
        Caption = 'Select Fastboot ROM Directory (contains images\):'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        StyleElements = []
      end
      object edtRomPath: TEdit
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
        TextHint = 'D:\Xiaomi_ROM\raphael_global_images'
      end
      object btnBrowseRom: TButton
        Left = 556
        Top = 65
        Width = 115
        Height = 27
        Caption = 'CHOOSE DIR...'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnClick = btnBrowseRomClick
      end
      object btnFlashXiaomiRom: TButton
        Left = 16
        Top = 98
        Width = 230
        Height = 30
        Caption = '>> FLASH FULL XIAOMI ROM <<'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        OnClick = btnFlashXiaomiRomClick
      end
    end
    object pnlFlashCard: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 154
      Width = 688
      Height = 142
      Margins.Left = 8
      Margins.Top = 4
      Margins.Right = 8
      Margins.Bottom = 8
      Align = alTop
      BevelOuter = bvNone
      Color = 2365198
      ParentBackground = False
      StyleElements = []
      TabOrder = 1
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
        Caption = 'UNIVERSAL FASTBOOT PARTITION FLASHER'
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
        Caption = 'High-speed 1MB chunked raw WinUSB flashing for standard Android partitions'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        StyleElements = []
      end
      object lblPartition: TLabel
        Left = 16
        Top = 48
        Width = 90
        Height = 15
        Caption = 'Target Partition:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        StyleElements = []
      end
      object cbPartition: TComboBox
        Left = 16
        Top = 66
        Width = 180
        Height = 25
        Color = 1839884
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ItemIndex = 0
        ParentFont = False
        TabOrder = 0
        Text = 'boot'
        Items.Strings = (
          'boot'
          'recovery'
          'vbmeta'
          'system'
          'vendor'
          'userdata'
          'cust'
          'super'
          'misc'
          'cache'
          'dtbo'
          'persist')
      end
      object lblImageFile: TLabel
        Left = 212
        Top = 48
        Width = 111
        Height = 15
        Caption = 'Partition Image File:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        StyleElements = []
      end
      object edtImagePath: TEdit
        Left = 212
        Top = 66
        Width = 330
        Height = 25
        Color = 1839884
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        TextHint = 'D:\firmware\boot.img'
      end
      object btnBrowseImage: TButton
        Left = 552
        Top = 65
        Width = 120
        Height = 27
        Caption = 'BROWSE...'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        OnClick = btnBrowseImageClick
      end
      object btnFlashPartition: TButton
        Left = 16
        Top = 98
        Width = 170
        Height = 30
        Caption = '>> FLASH PARTITION <<'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 3
        OnClick = btnFlashPartitionClick
      end
      object btnErasePartition: TButton
        Left = 194
        Top = 98
        Width = 140
        Height = 30
        Caption = 'ERASE PARTITION'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 4
        OnClick = btnErasePartitionClick
      end
      object btnRebootSystem: TButton
        Left = 342
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
        TabOrder = 5
        OnClick = btnRebootSystemClick
      end
    end
    object pnlProgressCard: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 304
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
      TabOrder = 2
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
        Caption = 'TRANSFER & FLASH STATUS'
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
        Caption = 'Ready. Select partition and image to begin.'
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
  object dlgOpenImage: TOpenDialog
    Filter = 'Partition Images (*.img;*.bin)|*.img;*.bin|All Files (*.*)|*.*'
    Title = 'Select Partition Image File'
    Left = 480
    Top = 16
  end
end
