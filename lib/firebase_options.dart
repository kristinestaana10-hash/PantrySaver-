import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDagZ7lR0G76jSqCKuhbkVOM6Gb5-ynooM',
    appId: '1:257156430689:web:0f5865f4e0b704d0b0159b',
    messagingSenderId: '257156430689',
    projectId: 'pantrysaver-ce359',
    authDomain: 'pantrysaver-ce359.firebaseapp.com',
    storageBucket: 'pantrysaver-ce359.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDagZ7lR0G76jSqCKuhbkVOM6Gb5-ynooM',
    appId: '1:257156430689:android:cf7db151819a97f09c6320',
    messagingSenderId: '257156430689',
    projectId: 'pantrysaver-ce359',
    storageBucket: 'pantrysaver-ce359.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDagZ7lR0G76jSqCKuhbkVOM6Gb5-ynooM',
    appId: '1:257156430689:ios:cf7db151819a97f09c6320',
    messagingSenderId: '257156430689',
    projectId: 'pantrysaver-ce359',
    storageBucket: 'pantrysaver-ce359.firebasestorage.app',
    iosBundleId: 'com.pantrysaver.pantrysaver',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDagZ7lR0G76jSqCKuhbkVOM6Gb5-ynooM',
    appId: '1:257156430689:ios:cf7db151819a97f09c6320',
    messagingSenderId: '257156430689',
    projectId: 'pantrysaver-ce359',
    storageBucket: 'pantrysaver-ce359.firebasestorage.app',
    iosBundleId: 'com.pantrysaver.pantrysaver',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDagZ7lR0G76jSqCKuhbkVOM6Gb5-ynooM',
    appId: '1:257156430689:web:0f5865f4e0b704d0b0159b',
    messagingSenderId: '257156430689',
    projectId: 'pantrysaver-ce359',
    storageBucket: 'pantrysaver-ce359.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDagZ7lR0G76jSqCKuhbkVOM6Gb5-ynooM',
    appId: '1:257156430689:web:0f5865f4e0b704d0b0159b',
    messagingSenderId: '257156430689',
    projectId: 'pantrysaver-ce359',
    storageBucket: 'pantrysaver-ce359.firebasestorage.app',
  );
}
