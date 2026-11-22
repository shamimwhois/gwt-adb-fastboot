# GWT ADB & Fastboot Tool v1.2

A professional, high-performance Android service and flashing utility written in **100% Native Delphi 13 (RAD Studio 37.0)** with **Zero External CLI Dependencies** (`adb.exe` / `fastboot.exe` not required).

---

## Key Features

- **100% Native Protocol Communication**:
  - Communicates directly with Android devices via WinUSB bulk endpoints and Windows SetupAPI (`WinUsb.dll` + `SetupAPI.dll`).
  - Full native ADB packet framing with automatic RSA authentication handshake.
  - Native Fastboot engine supporting text request/response protocol and 1MB chunked raw binary downloads.
  - Dual-engine fallback: automatically leverages ADB loopback socket daemon or raw WinUSB bulk transport.
- **Three Core Modes**:
  - **ADB Mode**:
    - Universal Read Device Info (Manufacturer, Model, Brand, Android Version, SDK, Security Patch, CPU, Serial, Battery).
    - ADB FRP Reset (Settings Secure Content Provider bypass).
    - Reboot controls: Fastboot, Recovery, EDL (Qualcomm 9008), System.
    - Brand Suites: Xiaomi (MIUI version, Mi Account bypass, Qualcomm Diag, ad removal), Vivo (Funtouch OS, model, BSP, factory reset, diag, demo mode removal), Huawei (EMUI build, Manufacture Mode, FRP reset).
  - **Fastboot Mode**:
    - **Service Tab**: Huawei 16-digit FRP unlock, Xiaomi OEM unlock/relock/EDL, Vivo BBK bootloader unlock, universal userdata wipe.
    - **Flash Tab**: Full Xiaomi Fastboot ROM multi-partition flasher + Universal single partition flasher.
  - **Recovery Mode**:
    - **Service Tab**: Xiaomi Mi Assistant sideload, Huawei eRecovery, Vivo Recovery, general reboot utilities.
    - **Flash Tab**: Recovery ADB Sideload flasher for OTA updates, custom ZIPs, and Magisk root packages.
- **Sleek & Compact GSM UI**:
  - Compact 30px–34px button heights and space-efficient card containers.
  - Real-time USB connection status and timestamped color-coded logs.
  - Real-time automatic device arrival and removal detection (`WM_DEVICECHANGE`).

---

## Project Structure

```
adb-fastboot/
├── CHANGELOG.md
├── README.md
├── .gitignore
├── gwt_adb_fastboot_tool_delphi_13_native_protocol_documentation.md
├── GWT_Tool.exe                          # Standalone Win32 Release Executable
└── GWT_Tool/
    ├── Build.bat                         # Automated Win32 & Win64 compilation script
    ├── GWT_Tool.dpr                      # Delphi Application Entry Point
    ├── GWT_Tool.dproj                    # Delphi Project File
    ├── Core/
    │   └── GWT.Types.pas                 # Shared types, records, and constants
    ├── Protocols/
    │   ├── GWT.WinUSB.API.pas            # WinUSB & SetupAPI direct DLL headers
    │   ├── GWT.WinUSB.Transport.pas      # Bulk pipe transport layer & device scanner
    │   ├── GWT.Protocol.ADB.pas          # Native ADB packet engine & RSA handshake
    │   └── GWT.Protocol.Fastboot.pas     # Native Fastboot command & download engine
    ├── Services/
    │   └── GWT.CommandService.pas        # Central async operation orchestrator
    ├── Frames/
    │   ├── Frame.AdbService.pas/.dfm     # ADB workspace & brand cards
    │   ├── Frame.FastbootService.pas/.dfm# Fastboot service workspace
    │   ├── Frame.FastbootFlash.pas/.dfm  # Fastboot partition & ROM flasher
    │   ├── Frame.RecoveryService.pas/.dfm# Recovery service workspace
    │   └── Frame.RecoveryFlash.pas/.dfm  # Recovery sideload ZIP flasher
    └── UI/
        ├── Form.Main.pas                 # Main application window logic
        └── Form.Main.dfm                 # VCL form layout
```

---

## Building from Source

### Prerequisites
- **Embarcadero Delphi 13 / RAD Studio 37.0** (or compatible Delphi compiler `dcc32` / `dcc64`).
- Windows 10 / 11 (x86 or x64).

### Automated Build
Run the included build batch script:
```cmd
cd GWT_Tool
Build.bat
```
This produces optimized Release binaries:
- `Win32\Release\GWT_Tool.exe` (32-bit standalone)
- `Win64\Release\GWT_Tool.exe` (64-bit standalone)

---

## License
Proprietary / All Rights Reserved. Built for professional GSM servicing.
