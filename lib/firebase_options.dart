import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart';
// show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
        'DefaultFirebaseOptions are not supported for this platform.');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBxIEXCQv8sJLqWuvho5CX-QxBEJV4dLWM',
    appId: '1:385821449936:web:a476031a1b8919624048d5',
    messagingSenderId: '385821449936',
    projectId: 'counter-c0347',
    authDomain: 'counter-c0347.firebaseapp.com',
    storageBucket: 'counter-c0347.firebasestorage.app',
  );

}