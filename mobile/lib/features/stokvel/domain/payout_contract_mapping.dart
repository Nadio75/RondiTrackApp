import 'payout_models.dart';

PayoutStatus payoutStatusFromWire(String? value) =>
    switch (value?.toLowerCase()) {
      'paid' => PayoutStatus.paid,
      'next' => PayoutStatus.next,
      'upcoming' => PayoutStatus.upcoming,
      _ => PayoutStatus.unknown,
    };
