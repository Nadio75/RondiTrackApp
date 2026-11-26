import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'push_gateway.dart';

class NotificationPermissionPrompt {
  static const preferenceKey = 'ronditrack.notification_permission_offered.v1';

  static bool _showing = false;

  static Future<void> offer({
    required BuildContext context,
    required PushGateway gateway,
    required bool Function() isSessionCurrent,
  }) async {
    if (!gateway.enabled || _showing) return;

    _showing = true;

    try {
      final preferences = await SharedPreferences.getInstance();

      if (preferences.getBool(preferenceKey) == true) return;

      if (!context.mounted || !isSessionCurrent()) return;

      final saved = await preferences.setBool(preferenceKey, true);

      if (!saved || !context.mounted || !isSessionCurrent()) {
        return;
      }

      final sepedi = Localizations.localeOf(context).languageCode == 'nso';

      final accepted = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.notifications_outlined),
          title: Text(sepedi ? 'Dumela ditsebišo' : 'Stay up to date'),
          content: Text(
            sepedi
                ? 'Amogela ditsebišo ge moneelo wa gago o netefaditšwe.'
                : 'Receive a notification when your contribution '
                      'has been confirmed. Your financial details '
                      'will not appear in the notification.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(sepedi ? 'E sego bjale' : 'Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(sepedi ? 'Dumela' : 'Enable notifications'),
            ),
          ],
        ),
      );

      if (accepted == true && context.mounted && isSessionCurrent()) {
        await gateway.requestPermission();
      }
    } catch (_) {
      // Notification failures must not affect recorded payments.
    } finally {
      _showing = false;
    }
  }
}
