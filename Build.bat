@echo off
setlocal
echo ===================================================
echo  Building GWT ADB ^& Fastboot Tool v1.0 (Delphi 13)
echo ===================================================

set RAD_BIN=D:\studio\rad\37.0\bin
set RAD_LIB32=D:\studio\rad\37.0\lib\win32\release
set RAD_LIB64=D:\studio\rad\37.0\lib\win64\release

if not exist GWT_Tool.res (
  echo Compiling resources...
  "%RAD_BIN%\brcc32.exe" GWT_Tool.rc
)

if not exist "Win32\Release" mkdir "Win32\Release"
if not exist "Win64\Release" mkdir "Win64\Release"

echo.
echo Compiling 32-bit (Win32)...
"%RAD_BIN%\dcc32.exe" -B -Q -NU"Win32\Release" -E"Win32\Release" "-ICore;Protocols;Services;Frames;UI" "-UCore;Protocols;Services;Frames;UI;%RAD_LIB32%" GWT_Tool.dpr
if %ERRORLEVEL% NEQ 0 (
  echo [ERROR] 32-bit build failed.
  exit /b %ERRORLEVEL%
)
copy /y "Win32\Release\GWT_Tool.exe" "GWT_Tool.exe" >nul
echo [SUCCESS] 32-bit build finished: Win32\Release\GWT_Tool.exe

echo.
echo Compiling 64-bit (Win64)...
"%RAD_BIN%\dcc64.exe" -B -Q -NU"Win64\Release" -E"Win64\Release" "-ICore;Protocols;Services;Frames;UI" "-UCore;Protocols;Services;Frames;UI;%RAD_LIB64%" GWT_Tool.dpr
if %ERRORLEVEL% NEQ 0 (
  echo [ERROR] 64-bit build failed.
  exit /b %ERRORLEVEL%
)
echo [SUCCESS] 64-bit build finished: Win64\Release\GWT_Tool.exe

echo.
echo Build completed successfully.
if "%1" NEQ "nopause" pause
