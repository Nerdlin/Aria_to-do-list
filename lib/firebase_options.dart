import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return web;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyChPDSdTAJguxPuX1gf1AdFPtaSGwOfVtg',
    appId: '1:78415977018:web:e0003af9019ac50f2a3303',
    messagingSenderId: '78415977018',
    projectId: 'ariaapp-ae1cc',
    authDomain: 'ariaapp-ae1cc.firebaseapp.com',
    storageBucket: 'ariaapp-ae1cc.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyChPDSdTAJguxPuX1gf1AdFPtaSGwOfVtg',
    appId: '1:78415977018:android:e0003af9019ac50f2a3303',
    messagingSenderId: '78415977018',
    projectId: 'ariaapp-ae1cc',
    storageBucket: 'ariaapp-ae1cc.firebasestorage.app',
  );
}
