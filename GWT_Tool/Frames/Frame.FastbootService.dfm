object FrameFastbootService: TFrameFastbootService
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
    object pnlHuaweiCard: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 8
      Width = 688
      Height = 140
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
        Caption = 'HUAWEI FASTBOOT & FRP'
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
        Top = 28
        Width = 656
        Height = 15
        Margins.Left = 16
        Margins.Top = 0
        Margins.Right = 16
        Margins.Bottom = 4
        Align = alTop
        Caption = 'Reset FRP lock using 16-character factory token, read parameters, relock bootloader'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        StyleElements = []
      end
      object lblFRPPrompt: TLabel
        Left = 16
        Top = 49
        Width = 142
        Height = 15
        Caption = 'Enter Huawei 16-Digit FRP Key:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        StyleElements = []
      end
      object edtFRPKey: TEdit
        Left = 16
        Top = 66
        Width = 340
        Height = 25
        Color = 1839884
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        MaxLength = 32
        ParentFont = False
        TabOrder = 0
        TextHint = 'e.g. 8A24F90B1C4E7D3F'
      end
      object btnHuaweiResetFRP: TButton
        Left = 368
        Top = 65
        Width = 150
        Height = 27
        Caption = 'RESET FRP (KEY)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        OnClick = btnHuaweiResetFRPClick
      end
      object btnHuaweiReadInfo: TButton
        Left = 16
        Top = 98
        Width = 200
        Height = 30
        Caption = 'READ OEM INFO (HUAWEI)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        OnClick = btnHuaweiReadInfoClick
      end
      object btnHuaweiRelockBL: TButton
        Left = 226
        Top = 98
        Width = 180
        Height = 30
        Caption = 'RELOCK BOOTLOADER'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        OnClick = btnHuaweiRelockBLClick
      end
    end
    object pnlXiaomiCard: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 156
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
        Caption = 'XIAOMI FASTBOOT'
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
        Caption = 'Read Fastboot getvar all, OEM unlock/relock bootloader, reboot to 9008 EDL mode'
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
            Value = 20.000000000000000000
          end
          item
            Value = 20.000000000000000000
          end
          item
            Value = 20.000000000000000000
          end
          item
            Value = 20.000000000000000000
          end
          item
            Value = 20.000000000000000000
          end>
        ControlCollection = <
          item
            Column = 0
            Control = btnXiaomiReadInfo
            Row = 0
          end
          item
            Column = 1
            Control = btnXiaomiUnlockBL
            Row = 0
          end
          item
            Column = 2
            Control = btnXiaomiRelockBL
            Row = 0
          end
          item
            Column = 3
            Control = btnXiaomiRebootEDL
            Row = 0
          end
          item
            Column = 4
            Control = btnXiaomiSafeWipe
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
          Width = 128
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'READ FASTBOOT'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = btnXiaomiReadInfoClick
        end
        object btnXiaomiUnlockBL: TButton
          AlignWithMargins = True
          Left = 134
          Top = 2
          Width = 128
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'UNLOCK BL (OEM)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = btnXiaomiUnlockBLClick
        end
        object btnXiaomiRelockBL: TButton
          AlignWithMargins = True
          Left = 266
          Top = 2
          Width = 128
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'RELOCK BL'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnClick = btnXiaomiRelockBLClick
        end
        object btnXiaomiRebootEDL: TButton
          AlignWithMargins = True
          Left = 398
          Top = 2
          Width = 128
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'REBOOT EDL (9008)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 3
          OnClick = btnXiaomiRebootEDLClick
        end
        object btnXiaomiSafeWipe: TButton
          AlignWithMargins = True
          Left = 530
          Top = 2
          Width = 132
          Height = 32
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'SAFE WIPE DATA'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 4
          OnClick = btnXiaomiSafeWipeClick
        end
      end
    end
    object pnlVivoCard: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 262
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
        Caption = 'VIVO FASTBOOT'
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
        Caption = 'Read Vivo model and BSP version, unlock BBK bootloader, format userdata'
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
            Control = btnVivoReadInfo
            Row = 0
          end
          item
            Column = 1
            Control = btnVivoUnlockBL
            Row = 0
          end
          item
            Column = 2
            Control = btnVivoFactoryReset
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
          Width = 217
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
        object btnVivoUnlockBL: TButton
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
          Caption = 'UNLOCK BL (VIVO BBK)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = btnVivoUnlockBLClick
        end
        object btnVivoFactoryReset: TButton
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
          Caption = 'FACTORY RESET'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnClick = btnVivoFactoryResetClick
        end
      end
    end
    object pnlGeneralCard: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 368
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
        Caption = 'GENERAL LOCKS & REBOOT CONTROLS'
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
        Caption = 'Universal FRP bypass, format userdata partition, reboot to system or recovery'
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
            Control = btnGeneralResetFRP
            Row = 0
          end
          item
            Column = 1
            Control = btnGeneralFormatData
            Row = 0
          end
          item
            Column = 2
            Control = btnGeneralRebootSystem
            Row = 0
          end
          item
            Column = 3
            Control = btnGeneralRebootRecovery
            Row = 0
          end>
        ParentBackground = False
        RowCollection = <
          item
            Value = 100.000000000000000000
          end>
        StyleElements = []
        TabOrder = 0
        object btnGeneralResetFRP: TButton
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
          Caption = 'RESET FRP (GENERIC)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = btnGeneralResetFRPClick
        end
        object btnGeneralFormatData: TButton
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
          Caption = 'FORMAT USERDATA'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = btnGeneralFormatDataClick
        end
        object btnGeneralRebootSystem: TButton
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
          Caption = 'REBOOT SYSTEM'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnClick = btnGeneralRebootSystemClick
        end
        object btnGeneralRebootRecovery: TButton
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
          Caption = 'REBOOT RECOVERY'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          OnClick = btnGeneralRebootRecoveryClick
        end
      end
    end
  end
end
