object FrameAdbNetworkUnlock: TFrameAdbNetworkUnlock
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
    object pnlBrandModelBar: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 6
      Width = 688
      Height = 72
      Margins.Left = 8
      Margins.Top = 6
      Margins.Right = 8
      Margins.Bottom = 4
      Align = alTop
      BevelOuter = bvNone
      Color = 2365198
      ParentBackground = False
      StyleElements = []
      TabOrder = 0
      object lblBrand: TLabel
        Left = 14
        Top = 10
        Width = 113
        Height = 15
        Caption = 'BRAND / PLATFORM:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleElements = []
      end
      object lblModel: TLabel
        Left = 240
        Top = 10
        Width = 83
        Height = 15
        Caption = 'MODEL / SERIES:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleElements = []
      end
      object lblMethod: TLabel
        Left = 466
        Top = 10
        Width = 124
        Height = 15
        Caption = 'CONNECTION METHOD:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleElements = []
      end
      object cbBrand: TComboBox
        Left = 14
        Top = 30
        Width = 212
        Height = 25
        Style = csDropDownList
        Color = 1839884
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ItemIndex = 0
        ParentFont = False
        TabOrder = 0
        Text = 'Universal / Auto-Detect'
        OnChange = cbBrandChange
        Items.Strings = (
          'Universal / Auto-Detect'
          'Samsung'
          'Xiaomi / Redmi / POCO'
          'Vivo / iQOO'
          'Huawei / Honor'
          'Oppo / Realme / OnePlus'
          'Transsion (Tecno / Infinix / Itel)'
          'MediaTek Generic (MTK)'
          'Qualcomm Generic (QCOM)'
          'Unisoc / Spreadtrum (SPD)')
      end
      object cbModel: TComboBox
        Left = 240
        Top = 30
        Width = 212
        Height = 25
        Style = csDropDownList
        Color = 1839884
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ItemIndex = 0
        ParentFont = False
        TabOrder = 1
        Text = '[Auto-Detect Model]'
        Items.Strings = (
          '[Auto-Detect Model]')
      end
      object cbMethod: TComboBox
        Left = 466
        Top = 30
        Width = 208
        Height = 25
        Style = csDropDownList
        Color = 1839884
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ItemIndex = 0
        ParentFont = False
        TabOrder = 2
        Text = 'ADB Shell / Root Direct'
        Items.Strings = (
          'ADB Shell / Root Direct'
          'AT via Radio /dev/tty'
          'Diagnostic (DIAG) Port'
          'EFS / NVRAM Partition Direct')
      end
    end
    object pnlImeiCard: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 86
      Width = 688
      Height = 156
      Margins.Left = 8
      Margins.Top = 4
      Margins.Right = 8
      Margins.Bottom = 4
      Align = alTop
      BevelOuter = bvNone
      Color = 2365198
      ParentBackground = False
      StyleElements = []
      TabOrder = 1
      object lblImeiHeader: TLabel
        AlignWithMargins = True
        Left = 14
        Top = 8
        Width = 660
        Height = 16
        Margins.Left = 14
        Margins.Top = 8
        Margins.Right = 14
        Margins.Bottom = 2
        Align = alTop
        Caption = 'DUAL IMEI REPAIR & LUHN VALIDATION'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16773120
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
        StyleElements = []
      end
      object lblImeiSub: TLabel
        AlignWithMargins = True
        Left = 14
        Top = 26
        Width = 660
        Height = 15
        Margins.Left = 14
        Margins.Top = 0
        Margins.Right = 14
        Margins.Bottom = 4
        Align = alTop
        Caption = 'Read, calculate Luhn checksum, and safely write IMEI 1 & IMEI 2 via native ADB/AT protocol'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        StyleElements = []
      end
      object lblImei1: TLabel
        Left = 14
        Top = 48
        Width = 92
        Height = 15
        Caption = 'IMEI 1 (15 Digits):'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        StyleElements = []
      end
      object lblImei1Status: TLabel
        Left = 260
        Top = 48
        Width = 60
        Height = 15
        Caption = '[Pending]'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleElements = []
      end
      object lblImei2: TLabel
        Left = 350
        Top = 48
        Width = 92
        Height = 15
        Caption = 'IMEI 2 (15 Digits):'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        StyleElements = []
      end
      object lblImei2Status: TLabel
        Left = 595
        Top = 48
        Width = 60
        Height = 15
        Caption = '[Pending]'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleElements = []
      end
      object edtImei1: TEdit
        Left = 14
        Top = 68
        Width = 320
        Height = 25
        Color = 1839884
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Consolas'
        Font.Style = []
        MaxLength = 15
        ParentFont = False
        TabOrder = 0
        TextHint = 'Enter 15-digit IMEI 1'
        OnChange = edtImei1Change
      end
      object edtImei2: TEdit
        Left = 350
        Top = 68
        Width = 324
        Height = 25
        Color = 1839884
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Consolas'
        Font.Style = []
        MaxLength = 15
        ParentFont = False
        TabOrder = 1
        TextHint = 'Enter 15-digit IMEI 2'
        OnChange = edtImei2Change
      end
      object gpImeiButtons: TGridPanel
        AlignWithMargins = True
        Left = 10
        Top = 104
        Width = 668
        Height = 44
        Margins.Left = 10
        Margins.Top = 6
        Margins.Right = 10
        Margins.Bottom = 8
        Align = alBottom
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
            Control = btnReadImei
            Row = 0
          end
          item
            Column = 1
            Control = btnCalcLuhn
            Row = 0
          end
          item
            Column = 2
            Control = btnGenTestImei
            Row = 0
          end
          item
            Column = 3
            Control = btnWriteImei
            Row = 0
          end>
        ParentBackground = False
        RowCollection = <
          item
            Value = 100.000000000000000000
          end>
        TabOrder = 2
        StyleElements = []
        object btnReadImei: TButton
          AlignWithMargins = True
          Left = 2
          Top = 2
          Width = 163
          Height = 40
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'READ IMEI'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = btnReadImeiClick
        end
        object btnCalcLuhn: TButton
          AlignWithMargins = True
          Left = 169
          Top = 2
          Width = 163
          Height = 40
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'CALC LUHN DIGIT'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = btnCalcLuhnClick
        end
        object btnGenTestImei: TButton
          AlignWithMargins = True
          Left = 336
          Top = 2
          Width = 163
          Height = 40
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'TEST IMEI GEN'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnClick = btnGenTestImeiClick
        end
        object btnWriteImei: TButton
          AlignWithMargins = True
          Left = 503
          Top = 2
          Width = 163
          Height = 40
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'REPAIR / WRITE'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 3
          OnClick = btnWriteImeiClick
        end
      end
    end
    object pnlUnlockCard: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 250
      Width = 688
      Height = 100
      Margins.Left = 8
      Margins.Top = 4
      Margins.Right = 8
      Margins.Bottom = 4
      Align = alTop
      BevelOuter = bvNone
      Color = 2365198
      ParentBackground = False
      StyleElements = []
      TabOrder = 2
      object lblUnlockHeader: TLabel
        AlignWithMargins = True
        Left = 14
        Top = 8
        Width = 660
        Height = 16
        Margins.Left = 14
        Margins.Top = 8
        Margins.Right = 14
        Margins.Bottom = 2
        Align = alTop
        Caption = 'NETWORK & CARRIER UNLOCK'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16773120
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
        StyleElements = []
      end
      object lblUnlockSub: TLabel
        AlignWithMargins = True
        Left = 14
        Top = 26
        Width = 660
        Height = 15
        Margins.Left = 14
        Margins.Top = 0
        Margins.Right = 14
        Margins.Bottom = 4
        Align = alTop
        Caption = 'Direct SIM de-personalization, carrier restriction removal, and baseband radio recovery'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        StyleElements = []
      end
      object gpUnlockButtons: TGridPanel
        AlignWithMargins = True
        Left = 10
        Top = 48
        Width = 668
        Height = 44
        Margins.Left = 10
        Margins.Top = 4
        Margins.Right = 10
        Margins.Bottom = 8
        Align = alBottom
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
            Control = btnCheckSimlock
            Row = 0
          end
          item
            Column = 1
            Control = btnDirectUnlock
            Row = 0
          end
          item
            Column = 2
            Control = btnRestoreLock
            Row = 0
          end
          item
            Column = 3
            Control = btnRepairBaseband
            Row = 0
          end>
        ParentBackground = False
        RowCollection = <
          item
            Value = 100.000000000000000000
          end>
        TabOrder = 0
        StyleElements = []
        object btnCheckSimlock: TButton
          AlignWithMargins = True
          Left = 2
          Top = 2
          Width = 163
          Height = 40
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'CHECK SIMLOCK'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = btnCheckSimlockClick
        end
        object btnDirectUnlock: TButton
          AlignWithMargins = True
          Left = 169
          Top = 2
          Width = 163
          Height = 40
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'DIRECT UNLOCK'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 1
          OnClick = btnDirectUnlockClick
        end
        object btnRestoreLock: TButton
          AlignWithMargins = True
          Left = 336
          Top = 2
          Width = 163
          Height = 40
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'RESTORE LOCK'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnClick = btnRestoreLockClick
        end
        object btnRepairBaseband: TButton
          AlignWithMargins = True
          Left = 503
          Top = 2
          Width = 163
          Height = 40
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'REPAIR BASEBAND'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          OnClick = btnRepairBasebandClick
        end
      end
    end
    object pnlSecurityCard: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 358
      Width = 688
      Height = 100
      Margins.Left = 8
      Margins.Top = 4
      Margins.Right = 8
      Margins.Bottom = 4
      Align = alTop
      BevelOuter = bvNone
      Color = 2365198
      ParentBackground = False
      StyleElements = []
      TabOrder = 3
      object lblSecurityHeader: TLabel
        AlignWithMargins = True
        Left = 14
        Top = 8
        Width = 660
        Height = 16
        Margins.Left = 14
        Margins.Top = 8
        Margins.Right = 14
        Margins.Bottom = 2
        Align = alTop
        Caption = 'EFS & NVRAM SECURITY BACKUP'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16773120
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
        StyleElements = []
      end
      object lblSecuritySub: TLabel
        AlignWithMargins = True
        Left = 14
        Top = 26
        Width = 660
        Height = 15
        Margins.Left = 14
        Margins.Top = 0
        Margins.Right = 14
        Margins.Bottom = 4
        Align = alTop
        Caption = 'Dump and protect modem calibration, modemst1/2, and NVRAM data to prevent signal loss'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        StyleElements = []
      end
      object gpSecurityButtons: TGridPanel
        AlignWithMargins = True
        Left = 10
        Top = 48
        Width = 668
        Height = 44
        Margins.Left = 10
        Margins.Top = 4
        Margins.Right = 10
        Margins.Bottom = 8
        Align = alBottom
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
            Control = btnBackupSecurity
            Row = 0
          end
          item
            Column = 1
            Control = btnRestoreSecurity
            Row = 0
          end
          item
            Column = 2
            Control = btnRestartRil
            Row = 0
          end>
        ParentBackground = False
        RowCollection = <
          item
            Value = 100.000000000000000000
          end>
        TabOrder = 0
        StyleElements = []
        object btnBackupSecurity: TButton
          AlignWithMargins = True
          Left = 2
          Top = 2
          Width = 218
          Height = 40
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'BACKUP EFS / NVRAM'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = btnBackupSecurityClick
        end
        object btnRestoreSecurity: TButton
          AlignWithMargins = True
          Left = 224
          Top = 2
          Width = 218
          Height = 40
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'RESTORE EFS / NVRAM'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = btnRestoreSecurityClick
        end
        object btnRestartRil: TButton
          AlignWithMargins = True
          Left = 446
          Top = 2
          Width = 220
          Height = 40
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'RESTART MODEM / RIL'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnClick = btnRestartRilClick
        end
      end
    end
    object pnlDiagCard: TPanel
      AlignWithMargins = True
      Left = 8
      Top = 466
      Width = 688
      Height = 100
      Margins.Left = 8
      Margins.Top = 4
      Margins.Right = 8
      Margins.Bottom = 4
      Align = alTop
      BevelOuter = bvNone
      Color = 2365198
      ParentBackground = False
      StyleElements = []
      TabOrder = 4
      object lblDiagHeader: TLabel
        AlignWithMargins = True
        Left = 14
        Top = 8
        Width = 660
        Height = 16
        Margins.Left = 14
        Margins.Top = 8
        Margins.Right = 14
        Margins.Bottom = 2
        Align = alTop
        Caption = 'DIAGNOSTIC (DIAG) PORT CONTROLS'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16773120
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = [fsBold]
        ParentFont = False
        StyleElements = []
      end
      object lblDiagSub: TLabel
        AlignWithMargins = True
        Left = 14
        Top = 26
        Width = 660
        Height = 15
        Margins.Left = 14
        Margins.Top = 0
        Margins.Right = 14
        Margins.Bottom = 4
        Align = alTop
        Caption = 'Switch USB configuration to DIAG+ADB or trigger manufacturer engineering dialer'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12959408
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        StyleElements = []
      end
      object gpDiagButtons: TGridPanel
        AlignWithMargins = True
        Left = 10
        Top = 48
        Width = 668
        Height = 44
        Margins.Left = 10
        Margins.Top = 4
        Margins.Right = 10
        Margins.Bottom = 8
        Align = alBottom
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
            Control = btnEnableDiag
            Row = 0
          end
          item
            Column = 1
            Control = btnOpenSecretDialer
            Row = 0
          end>
        ParentBackground = False
        RowCollection = <
          item
            Value = 100.000000000000000000
          end>
        TabOrder = 0
        StyleElements = []
        object btnEnableDiag: TButton
          AlignWithMargins = True
          Left = 2
          Top = 2
          Width = 330
          Height = 40
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'ENABLE DIAG (ROOT / SETPROP)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = btnEnableDiagClick
        end
        object btnOpenSecretDialer: TButton
          AlignWithMargins = True
          Left = 336
          Top = 2
          Width = 330
          Height = 40
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          Caption = 'OPEN OEM SECRET DIALER'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = btnOpenSecretDialerClick
        end
      end
    end
  end
end
