import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/payout_models.dart';

sealed class PayoutViewState {
  const PayoutViewState();
}

final class PayoutLoading extends PayoutViewState {
  const PayoutLoading();
}

final class PayoutEmpty extends PayoutViewState {
  const PayoutEmpty();
}

final class PayoutData extends PayoutViewState {
  const PayoutData(this.rotation);

  final PayoutRotation rotation;
}

final class PayoutFailure extends PayoutViewState {
  const PayoutFailure(this.error);

  final Object error;
}

/// Converts Riverpod's asynchronous state into a screen-friendly state.
PayoutViewState payoutViewStateFromAsync(AsyncValue<PayoutRotation?> value) {
  return switch (value) {
    AsyncLoading<PayoutRotation?>() => const PayoutLoading(),
    AsyncError<PayoutRotation?>(:final error) => PayoutFailure(error),
    AsyncData<PayoutRotation?>(value: final rotation) =>
      rotation == null || rotation.entries.isEmpty
          ? const PayoutEmpty()
          : PayoutData(rotation),
  };
}
