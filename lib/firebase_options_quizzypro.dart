// Firebase options for the `quizzypro` flavor's separate Firebase app
// (same "Quizzy AI" project, distinct Android/iOS app registrations).
// Values sourced from android/app/src/quizzypro/google-services.json and
// ios/config/quizzypro/GoogleService-Info.plist — keep in sync if those change.
//
// The custom auth domain ('auth.quizzyai.app') is NOT set here:
// `FirebaseOptions.authDomain` is a web-only field on native (Android/iOS),
// so it would be silently dropped. It's applied at runtime instead via
// `FirebaseAuth.customAuthDomain` in `FirebaseAuthService`.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptionsQuizzyPro {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptionsQuizzyPro have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptionsQuizzyPro are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAI5VFgJDZ8jDQve17iJkc1zAebKb2psXA',
    appId: '1:897552655477:android:a4ca41f0f8b636ea43043c',
    messagingSenderId: '897552655477',
    projectId: 'quizzy-ai-85865',
    storageBucket: 'quizzy-ai-85865.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAJ6F0d_poQUW_1WSjI9J6eR7k1VSis7KE',
    appId: '1:897552655477:ios:184bc4f6ce76290343043c',
    messagingSenderId: '897552655477',
    projectId: 'quizzy-ai-85865',
    storageBucket: 'quizzy-ai-85865.firebasestorage.app',
    iosBundleId: 'com.chechoora.quizzy.pro',
  );
}
