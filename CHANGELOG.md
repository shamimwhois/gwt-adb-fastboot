# Changelog

All notable changes to the **GWT ADB & Fastboot Tool** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.1.0] - 2026-11-23

### Added
- **ADB Network Unlock & IMEI Repair Module (`Frame.AdbNetworkUnlock`)**:
  - **Dynamic Brand & Model Filtering**: Pre-loaded series presets for Samsung, Xiaomi, Vivo, Huawei, Oppo/Realme, Transsion (Tecno/Infinix/Itel), MTK Generic, QCOM Generic, and Unisoc.
  - **Dual IMEI Repair & Validation**:
    - Built-in ISO/IEC 7812-1 **Luhn Checksum Algorithm** with real-time check-digit calculation and live validity badge indicators.
    - Read IMEI 1 & IMEI 2 directly from properties and radio sub-info endpoints.
    - Safe IMEI write with automatic pre-flight EFS/NVRAM security partition backup.
    - Test IMEI generator for rapid lab verification.
  - **Network & Carrier Unlock Engine**:
    - Direct SIM de-personalization bypass via manufacturer radio AT sequences.
    - Carrier policy unlock flags management.
    - Baseband recovery tool to resolve null IMEI and "Unknown Baseband" crashes.
  - **EFS & NVRAM Security Partitions**:
    - Automated dump of `modemst1`, `modemst2`, `fsg`, `fsc`, `nvram`, `nvdata`, `secro` partitions to `/sdcard/GWT_*.img`.
    - Automated modem & RILD daemon restart sequence.
  - **Diagnostic (DIAG) Port Switcher**:
    - USB configuration switching to `diag,adb` via root/setprop.
    - Manufacturer engineering secret dialers (`*#0808#`, `*#*#717717#*#*`, `*#*#2846579#*#*`, `*#558#`, `*#801#`).

### Changed
- **Unified Sub-Tab Navigation System**:
  - Sub-tabs are now permanently available across all modes (`ADB`, `FASTBOOT`, `RECOVERY`).
  - ADB mode features `[SERVICE]` and `[NETWORK UNLOCK & IMEI]`.
  - Fastboot mode features `[SERVICE]` and `[FLASH]`.
  - Recovery mode features `[SERVICE]` and `[FLASH / SIDELOAD]`.

---

## [1.0.0] - 2026-11-23

### Added
- **100% Native Delphi Protocol Engine (Zero External CLI Dependency)**:
  - Native WinUSB bulk endpoints communication using direct Windows API (`WinUsb.dll` + `SetupAPI.dll`).
  - Native ADB packet framing (`A_CNXN`, `A_AUTH`, `A_OPEN`, `A_OKAY`, `A_CLSE`, `A_WRTE`).
  - Automatic RSA authentication handler sending `A_AUTH_RSAPUBLICKEY` loaded from `%USERPROFILE%\.android\adbkey.pub` or built-in fallback.
  - Native Fastboot protocol engine supporting text requests/responses (`OKAY`, `FAIL`, `DATA`, `INFO`, `TEXT`) and 1MB chunked raw binary downloads (`download:<hex_len>`).
- **Dual-Engine Protocol Dispatcher**:
  - Automatically queries loopback ADB socket daemon (`127.0.0.1:5037`) for high-fidelity device metadata.
  - Seamlessly falls back to direct raw WinUSB bulk transport when socket or daemon is unavailable.
- **Brand-Specific Engineering Suites**:
  - **Xiaomi**:
    - ADB: Read MIUI version, bypass Mi Account/Cloud services, enable Qualcomm Diag port (`*#*#717717#*#*`), disable analytics bloatware (`msa`).
    - Fastboot: Read anti-rollback index (`anti`), OEM unlock/relock bootloader, reboot to EDL mode (Qualcomm 9008), safe userdata wipe, and full Fastboot ROM automated flasher.
    - Recovery: Mi Assistant sideload communication, cloud association reset, safe factory wipe.
  - **Vivo**:
    - ADB: Read Funtouch/OriginOS version, Vivo internal model, BSP version, safe factory reset, enable diagnostic mode, remove retail/demo mode.
    - Fastboot: Read Vivo board info, BBK bootloader unlock (`bbk unlock_vivo`), format userdata.
    - Recovery: Recovery parameter inspector, safe userdata format.
  - **Huawei**:
    - ADB: Read EMUI / HarmonyOS build, enable Manufacture Mode (`*#*#2846579#*#*`), ADB FRP reset.
    - Fastboot: Factory 16-digit token FRP unlock (`oem frp-unlock <key>`), OEM info inspection, relock bootloader, format userdata & cache.
    - Recovery: eRecovery parameter inspection, wipe data/factory, wipe cache partition.
  - **Universal Operations**:
    - ADB Read Device Info with multi-property batch extraction (Manufacturer, Model, Brand, Android Version, SDK level, Security Patch, CPU Platform, Serial Number, Battery Level).
    - ADB FRP Reset (Settings Secure Content Provider bypass).
    - Universal Fastboot partition flasher (`boot`, `recovery`, `vbmeta`, `super`, `system`, `vendor`, `cust`, `dtbo`).
    - Recovery ADB Sideload flasher for OTA updates, custom ZIPs, and Magisk root packages.
- **Real-Time Auto-Detection**:
  - Hardware interface arrival and removal detection via `WM_DEVICECHANGE` and `RegisterDeviceNotification`.
  - Automatic UI mode switching on device state transition (e.g. automatically switching to Fastboot tab when device reboots).

### Changed
- **Compact & Sleek GSM UI Overhaul**:
  - Reduced oversized button heights from 56px–64px to standard GSM service tool proportions (30px–34px).
  - Reduced card container heights from 160px–200px to compact 98px–142px with tight 2px padding.
  - Refactored top navigation: 3 primary mode buttons (`ADB`, `FASTBOOT`, `RECOVERY`) with dedicated sub-tabs (`SERVICE`, `FLASH`) for Fastboot and Recovery.
  - Color-coded real-time diagnostic console with timestamped status logs.

### Fixed
- Fixed missing `Application.Run` call in `GWT_Tool.dpr` causing immediate process termination on launch.
- Fixed Delphi compiler `F2048 Bad unit format` error by separating Win32 and Win64 output units (`-NU"Win32\Release"` vs `-NU"Win64\Release"`).
- Fixed `GetString` buffer conversion type mismatch in `GWT.Protocol.ADB.pas` by migrating to dynamic `TBytes` buffer allocation.
- Fixed brand card actions failing when device is connected purely via raw WinUSB by introducing `ExecuteAdbShell` and `ExecuteAdbReboot` unified dispatchers.
- Cleaned legacy source files and history directories.
