# Doot

Doot is the unified business manager for the DootDelivery service.

Targets:
- Android
- iOS / iPadOS
- Windows
- macOS
- Web

## Current modules
- Admin login
- Dashboard
- Products
- Product photo upload to Firestore as compressed/base64 data
- Orders
- Order status
- Sales total
- Delivery settings display

## Firebase
The project points to the existing `doot-delivery` Firebase project.

IMPORTANT:
The Firebase API-key error seen in the old web admin must be resolved on the Firebase side before authentication can work. The app does not bypass Firebase authentication.

For real Android/iOS/macOS Firebase registration, use FlutterFire CLI once:
1. Install Flutter.
2. `dart pub global activate flutterfire_cli`
3. `flutterfire configure`
4. Select `doot-delivery`.
5. Select Android/iOS/macOS/Web as required.
6. Replace `lib/firebase_options.dart` with the generated file.

## Build
flutter pub get
flutter run

Android:
flutter build apk --release

Windows:
flutter build windows --release

Web:
flutter build web --release

iOS/macOS builds require Apple tooling/signing on macOS.
