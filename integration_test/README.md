Integration tests for gestion_hotel

Overview
--------
This folder contains integration tests for the hotel app (Phase 3). Tests assume you run the Firebase Emulator Suite (Firestore + Auth) locally to avoid touching production data.

Files
-----
- driver.dart - integration_test driver used with `flutter drive`.
- room_flow_test.dart - UI test that covers add/edit/delete of rooms as admin.
- reservation_flow_test.dart - UI test that covers booking a room as a normal user and verifies Firestore documents.
- app_test.dart - (optional) basic app start smoke test.

Prerequisites
-------------
- Flutter SDK installed (stable).
- Firebase CLI installed and configured.
- Android SDK / emulator OR a real Android device connected.
- Run the Firebase emulator (Firestore & Auth) locally.

Start Firebase emulator (recommended)
-----------------------------------
From your project directory with a valid `firebase.json`/project setup, run:

```bash
firebase emulators:start --only firestore,auth
```

Default ports used by tests:
- Firestore emulator: localhost:8080
- Auth emulator: localhost:9099

If you use different ports, edit the test files to point to the correct host/ports.

Run tests on Android emulator/device
-----------------------------------
1. Start an Android emulator or connect a device.
2. Start the Firebase emulators (see above).
3. Run the tests with `flutter drive`:

```powershell
flutter drive --driver=integration_test/driver.dart --target=integration_test/room_flow_test.dart -d android
flutter drive --driver=integration_test/driver.dart --target=integration_test/reservation_flow_test.dart -d android
```

Note: `flutter drive` launches the app on the device and runs the integration test. Each `--target` runs a single test file. You can script them together.

Run tests on Chrome (experimental / may be unsupported)
------------------------------------------------------
Web integration tests are partially supported. If your setup supports web-drive, you can try:

```powershell
flutter drive --driver=integration_test/driver.dart --target=integration_test/room_flow_test.dart -d chrome
```

If that fails with "Web devices are not supported for integration tests yet", run the tests on Android instead.

CI (GitHub Actions) snippet
---------------------------
Below is an example workflow for GitHub Actions to run the tests on an Android emulator and the Firebase emulator.

```yaml
name: integration-tests
on: [push, pull_request]
jobs:
  integration:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'
      - name: Install Firebase CLI
        run: curl -sL https://firebase.tools | bash
      - name: Start Firebase emulators
        run: |
          firebase setup:web
          firebase emulators:start --only firestore,auth &
      - name: Start emulator
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 31
          target: google_apis
          arch: x86_64
          emulator-options: -no-window
      - name: Run integration tests
        run: |
          flutter drive --driver=integration_test/driver.dart --target=integration_test/room_flow_test.dart -d emulator-5554
          flutter drive --driver=integration_test/driver.dart --target=integration_test/reservation_flow_test.dart -d emulator-5554
```

Notes & Caveats
---------------
- Tests expect the app to use the Firebase emulator endpoints. The test files set emulators to `localhost:8080` (Firestore) and `localhost:9099` (Auth). Ensure these ports are free and emulators are started.
- UI tests rely on Keys added to widgets (see `lib/screens/rooms/*` and `lib/widgets/room_card.dart`). If you change widget structure, update the tests accordingly.
- For production-level CI, secure service accounts and environment configs are needed.

If you want, I can also generate GitHub Actions with matrix runs and upload them to `.github/workflows/`.
