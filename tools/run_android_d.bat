@echo off
setlocal

set "PROJECT_DIR=%~dp0.."
pushd "%PROJECT_DIR%"

set "APPDATA=%PROJECT_DIR%\.runtime\appdata"
set "LOCALAPPDATA=%PROJECT_DIR%\.runtime\localappdata"
set "PUB_CACHE=%PROJECT_DIR%\.runtime\pub-cache"
set "GRADLE_USER_HOME=%PROJECT_DIR%\.runtime\gradle"
set "FLUTTER_ROOT=%PROJECT_DIR%\.runtime\flutter"
set "JAVA_HOME=%PROJECT_DIR%\.runtime\jdk\jdk-17.0.19+10"
set "ANDROID_HOME=%PROJECT_DIR%\.runtime\android-sdk"
set "ANDROID_SDK_ROOT=%PROJECT_DIR%\.runtime\android-sdk"
set "ANDROID_AVD_HOME=%PROJECT_DIR%\.runtime\avd"
set "PATH="
set "Path=%FLUTTER_ROOT%\bin\mingit\cmd;%FLUTTER_ROOT%\bin;%JAVA_HOME%\bin;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\emulator;C:\Windows\System32;C:\Windows;C:\Windows\System32\WindowsPowerShell\v1.0"

if not exist "%APPDATA%" mkdir "%APPDATA%"
if not exist "%LOCALAPPDATA%" mkdir "%LOCALAPPDATA%"
if not exist "%PUB_CACHE%" mkdir "%PUB_CACHE%"
if not exist "%GRADLE_USER_HOME%" mkdir "%GRADLE_USER_HOME%"

"%FLUTTER_ROOT%\bin\cache\dart-sdk\bin\dart.exe" pub get --offline
if errorlevel 1 (
  popd
  endlocal
  exit /b 1
)

pushd "%PROJECT_DIR%\android"
call gradlew.bat :app:assembleDebug -Ptarget-platform=android-x64 --no-daemon
if errorlevel 1 (
  popd
  popd
  endlocal
  exit /b 1
)
popd

"%ANDROID_HOME%\platform-tools\adb.exe" install -r "%PROJECT_DIR%\build\app\outputs\flutter-apk\app-debug.apk"
if errorlevel 1 (
  popd
  endlocal
  exit /b 1
)

"%ANDROID_HOME%\platform-tools\adb.exe" shell am force-stop com.example.monex
"%ANDROID_HOME%\platform-tools\adb.exe" shell monkey -p com.example.monex 1

popd
endlocal
