// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        // Jika Anda ingin menambahkan iOS, tambahkan konfigurasi di sini
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC20XwLDOSNphCqN1Wk5ypoRoZ2pGecmuo',
    appId: '1:1094877603105:web:7c611c307f794505508a60',
    messagingSenderId: '1094877603105',
    projectId: 'resepkita-apps',
    authDomain: 'resepkita-apps.firebaseapp.com',
    databaseURL: 'https://resepkita-apps-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'resepkita-apps.firebasestorage.app',
    measurementId: 'G-1QPLCWBSFT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCJkEGFf9S0BnqkDW7NAxRSkPa_cAUDmMs',
    appId: '1:1094877603105:android:0290e1cb68ad23f1508a60',
    messagingSenderId: '1094877603105',
    projectId: 'resepkita-apps',
    databaseURL: 'https://resepkita-apps-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'resepkita-apps.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC20XwLDOSNphCqN1Wk5ypoRoZ2pGecmuo',
    appId: '1:1094877603105:web:f867b41ca13e57c2508a60',
    messagingSenderId: '1094877603105',
    projectId: 'resepkita-apps',
    authDomain: 'resepkita-apps.firebaseapp.com',
    databaseURL: 'https://resepkita-apps-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'resepkita-apps.firebasestorage.app',
    measurementId: 'G-YB2RXETD13',
  );

}