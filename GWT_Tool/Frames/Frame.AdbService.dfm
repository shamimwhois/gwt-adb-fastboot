object FrameAdbService: TFrameAdbService
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
    object pnlUniversalCard: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 8
      Width = 688
      Height = 138
      Margins.Left = 8
      Margins.Top = 6
      Margins.Right = 8
      Margins.Bottom = 6
      Align = alTop
      BevelOuter = bvNone
      Color = 2365198
      ParentBackground = False
      StyleElements = []
      TabOrder = 0
      object lblUniversalHeader: TLabel
        AlignWithMargins = True
        Left = 16
        Top = 8
        Width = 656
        Height = 16
        Margins.Left = 16
        Margins.Top = 8
        Margins.Right = 16
        Margins.Bottom = 2
        Align = alTop
        Caption = 'UNIVERSAL ADB CONTROLS'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16773120
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
        StyleElements = []
      end
      object lblUniversalSub: TLabel
        AlignWithMargins = True
        Left = 16
        Top = 26
        Width = 656
        Height = 15
        Margins.Left = 16
        Margins.Top = 0
        Margins.Right = 16
        Margins.Bottom = 4
        Align = alTop
        Caption = 'Read Android build parameters, reset Google FRP, and switch modes'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        StyleElements = []
      end
      object gpUniversalButtons: TGridPanel
        AlignWithMargins = True
        Left = 12
        Top = 45
        Width = 664
        Height = 72
        Margins.Left = 12
        Margins.Top = 2
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
            Control = btnReadInfo
            Row = 0
          end
          item
            Column = 1
            Control = btnResetFRP
            Row = 0
          end
          item
            Column = 2
            Control = btnRebootFastboot
            Row = 0
          end
          item
            Column = 0
            Control = btnRebootRecovery
            Row = 1
          end
          item
            Column = 1
            Control = btnRebootEDL
            Row = 1
          end
          item
            Column = 2
            Control = btnRebootSystem
            Row = 1
          end>
        ParentBackground = False
        RowCollection = <
          item
            Value = 50.000000000000000000
          end
          item
            Value = 50.000000000000000000
          end>
        StyleElements = []
        TabOrder = 0
        object btnReadInfo: TButton
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
          Caption = '>> READ INFO (ADB) <<'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = btnReadInfoClick
        end
        object btnResetFRP: TButton
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
          Caption = 'RESET FRP (ADB SETUP)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 1
          OnClick = btnResetFRPClick
        end
        object btnRebootFastboot: TButton
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
          Caption = '>> REBOOT FASTBOOT <<'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 2
          OnClick = btnRebootFastbootClick
        end
        object btnRebootRecovery: TButton
          AlignWithMargins = True
          Left = 2
          Top = 38
          Width = 217
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'REBOOT TO RECOVERY'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          OnClick = btnRebootRecoveryClick
        end
        object btnRebootEDL: TButton
          AlignWithMargins = True
          Left = 223
          Top = 38
          Width = 217
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'REBOOT TO EDL (9008)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 4
          OnClick = btnRebootEDLClick
        end
        object btnRebootSystem: TButton
          AlignWithMargins = True
          Left = 444
          Top = 38
          Width = 218
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
          TabOrder = 5
          OnClick = btnRebootSystemClick
        end
      end
    end
    object pnlXiaomiCard: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 196
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
        Caption = 'XIAOMI ADB SPECIAL'
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
        Caption = 'Read MIUI version, bypass Mi Account, enable Qualcomm Diag, and disable ads'
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
            Value = 25.000000000000000000
          end
          item
            Value = 25.000000000000000000
          end
          item
            Value = 25.000000000000000000
          end
          item
            Value = 25.000000000000000000
          end>
        ControlCollection = <
          item
            Column = 0
            Control = btnXiaomiReadInfo
            Row = 0
          end
          item
            Column = 1
            Control = btnXiaomiBypassMi
            Row = 0
          end
          item
            Column = 2
            Control = btnXiaomiEnableDiag
            Row = 0
          end
          item
            Column = 3
            Control = btnXiaomiDisableAds
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
          Width = 162
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'READ MI INFO'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = btnXiaomiReadInfoClick
        end
        object btnXiaomiBypassMi: TButton
          AlignWithMargins = True
          Left = 168
          Top = 2
          Width = 162
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
          TabOrder = 1
          OnClick = btnXiaomiBypassMiClick
        end
        object btnXiaomiEnableDiag: TButton
          AlignWithMargins = True
          Left = 334
          Top = 2
          Width = 162
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'ENABLE DIAG (*#*#)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnClick = btnXiaomiEnableDiagClick
        end
        object btnXiaomiDisableAds: TButton
          AlignWithMargins = True
          Left = 500
          Top = 2
          Width = 162
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'DISABLE ADS (MSA)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          OnClick = btnXiaomiDisableAdsClick
        end
      end
    end
    object pnlVivoCard: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 302
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
        Caption = 'VIVO ADB SPECIAL'
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
        Caption = 'Read Vivo hardware model, safe factory reset, and remove retail demo mode'
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
            Value = 25.000000000000000000
          end
          item
            Value = 25.000000000000000000
          end
          item
            Value = 25.000000000000000000
          end
          item
            Value = 25.000000000000000000
          end>
        ControlCollection = <
          item
            Column = 0
            Control = btnVivoReadInfo
            Row = 0
          end
          item
            Column = 1
            Control = btnVivoFactoryReset
            Row = 0
          end
          item
            Column = 2
            Control = btnVivoEnableDiag
            Row = 0
          end
          item
            Column = 3
            Control = btnVivoRemoveDemo
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
          Width = 162
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'READ VIVO INFO'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = btnVivoReadInfoClick
        end
        object btnVivoFactoryReset: TButton
          AlignWithMargins = True
          Left = 168
          Top = 2
          Width = 162
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'FACTORY RESET'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = btnVivoFactoryResetClick
        end
        object btnVivoEnableDiag: TButton
          AlignWithMargins = True
          Left = 334
          Top = 2
          Width = 162
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'ENABLE VIVO DIAG'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnClick = btnVivoEnableDiagClick
        end
        object btnVivoRemoveDemo: TButton
          AlignWithMargins = True
          Left = 500
          Top = 2
          Width = 162
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'REMOVE DEMO MODE'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          OnClick = btnVivoRemoveDemoClick
        end
      end
    end
    object pnlHuaweiCard: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 408
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
        Caption = 'HUAWEI ADB SPECIAL'
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
        Caption = 'Read EMUI version, switch to Manufacture Mode (*#*#2846579#*#*), and reset FRP'
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
            Control = btnHuaweiReadBuild
            Row = 0
          end
          item
            Column = 1
            Control = btnHuaweiManufacture
            Row = 0
          end
          item
            Column = 2
            Control = btnHuaweiResetFRP
            Row = 0
          end>
        ParentBackground = False
        RowCollection = <
          item
            Value = 100.000000000000000000
          end>
        StyleElements = []
        TabOrder = 0
        object btnHuaweiReadBuild: TButton
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
          Caption = 'READ EMUI / BUILD'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = btnHuaweiReadBuildClick
        end
        object btnHuaweiManufacture: TButton
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
          Caption = 'MANUFACTURE MODE'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = btnHuaweiManufactureClick
        end
        object btnHuaweiResetFRP: TButton
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
          Caption = 'RESET FRP (HUAWEI ADB)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnClick = btnHuaweiResetFRPClick
        end
      end
    end
  end
end
