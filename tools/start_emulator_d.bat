@echo off
setlocal

set "PROJECT_DIR=%~dp0.."
set "ANDROID_HOME=%PROJECT_DIR%\.runtime\android-sdk"
set "ANDROID_SDK_ROOT=%ANDROID_HOME%"
set "ANDROID_AVD_HOME=%PROJECT_DIR%\.runtime\avd"
set "PATH="
set "Path=%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\emulator;C:\Windows\System32;C:\Windows;C:\Windows\System32\WindowsPowerShell\v1.0"

start "" "%ANDROID_HOME%\emulator\emulator.exe" -avd Medium_Phone -no-snapshot-load

endlocal
