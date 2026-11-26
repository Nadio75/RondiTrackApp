import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_context.dart';
import '../../../core/money/parse_rands.dart';
import '../../../core/notifications/notification_permission_prompt.dart';
import '../../../core/notifications/push_providers.dart';
import '../../../core/notifications/local_notification_provider.dart';
import '../../../core/offline/payment_outbox_service.dart';
import '../../session/presentation/session_provider.dart';
import '../../session/presentation/session_origin_provider.dart';
import '../domain/contribution_controller.dart';
import 'payment_outcome_message.dart';

class ContributionForm extends ConsumerStatefulWidget {
  const ContributionForm({
    super.key,
    required this.stokvelId,
    required this.cycleId,
    required this.memberId,
    this.requiredAmount,
  });

  final String stokvelId;
  final String cycleId;
  final String memberId;
  final double? requiredAmount;

  @override
  ConsumerState<ContributionForm> createState() => _ContributionFormState();
}

class _ContributionFormState extends ConsumerState<ContributionForm> {
  final _formKey = GlobalKey<FormState>();
  late final _amountController = TextEditingController(
    text: widget.requiredAmount?.toStringAsFixed(2) ?? '',
  );

  PaymentOutcome? _outcome;
  bool _saveFailed = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _retryPending() async {
    if (ref.read(contributionControllerProvider)) {
      return;
    }

    final accountId = ref.read(sessionProvider)?.id;
    final generation = ref.read(sessionProvider.notifier).sessionGeneration;

    setState(() {
      _saveFailed = false;
    });

    try {
      final outcome = await ref
          .read(contributionControllerProvider.notifier)
          .retryPending(
            stokvelId: widget.stokvelId,
            cycleId: widget.cycleId,
            memberId: widget.memberId,
          );

      if (!mounted) return;

      if (ref.read(sessionProvider)?.id != accountId ||
          ref.read(sessionProvider.notifier).sessionGeneration != generation) {
        return;
      }

      setState(() {
        _outcome = outcome;
      });

      if (outcome == PaymentOutcome.recorded) {
        if (widget.requiredAmount == null) _amountController.clear();

        ref.read(notificationRefreshProvider.notifier).refresh();

        await NotificationPermissionPrompt.offer(
          context: context,
          gateway: ref.read(pushGatewayProvider),
          isSessionCurrent: () =>
              mounted &&
              ref.read(sessionProvider)?.id == accountId &&
              ref.read(sessionProvider.notifier).sessionGeneration ==
                  generation &&
              ref.read(sessionOriginProvider) == SessionOrigin.api,
        );
      }
    } catch (_) {
      if (!mounted) return;

      if (ref.read(sessionProvider)?.id != accountId ||
          ref.read(sessionProvider.notifier).sessionGeneration != generation) {
        return;
      }

      setState(() {
        _saveFailed = true;
      });
    }
  }

  Future<void> _submit() async {
    if (ref.read(contributionControllerProvider)) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final accountId = ref.read(sessionProvider)?.id;
    final generation = ref.read(sessionProvider.notifier).sessionGeneration;

    setState(() {
      _outcome = null;
      _saveFailed = false;
    });

    try {
      final outcome = await ref
          .read(contributionControllerProvider.notifier)
          .submit(
            stokvelId: widget.stokvelId,
            cycleId: widget.cycleId,
            memberId: widget.memberId,
            amount:
                widget.requiredAmount?.toStringAsFixed(2) ??
                _amountController.text,
          );

      if (!mounted) return;

      if (ref.read(sessionProvider)?.id != accountId ||
          ref.read(sessionProvider.notifier).sessionGeneration != generation) {
        if (widget.requiredAmount == null) _amountController.clear();
        return;
      }

      setState(() {
        _outcome = outcome;
      });

      if (outcome == PaymentOutcome.recorded) {
        if (widget.requiredAmount == null) _amountController.clear();

        ref.read(notificationRefreshProvider.notifier).refresh();

        await NotificationPermissionPrompt.offer(
          context: context,
          gateway: ref.read(pushGatewayProvider),
          isSessionCurrent: () =>
              mounted &&
              ref.read(sessionProvider)?.id == accountId &&
              ref.read(sessionProvider.notifier).sessionGeneration ==
                  generation &&
              ref.read(sessionOriginProvider) == SessionOrigin.api,
        );
      }
    } catch (_) {
      if (!mounted) return;

      if (ref.read(sessionProvider)?.id != accountId ||
          ref.read(sessionProvider.notifier).sessionGeneration != generation) {
        return;
      }

      setState(() {
        _saveFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final processing = ref.watch(contributionControllerProvider);
    final user = ref.watch(sessionProvider);
    final origin = ref.watch(sessionOriginProvider);

    if (user == null ||
        origin != SessionOrigin.api ||
        user.id != widget.memberId) {
      return Text(l10n.contributionAuthenticationRequired);
    }

    final finished =
        _outcome == PaymentOutcome.recorded ||
        _outcome == PaymentOutcome.alreadyPaid ||
        _outcome == PaymentOutcome.cycleClosed;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.recordContribution,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('contribution_amount'),
            controller: _amountController,
            readOnly: widget.requiredAmount != null,
            enabled: !processing && !finished,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.contributionAmount,
              prefixText: 'R ',
              suffixIcon: widget.requiredAmount != null
                  ? const Icon(Icons.lock_outline)
                  : null,
              helperText: widget.requiredAmount != null
                  ? (Localizations.localeOf(context).languageCode == 'nso'
                        ? 'Moneelo o beilwe ke stokvel.'
                        : 'Your monthly contribution is fixed.')
                  : null,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              final parsed = parseRandsStrict(value ?? '');

              if (widget.requiredAmount != null &&
                  value != widget.requiredAmount!.toStringAsFixed(2)) {
                return l10n.contributionInvalidAmount;
              }

              if (parsed is! RandParseSuccess ||
                  parsed.amount.value <= 0 ||
                  parsed.amount.value > 2147483647) {
                return l10n.contributionInvalidAmount;
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('submit_contribution'),
            onPressed: processing || finished ? null : _submit,
            child: Text(
              processing
                  ? l10n.contributionProcessing
                  : l10n.recordContribution,
            ),
          ),
          if (!finished) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              key: const Key('retry_pending_contributions'),
              onPressed: processing ? null : _retryPending,
              child: Text(l10n.retryPendingContributions),
            ),
          ],
          if (processing) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (_outcome != null) ...[
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: Text(
                paymentOutcomeMessage(l10n, _outcome!),
                key: const Key('contribution_feedback'),
              ),
            ),
          ],
          if (_saveFailed) ...[
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: Text(l10n.contributionSaveFailed),
            ),
          ],
        ],
      ),
    );
  }
}
