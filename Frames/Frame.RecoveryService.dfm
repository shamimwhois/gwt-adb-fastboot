object FrameRecoveryService: TFrameRecoveryService
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
    object pnlXiaomiCard: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 8
      Width = 688
      Height = 98
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
      object lblXiaomiHeader: TLabel
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
        Caption = 'XIAOMI MI ASSISTANT (SIDELOAD)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16773120
        Font.Height = -13
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
        StyleElements = []
      end
      object lblXiaomiSub: TLabel
        AlignWithMargins = True
        Left = 16
        Top = 30
        Width = 656
        Height = 15
        Margins.Left = 16
        Margins.Top = 0
        Margins.Right = 16
        Margins.Bottom = 4
        Align = alTop
        Caption = 'Read parameters via Mi Assistant, format userdata in recovery, bypass Mi Account'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        StyleElements = []
      end
      object gpXiaomiButtons: TGridPanel
        AlignWithMargins = True
        Left = 12
        Top = 49
        Width = 664
        Height = 36
        Margins.Left = 12
        Margins.Top = 0
        Margins.Right = 12
        Margins.Bottom = 6
        Align = alClient
        BevelOuter = bvNone
        Color = 2365198
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
            Control = btnXiaomiReadInfo
            Row = 0
          end
          item
            Column = 1
            Control = btnXiaomiSafeWipe
            Row = 0
          end
          item
            Column = 2
            Control = btnXiaomiBypassMi
            Row = 0
          end>
        ParentBackground = False
        RowCollection = <
          item
            Value = 100.000000000000000000
          end>
        StyleElements = []
        TabOrder = 0
        object btnXiaomiReadInfo: TButton
          AlignWithMargins = True
          Left = 2
          Top = 2
          Width = 217
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'READ MI ASSISTANT'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = btnXiaomiReadInfoClick
        end
        object btnXiaomiSafeWipe: TButton
          AlignWithMargins = True
          Left = 223
          Top = 2
          Width = 217
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'SAFE WIPE ALL DATA'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = btnXiaomiSafeWipeClick
        end
        object btnXiaomiBypassMi: TButton
          AlignWithMargins = True
          Left = 444
          Top = 2
          Width = 218
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'BYPASS MI ACCOUNT'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnClick = btnXiaomiBypassMiClick
        end
      end
    end
    object pnlHuaweiCard: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 114
      Width = 688
      Height = 98
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
      object lblHuaweiHeader: TLabel
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
        Caption = 'HUAWEI ERECOVERY'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16773120
        Font.Height = -13
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
        StyleElements = []
      end
      object lblHuaweiSub: TLabel
        AlignWithMargins = True
        Left = 16
        Top = 30
        Width = 656
        Height = 15
        Margins.Left = 16
        Margins.Top = 0
        Margins.Right = 16
        Margins.Bottom = 4
        Align = alTop
        Caption = 'Read eRecovery properties, format factory userdata, and wipe cache'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        StyleElements = []
      end
      object gpHuaweiButtons: TGridPanel
        AlignWithMargins = True
        Left = 12
        Top = 49
        Width = 664
        Height = 36
        Margins.Left = 12
        Margins.Top = 0
        Margins.Right = 12
        Margins.Bottom = 6
        Align = alClient
        BevelOuter = bvNone
        Color = 2365198
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
            Control = btnHuaweiReadInfo
            Row = 0
          end
          item
            Column = 1
            Control = btnHuaweiWipeData
            Row = 0
          end
          item
            Column = 2
            Control = btnHuaweiWipeCache
            Row = 0
          end>
        ParentBackground = False
        RowCollection = <
          item
            Value = 100.000000000000000000
          end>
        StyleElements = []
        TabOrder = 0
        object btnHuaweiReadInfo: TButton
          AlignWithMargins = True
          Left = 2
          Top = 2
          Width = 217
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'READ ERECOVERY INFO'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = btnHuaweiReadInfoClick
        end
        object btnHuaweiWipeData: TButton
          AlignWithMargins = True
          Left = 223
          Top = 2
          Width = 217
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'WIPE DATA / FACTORY'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = btnHuaweiWipeDataClick
        end
        object btnHuaweiWipeCache: TButton
          AlignWithMargins = True
          Left = 444
          Top = 2
          Width = 218
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'WIPE CACHE'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnClick = btnHuaweiWipeCacheClick
        end
      end
    end
    object pnlVivoCard: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 220
      Width = 688
      Height = 98
      Margins.Left = 8
      Margins.Top = 4
      Margins.Right = 8
      Margins.Bottom = 8
      Align = alTop
      BevelOuter = bvNone
      Color = 2365198
      ParentBackground = False
      StyleElements = []
      TabOrder = 2
      object lblVivoHeader: TLabel
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
        Caption = 'VIVO RECOVERY'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16773120
        Font.Height = -13
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
        StyleElements = []
      end
      object lblVivoSub: TLabel
        AlignWithMargins = True
        Left = 16
        Top = 30
        Width = 656
        Height = 15
        Margins.Left = 16
        Margins.Top = 0
        Margins.Right = 16
        Margins.Bottom = 4
        Align = alTop
        Caption = 'Read Vivo recovery serial and model, format userdata'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        StyleElements = []
      end
      object gpVivoButtons: TGridPanel
        AlignWithMargins = True
        Left = 12
        Top = 49
        Width = 664
        Height = 36
        Margins.Left = 12
        Margins.Top = 0
        Margins.Right = 12
        Margins.Bottom = 6
        Align = alClient
        BevelOuter = bvNone
        Color = 2365198
        ColumnCollection = <
          item
            Value = 50.000000000000000000
          end
          item
            Value = 50.000000000000000000
          end>
        ControlCollection = <
          item
            Column = 0
            Control = btnVivoReadInfo
            Row = 0
          end
          item
            Column = 1
            Control = btnVivoWipeData
            Row = 0
          end>
        ParentBackground = False
        RowCollection = <
          item
            Value = 100.000000000000000000
          end>
        StyleElements = []
        TabOrder = 0
        object btnVivoReadInfo: TButton
          AlignWithMargins = True
          Left = 2
          Top = 2
          Width = 327
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'READ VIVO RECOVERY INFO'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = btnVivoReadInfoClick
        end
        object btnVivoWipeData: TButton
          AlignWithMargins = True
          Left = 333
          Top = 2
          Width = 327
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'WIPE USERDATA (SAFE)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = btnVivoWipeDataClick
        end
      end
    end
    object pnlGeneralCard: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 326
      Width = 688
      Height = 98
      Margins.Left = 8
      Margins.Top = 4
      Margins.Right = 8
      Margins.Bottom = 16
      Align = alTop
      BevelOuter = bvNone
      Color = 2365198
      ParentBackground = False
      StyleElements = []
      TabOrder = 3
      object lblGeneralHeader: TLabel
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
        Caption = 'RECOVERY UTILITIES'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16773120
        Font.Height = -13
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
        StyleElements = []
      end
      object lblGeneralSub: TLabel
        AlignWithMargins = True
        Left = 16
        Top = 30
        Width = 656
        Height = 15
        Margins.Left = 16
        Margins.Top = 0
        Margins.Right = 16
        Margins.Bottom = 4
        Align = alTop
        Caption = 'Standard device reboot and shutdown controls'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        StyleElements = []
      end
      object gpGeneralButtons: TGridPanel
        AlignWithMargins = True
        Left = 12
        Top = 49
        Width = 664
        Height = 36
        Margins.Left = 12
        Margins.Top = 0
        Margins.Right = 12
        Margins.Bottom = 6
        Align = alClient
        BevelOuter = bvNone
        Color = 2365198
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
            Control = btnGeneralRebootSystem
            Row = 0
          end
          item
            Column = 1
            Control = btnGeneralRebootFastboot
            Row = 0
          end
          item
            Column = 2
            Control = btnGeneralPowerOff
            Row = 0
          end>
        ParentBackground = False
        RowCollection = <
          item
            Value = 100.000000000000000000
          end>
        StyleElements = []
        TabOrder = 0
        object btnGeneralRebootSystem: TButton
          AlignWithMargins = True
          Left = 2
          Top = 2
          Width = 217
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'REBOOT SYSTEM'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = btnGeneralRebootSystemClick
        end
        object btnGeneralRebootFastboot: TButton
          AlignWithMargins = True
          Left = 223
          Top = 2
          Width = 217
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'REBOOT FASTBOOT'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = btnGeneralRebootFastbootClick
        end
        object btnGeneralPowerOff: TButton
          AlignWithMargins = True
          Left = 444
          Top = 2
          Width = 218
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'POWER OFF DEVICE'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnClick = btnGeneralPowerOffClick
        end
      end
    end
  end
end
