
import 'package:firebase_core/firebase_core.dart'
    show FirebaseOptions;
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
      case TargetPlatform.linux:
        return windows;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA0cx3zs7ronUP_Nh1dH-ZjVfDGrECMI_g',
    appId: '1:771238210735:web:82fc817bd02cdde8ed385a',
    messagingSenderId: '771238210735',
    projectId: 'doot-delivery',
    authDomain: 'doot-delivery.firebaseapp.com',
    storageBucket: 'doot-delivery.firebasestorage.app',
    measurementId: 'G-94ZTPMFMVC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA0cx3zs7ronUP_Nh1dH-ZjVfDGrECMI_g',
    appId: '1:771238210735:android:82fc817bd02cdde8ed385a',
    messagingSenderId: '771238210735',
    projectId: 'doot-delivery',
    storageBucket: 'doot-delivery.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA0cx3zs7ronUP_Nh1dH-ZjVfDGrECMI_g',
    appId: '1:771238210735:ios:82fc817bd02cdde8ed385a',
    messagingSenderId: '771238210735',
    projectId: 'doot-delivery',
    storageBucket: 'doot-delivery.firebasestorage.app',
    iosBundleId: 'com.dootdelivery.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA0cx3zs7ronUP_Nh1dH-ZjVfDGrECMI_g',
    appId: '1:771238210735:ios:82fc817bd02cdde8ed385a',
    messagingSenderId: '771238210735',
    projectId: 'doot-delivery',
    storageBucket: 'doot-delivery.firebasestorage.app',
    iosBundleId: 'com.dootdelivery.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA0cx3zs7ronUP_Nh1dH-ZjVfDGrECMI_g',
    appId: '1:771238210735:web:82fc817bd02cdde8ed385a',
    messagingSenderId: '771238210735',
    projectId: 'doot-delivery',
    authDomain: 'doot-delivery.firebaseapp.com',
    storageBucket: 'doot-delivery.firebasestorage.app',
    measurementId: 'G-94ZTPMFMVC',
  );
}
