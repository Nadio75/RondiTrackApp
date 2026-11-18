import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SessionOrigin { none, demo, api }

class SessionOriginNotifier extends Notifier<SessionOrigin> {
  @override
  SessionOrigin build() => SessionOrigin.none;

  void markDemo() => state = SessionOrigin.demo;

  void markApi() => state = SessionOrigin.api;

  void clear() => state = SessionOrigin.none;
}

final sessionOriginProvider =
    NotifierProvider<SessionOriginNotifier, SessionOrigin>(
      SessionOriginNotifier.new,
    );
