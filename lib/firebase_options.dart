// File generated using information from google-services.json
// This file provides Firebase configuration for all platforms

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCgIuhcFw87ei_bjnP-Jj6PeYopdt2KYlo',
    appId: '1:333190680693:android:f413f267c86afb64e6283c',
    messagingSenderId: '333190680693',
    projectId: 'pkdriver-and',
    storageBucket: 'pkdriver-and.firebasestorage.app',
    databaseURL: 'https://pkdriver-and-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCgIuhcFw87ei_bjnP-Jj6PeYopdt2KYlo',
    appId: '1:333190680693:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '333190680693',
    projectId: 'pkdriver-and',
    storageBucket: 'pkdriver-and.firebasestorage.app',
    databaseURL: 'https://pkdriver-and-default-rtdb.firebaseio.com',
    iosBundleId: 'com.zeework.aadist',
  );
}

