object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'GWT ADB & Fastboot Tool v1.2'
  ClientHeight = 680
  ClientWidth = 1080
  Color = 1708299
  Constraints.MinHeight = 600
  Constraints.MinWidth = 960
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWhite
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  StyleElements = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 1080
    Height = 52
    Align = alTop
    BevelOuter = bvNone
    Color = 2365198
    ParentBackground = False
    TabOrder = 0
    StyleElements = []
    DesignSize = (
      1080
      52)
    object lblBrandLogo: TLabel
      Left = 18
      Top = 10
      Width = 52
      Height = 31
      Caption = 'GWT'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 16773120
      Font.Height = -23
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleElements = []
    end
    object lblAppTitle: TLabel
      Left = 82
      Top = 17
      Width = 179
      Height = 20
      Caption = 'ADB & FASTBOOT TOOL v1.2'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -15
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
      StyleElements = []
    end
    object lblConnStatus: TLabel
      Left = 913
      Top = 18
      Width = 147
      Height = 17
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = #9679' WAITING FOR DEVICE'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 46079
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleElements = []
    end
  end
  object pnlBody: TPanel
    Left = 0
    Top = 52
    Width = 1080
    Height = 628
    Align = alClient
    BevelOuter = bvNone
    Color = 1708299
    ParentBackground = False
    TabOrder = 1
    StyleElements = []
    object pnlRightSidebar: TPanel
      AlignWithMargins = True
      Left = 744
      Top = 8
      Width = 328
      Height = 612
      Margins.Left = 4
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      Align = alRight
      BevelOuter = bvNone
      Color = 2365198
      ParentBackground = False
      TabOrder = 0
      StyleElements = []
      object pnlUsbBox: TPanel
        Left = 0
        Top = 0
        Width = 328
        Height = 100
        Align = alTop
        BevelOuter = bvNone
        Color = 2365198
        ParentBackground = False
        TabOrder = 0
        StyleElements = []
        object lblUsbTitle: TLabel
          AlignWithMargins = True
          Left = 12
          Top = 8
          Width = 304
          Height = 13
          Margins.Left = 12
          Margins.Top = 8
          Margins.Right = 12
          Margins.Bottom = 2
          Align = alTop
          Caption = 'USB PORT DETECTION'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 12959408
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleElements = []
        end
        object cbUSBDevices: TComboBox
          AlignWithMargins = True
          Left = 12
          Top = 25
          Width = 304
          Height = 23
          Margins.Left = 12
          Margins.Top = 2
          Margins.Right = 12
          Margins.Bottom = 4
          Align = alTop
          Style = csDropDownList
          Color = 1839884
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
        object btnScanDevices: TButton
          AlignWithMargins = True
          Left = 12
          Top = 54
          Width = 304
          Height = 30
          Margins.Left = 12
          Margins.Top = 2
          Margins.Right = 12
          Margins.Bottom = 6
          Align = alTop
          Caption = 'SCAN ADB / FASTBOOT'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 1
          OnClick = btnScanDevicesClick
        end
      end
      object pnlLogBox: TPanel
        Left = 0
        Top = 100
        Width = 328
        Height = 498
        Align = alClient
        BevelOuter = bvNone
        Color = 2365198
        ParentBackground = False
        TabOrder = 1
        StyleElements = []
        object lblLogTitle: TLabel
          AlignWithMargins = True
          Left = 12
          Top = 6
          Width = 304
          Height = 13
          Margins.Left = 12
          Margins.Top = 6
          Margins.Right = 12
          Margins.Bottom = 6
          Align = alTop
          Caption = 'OPERATION LOGS'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 12959408
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          StyleElements = []
          ExplicitWidth = 92
        end
        object redLogs: TRichEdit
          AlignWithMargins = True
          Left = 12
          Top = 25
          Width = 304
          Height = 461
          Margins.Left = 12
          Margins.Top = 0
          Margins.Right = 12
          Margins.Bottom = 12
          Align = alClient
          BorderStyle = bsNone
          Color = 1051911
          Font.Charset = ANSI_CHARSET
          Font.Color = 12959408
          Font.Height = -12
          Font.Name = 'Consolas'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 0
          StyleElements = []
        end
      end
    end
    object pnlWorkspace: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 8
      Width = 728
      Height = 612
      Margins.Left = 8
      Margins.Top = 8
      Margins.Right = 4
      Margins.Bottom = 8
      Align = alClient
      BevelOuter = bvNone
      Color = 1708299
      ParentBackground = False
      TabOrder = 1
      StyleElements = []
      object gpModeTabs: TGridPanel
        AlignWithMargins = True
        Left = 0
        Top = 2
        Width = 728
        Height = 36
        Margins.Left = 0
        Margins.Top = 2
        Margins.Right = 0
        Margins.Bottom = 2
        Align = alTop
        BevelOuter = bvNone
        Color = 1708299
        ColumnCollection = <
          item
            Value = 33.333333333333330000
          end
          item
            Value = 33.333333333333330000
          end
          item
            Value = 33.333333333333340000
          end>
        ControlCollection = <
          item
            Column = 0
            Control = btnModeADB
            Row = 0
          end
          item
            Column = 1
            Control = btnModeFastboot
            Row = 0
          end
          item
            Column = 2
            Control = btnModeRecovery
            Row = 0
          end>
        ParentBackground = False
        RowCollection = <
          item
            Value = 100.000000000000000000
          end>
        TabOrder = 0
        StyleElements = []
        object btnModeADB: TButton
          AlignWithMargins = True
          Left = 3
          Top = 2
          Width = 237
          Height = 32
          Margins.Left = 3
          Margins.Top = 2
          Margins.Right = 3
          Margins.Bottom = 2
          Align = alClient
          Caption = 'ADB'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = ModeTabClick
        end
        object btnModeFastboot: TButton
          AlignWithMargins = True
          Left = 246
          Top = 2
          Width = 236
          Height = 32
          Margins.Left = 3
          Margins.Top = 2
          Margins.Right = 3
          Margins.Bottom = 2
          Align = alClient
          Caption = 'FASTBOOT'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = ModeTabClick
        end
        object btnModeRecovery: TButton
          AlignWithMargins = True
          Left = 488
          Top = 2
          Width = 237
          Height = 32
          Margins.Left = 3
          Margins.Top = 2
          Margins.Right = 3
          Margins.Bottom = 2
          Align = alClient
          Caption = 'RECOVERY'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnClick = ModeTabClick
        end
      end
      object pnlSubTabs: TPanel
        AlignWithMargins = True
        Left = 4
        Top = 40
        Width = 720
        Height = 30
        Margins.Left = 4
        Margins.Top = 2
        Margins.Right = 4
        Margins.Bottom = 2
        Align = alTop
        BevelOuter = bvNone
        Color = 1708299
        ParentBackground = False
        TabOrder = 1
        StyleElements = []
        object btnSubService: TButton
          Left = 0
          Top = 2
          Width = 120
          Height = 26
          Caption = 'SERVICE'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = SubTabClick
        end
        object btnSubFlash: TButton
          Left = 126
          Top = 2
          Width = 120
          Height = 26
          Caption = 'FLASH'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = SubTabClick
        end
      end
      object pnlFrameHost: TPanel
        Left = 0
        Top = 74
        Width = 728
        Height = 538
        Align = alClient
        BevelOuter = bvNone
        Color = 1708299
        ParentBackground = False
        TabOrder = 2
        StyleElements = []
      end
    end
  end
  object tmrAutoDetect: TTimer
    Interval = 2000
    OnTimer = tmrAutoDetectTimer
    Left = 700
    Top = 16
  end
end
