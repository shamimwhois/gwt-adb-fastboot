# GWT ADB & Fastboot Tool v1.0

[![Release](https://img.shields.io/github/v/release/shamimwhois/gwt-adb-fastboot?color=blue&label=Release)](https://github.com/shamimwhois/gwt-adb-fastboot/releases/latest)
[![Platform](https://img.shields.io/badge/Platform-Windows%20(x86%20%7C%20x64)-0078D6?logo=windows)](https://github.com/shamimwhois/gwt-adb-fastboot)
[![Language](https://img.shields.io/badge/Language-Delphi%2013%20%2F%20RAD%20Studio%2037.0-E62432)](https://www.embarcadero.com/)
[![License](https://img.shields.io/badge/License-Proprietary-yellow)](https://github.com/shamimwhois/gwt-adb-fastboot)

A professional, high-performance Android servicing and firmware flashing desktop utility built in **100% Native Delphi 13 (RAD Studio 37.0)**.

Featuring **Zero External CLI Dependencies** (`adb.exe` / `fastboot.exe` are completely unnecessary): all low-level USB bulk transfers, packet framing, RSA public key authorization, and Fastboot binary streaming are handled directly by native Windows API drivers (`WinUsb.dll` + `SetupAPI.dll`).

---

## ⚡ Quick Download

Download the official standalone release from the [Releases](https://github.com/shamimwhois/gwt-adb-fastboot/releases/tag/v1.0) page:
- **[GWT_Tool_v1.0_Win32.zip](https://github.com/shamimwhois/gwt-adb-fastboot/releases/download/v1.0/GWT_Tool_v1.0_Win32.zip)** (32-bit Standalone Portable)
- **[GWT_Tool_v1.0_x64.zip](https://github.com/shamimwhois/gwt-adb-fastboot/releases/download/v1.0/GWT_Tool_v1.0_x64.zip)** (64-bit Standalone Portable)

*(Portable application — no installation or driver setup required)*

---

## 🚀 Key Architectural Features

- **100% Native Delphi Protocol Engines**:
  - Communicates directly with Android endpoints via WinUSB bulk pipes using Windows API (`WinUsb.dll` and `SetupAPI.dll`).
  - Full native ADB packet framing (`A_CNXN`, `A_AUTH`, `A_OPEN`, `A_OKAY`, `A_CLSE`, `A_WRTE`).
  - Native RSA Authentication Handshake sending `A_AUTH_RSAPUBLICKEY` loaded automatically from `%USERPROFILE%\.android\adbkey.pub` or built-in fallback.
  - Native Fastboot engine supporting text request/response parsing and 1MB chunked raw binary downloads (`download:<hex_len>`).
- **Dual-Engine Protocol Dispatcher**:
  - Automatically queries loopback ADB daemon socket (`127.0.0.1:5037`) when available.
  - Seamlessly falls back to direct raw WinUSB bulk transport when socket is closed or unavailable.
- **Three Core Workspace Modes**:
  - **ADB Mode**:
    - **Service Tab**:
      - Universal Read Device Info (Manufacturer, Model, Brand, Android Version, SDK, Security Patch, CPU Platform, Serial Number, Battery Level).
      - ADB FRP Reset (Settings Secure Content Provider bypass).
      - Device Reboot Controls: Fastboot, Recovery, EDL (Qualcomm 9008), System.
      - Specialized Brand Cards:
        - **Xiaomi**: Read MIUI version, bypass Mi Account/Cloud services, enable Qualcomm Diag port (`*#*#717717#*#*`), disable analytics daemons (`msa`).
        - **Vivo**: Read Funtouch/OriginOS version, Vivo internal model, BSP version, safe factory reset, enable diagnostic mode, remove demo mode.
        - **Huawei**: Read EMUI build, enable Manufacture Mode (`*#*#2846579#*#*`), ADB FRP reset.
    - **Network Unlock & IMEI Tab (Brand & Model-Driven)**:
      - **Brand & Model Filtering**: Pre-loaded series presets for Samsung, Xiaomi, Vivo, Huawei, Oppo/Realme, Transsion (Tecno/Infinix/Itel), MTK Generic, QCOM Generic, and Unisoc.
      - **Dual IMEI Repair & Validation**:
        - Automatic ISO/IEC 7812-1 **Luhn Checksum Algorithm** verification and check-digit generation.
        - Read IMEI 1 and IMEI 2 via property injection and radio TTYs.
        - Safe IMEI write with automatic pre-flight EFS/NVRAM security partition backup.
        - Built-in valid Test IMEI generator.
      - **Network & Carrier Unlock**:
        - Direct SIM de-personalization and carrier lock removal.
        - Baseband recovery tool to fix "Unknown Baseband" and null IMEI.
      - **EFS & NVRAM Security Partitions**:
        - Dump `modemst1`, `modemst2`, `fsg`, `nvram`, `nvdata` block partitions to `/sdcard/GWT_*.img`.
        - Native modem & RILD daemon restart.
      - **Diagnostic (DIAG) Port Controls**:
        - Root/Setprop activation (`diag,adb`) + OEM secret dialers (`*#0808#`, `*#*#717717#*#*`, `*#*#2846579#*#*`, `*#558#`, `*#801#`).
  - **Fastboot Mode**:
    - **Service Tab**: Huawei 16-digit FRP factory unlock (`oem frp-unlock <key>`), Xiaomi OEM unlock/relock/EDL reboot, Vivo BBK bootloader unlock (`bbk unlock_vivo`), and universal userdata formatting.
    - **Flash Tab**: Full Xiaomi Fastboot ROM automated multi-partition flasher + Universal partition flasher (`boot`, `recovery`, `vbmeta`, `super`, `system`, `vendor`, `cust`, `dtbo`).
  - **Recovery Mode**:
    - **Service Tab**: Xiaomi Mi Assistant sideload communication, Huawei eRecovery, Vivo Recovery, general reboot utilities.
    - **Flash Tab**: Recovery ADB Sideload flasher for OTA update packages, custom ROM ZIPs, and Magisk root packages.
- **Compact & Sleek GSM UI**:
  - Compact button heights (30px–34px) with tight 2px padding.
  - Space-efficient cards (98px–142px) with dark GSM aesthetic.
  - Real-time USB connection status pill and timestamped color-coded logs.
  - Automatic hardware arrival and removal notifications via Windows `WM_DEVICECHANGE`.

---

## 📁 Repository Structure

```
gwt-adb-fastboot/
├── CHANGELOG.md                          # Version changelog
├── README.md                             # Project documentation
├── .gitignore                            # Delphi gitignore configuration
├── Build.bat                             # Automated Win32 & Win64 compilation script
├── GWT_Tool.dpr                          # Delphi Application Entry Point
├── GWT_Tool.dproj                        # Delphi Project File
├── GWT_Tool.rc / .res                    # Application resources and manifests
├── Core/
│   └── GWT.Types.pas                     # Shared types, records, and constants
├── Protocols/
│   ├── GWT.WinUSB.API.pas                # WinUSB & SetupAPI direct DLL headers
│   ├── GWT.WinUSB.Transport.pas          # Bulk pipe transport layer & device scanner
│   ├── GWT.Protocol.ADB.pas              # Native ADB packet engine & RSA handshake
│   └── GWT.Protocol.Fastboot.pas         # Native Fastboot command & download engine
├── Services/
│   └── GWT.CommandService.pas            # Central async operation orchestrator
├── Frames/
│   ├── Frame.AdbService.pas/.dfm         # ADB service workspace & brand cards
│   ├── Frame.AdbNetworkUnlock.pas/.dfm   # ADB Network Unlock & IMEI Repair module
│   ├── Frame.FastbootService.pas/.dfm    # Fastboot service workspace
│   ├── Frame.FastbootFlash.pas/.dfm      # Fastboot partition & ROM flasher
│   ├── Frame.RecoveryService.pas/.dfm    # Recovery service workspace
│   └── Frame.RecoveryFlash.pas/.dfm      # Recovery sideload ZIP flasher
└── UI/
    ├── Form.Main.pas                     # Main application window logic
    └── Form.Main.dfm                     # VCL form layout
```

---

## 🛠️ Building from Source

### Prerequisites
- **Embarcadero Delphi 13 / RAD Studio 37.0** (or compatible `dcc32` / `dcc64`).
- Windows 10 / 11 (x86 or x64).

### Automated Compilation
Run `Build.bat` directly from the project root:
```cmd
Build.bat
```
This generates optimized standalone Release binaries:
- `Win32\Release\GWT_Tool.exe` (32-bit standalone)
- `Win64\Release\GWT_Tool.exe` (64-bit standalone)

---

## 📄 License
Proprietary / All Rights Reserved. Built for professional GSM servicing.
