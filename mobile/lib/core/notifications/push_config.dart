import 'package:firebase_core/firebase_core.dart';

class PushConfig {
  const PushConfig({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
  });

  factory PushConfig.fromEnvironment() {
    return const PushConfig(
      apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
      appId: String.fromEnvironment('FIREBASE_APP_ID'),
      messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
      projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    );
  }

  final String apiKey;
  final String appId;
  final String messagingSenderId;
  final String projectId;

  bool get enabled {
    final values = [apiKey, appId, messagingSenderId, projectId];

    if (values.every((value) => value.trim().isEmpty)) {
      return false;
    }

    if (values.any((value) => value.trim().isEmpty)) {
      throw StateError('Incomplete Firebase configuration.');
    }

    return true;
  }

  FirebaseOptions get options {
    if (!enabled) {
      throw StateError('Firebase notifications are disabled.');
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
    );
  }
}
