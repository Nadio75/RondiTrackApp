import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_notification_service.dart';

final localNotificationServiceProvider = Provider<LocalNotificationService>((
  ref,
) {
  return const DisabledLocalNotificationService();
});

class NotificationRefreshNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void refresh() {
    state++;
  }
}

final notificationRefreshProvider =
    NotifierProvider<NotificationRefreshNotifier, int>(
      NotificationRefreshNotifier.new,
    );
