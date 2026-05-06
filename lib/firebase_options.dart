// File generated manually from Firebase project moodnest-jatin.
// flutterfire configure failed on iOS step due to missing xcodeproj gem.

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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAwHDMSFCe8LHMssXTBrU2jJj-yRLPUPmA',
    appId: '1:1067689461262:web:44038688a6141d5e25de5f',
    messagingSenderId: '1067689461262',
    projectId: 'moodnest-jatin',
    authDomain: 'moodnest-jatin.firebaseapp.com',
    storageBucket: 'moodnest-jatin.firebasestorage.app',
    measurementId: 'G-DZGS577FVE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA8K073B1qFIhN5OXsU6BDtWgnWiXOjtAs',
    appId: '1:1067689461262:android:158033c81979663a25de5f',
    messagingSenderId: '1067689461262',
    projectId: 'moodnest-jatin',
    storageBucket: 'moodnest-jatin.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBGG1gJ8SAPQMMZnWxuAA4NglyJ2IcBtsQ',
    appId: '1:1067689461262:ios:080b1a52f83cf9b425de5f',
    messagingSenderId: '1067689461262',
    projectId: 'moodnest-jatin',
    storageBucket: 'moodnest-jatin.firebasestorage.app',
    iosBundleId: 'com.example.moodnest',
  );
}
