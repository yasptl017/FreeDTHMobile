# FreeDTH Mobile (APK)

This folder contains a Flutter mobile app version with:
- App bar
- Center video content
- In-screen playback controls: play, pause, stop
- Forward/backward seek
- Playback speed control

## Build APK

1. Install Flutter + Android SDK:
   https://docs.flutter.dev/get-started/install/windows/mobile
2. Open this folder in terminal:
   `F:\Laravel\JB\FreeDTHMobile`
3. Run:
   `BUILD_APK.bat`

APK output:
`build\app\outputs\flutter-apk\app-release.apk`

## Build APK In Cloud (No Local Flutter/Studio)

1. Push this repository to GitHub.
2. Open GitHub -> `Actions` -> `Build Android APK`.
3. Click `Run workflow`.
4. After completion, open the run and download artifact:
   `FreeDTHMobile-release-apk`

Workflow file:
`.github/workflows/build-android-apk.yml`

## Notes

- `BUILD_APK.bat` auto-runs `flutter create` if Android project files are missing.
- INTERNET permission is added automatically for network streams.
- For live streams, seek forward/back may be limited by stream provider.
