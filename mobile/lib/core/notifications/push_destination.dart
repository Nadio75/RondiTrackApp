class PushDestination {
  const PushDestination({required this.stokvelId, required this.cycleId});

  final String stokvelId;
  final String cycleId;

  static final _guid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static bool _validId(Object? value) {
    return value is String &&
        _guid.hasMatch(value) &&
        value != '00000000-0000-0000-0000-000000000000';
  }

  static PushDestination? parse(Map<String, dynamic> data) {
    if (data['type'] != 'contribution_confirmed') {
      return null;
    }

    final stokvelId = data['stokvelId'];
    final cycleId = data['cycleId'];

    if (!_validId(stokvelId) || !_validId(cycleId)) {
      return null;
    }

    return PushDestination(
      stokvelId: stokvelId as String,
      cycleId: cycleId as String,
    );
  }

  String get location => '/stokvels/$stokvelId/cycles/$cycleId';
}
