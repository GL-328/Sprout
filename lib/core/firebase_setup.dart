import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase settings, passed in at build time from the optional
/// GOOGLE_SERVICES_JSON secret (see .github/workflows/build-apk.yml). These
/// identify the project; they are not passwords. Without them Friends stays
/// switched off and the rest of the app works as usual.
const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
const _appId = String.fromEnvironment('FIREBASE_APP_ID');
const _senderId = String.fromEnvironment('FIREBASE_SENDER_ID');
const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');

bool get firebaseConfigured => _apiKey.isNotEmpty && _appId.isNotEmpty && _senderId.isNotEmpty && _projectId.isNotEmpty;

/// Starts Firebase if this build was given its settings. Never throws.
Future<bool> startFirebase() async {
  if (!firebaseConfigured || kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: _apiKey,
        appId: _appId,
        messagingSenderId: _senderId,
        projectId: _projectId,
      ),
    );
    return true;
  } catch (e) {
    debugPrint('Firebase did not start: $e');
    return false;
  }
}
