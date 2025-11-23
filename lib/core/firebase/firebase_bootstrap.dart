import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

bool _firebaseInitialized = false;

Future<void> initFirebase() async {
  if (_firebaseInitialized) return;
  try {
    if (kIsWeb) {
      const webOptions = FirebaseOptions(
        apiKey: 'AIzaSyDDz6DiXIALuJ17Cd1PzxAMwxgnKin4w1Q',
        authDomain: 'kissan-cae04.firebaseapp.com',
        projectId: 'kissan-cae04',
        storageBucket: 'kissan-cae04.firebasestorage.app',
        messagingSenderId: '536548674493',
        appId: '1:536548674493:web:44abb0651a3ea03c21e0d4',
        measurementId: 'G-DRE65EQZYF',
      );
      await Firebase.initializeApp(options: webOptions);
    } else {
      // For mobile/desktop, expect google-services files after flutterfire configure.
      // Initialize without explicit options; if not configured yet, this will throw and be caught.
      await Firebase.initializeApp();
    }
    _firebaseInitialized = true;
  } catch (e) {
    if (kDebugMode) {
      // Log but don’t crash the app; configuration may be completed later.
      // ignore: avoid_print
      print('Firebase init failed: $e');
    }
  }
}

Future<void> ensureSignedIn() async {
  try {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
  } catch (e) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('Anonymous sign-in failed: $e');
    }
  }
}
