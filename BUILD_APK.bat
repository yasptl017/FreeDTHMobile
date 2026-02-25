@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

echo.
echo ================================================
echo   FreeDTH Mobile APK Builder
echo   Folder: %CD%
echo ================================================
echo.

where flutter >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter is not installed or not in PATH.
    echo Install Flutter SDK and Android toolchain first:
    echo https://docs.flutter.dev/get-started/install/windows/mobile
    pause
    exit /b 1
)

flutter --version
if errorlevel 1 (
    echo [ERROR] Flutter command failed.
    pause
    exit /b 1
)

if not exist "android\app\src\main\AndroidManifest.xml" (
    echo [STEP] Creating Android project files...
    flutter create . --platforms=android
    if errorlevel 1 (
        echo [ERROR] flutter create failed.
        pause
        exit /b 1
    )
)

if exist "tools\ensure_manifest_permission.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "tools\ensure_manifest_permission.ps1"
)

echo [STEP] Downloading Dart/Flutter packages...
flutter pub get
if errorlevel 1 (
    echo [ERROR] flutter pub get failed.
    pause
    exit /b 1
)

echo [STEP] Building release APK...
flutter build apk --release
if errorlevel 1 (
    echo [ERROR] APK build failed.
    pause
    exit /b 1
)

if exist "%CD%\build\app\outputs\flutter-apk\app-release.apk" (
    echo.
    echo +====================================================+
    echo ^| APK BUILD COMPLETE                                ^|
    echo ^| build\app\outputs\flutter-apk\app-release.apk    ^|
    echo +====================================================+
    explorer /select,"%CD%\build\app\outputs\flutter-apk\app-release.apk"
) else (
    echo [WARN] Build succeeded but APK not found in expected path.
)

echo.
pause
endlocal
exit /b 0
