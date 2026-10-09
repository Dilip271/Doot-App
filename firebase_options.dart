import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return windows;
      default:
        return web;
    }
  }

  // Existing Doot Firebase Web configuration.
  static const web = FirebaseOptions(
    apiKey: 'AIzaSyA0cx3zs7ronUP_Nh1dH-ZjVfDGrECMI_g',
    appId: '1:771238210735:web:82fc817bd02cdde8ed385a',
    messagingSenderId: '771238210735',
    projectId: 'doot-delivery',
    authDomain: 'doot-delivery.firebaseapp.com',
    storageBucket: 'doot-delivery.firebasestorage.app',
    measurementId: 'G-94ZTPMFMVC',
  );

  // Native entries intentionally mirror the same Firebase project.
  // If Firebase asks for native app registration, run:
  // flutterfire configure
  // and replace this file with the generated firebase_options.dart.
  static const android = FirebaseOptions(
    apiKey: web.apiKey,
    appId: '1:771238210735:android:82fc817bd02cdde8ed385a',
    messagingSenderId: web.messagingSenderId,
    projectId: web.projectId,
    storageBucket: web.storageBucket,
  );

  static const ios = FirebaseOptions(
    apiKey: web.apiKey,
    appId: '1:771238210735:ios:82fc817bd02cdde8ed385a',
    messagingSenderId: web.messagingSenderId,
    projectId: web.projectId,
    storageBucket: web.storageBucket,
    iosBundleId: 'com.dootdelivery.app',
  );

  static const macos = FirebaseOptions(
    apiKey: web.apiKey,
    appId: '1:771238210735:ios:82fc817bd02cdde8ed385a',
    messagingSenderId: web.messagingSenderId,
    projectId: web.projectId,
    storageBucket: web.storageBucket,
    iosBundleId: 'com.dootdelivery.app',
  );

  static const windows = web;
}
