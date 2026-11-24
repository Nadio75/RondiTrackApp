import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/offline/app_database.dart';
import 'package:ronditrack/core/offline/payment_outbox_repository.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  for (final version in [1, 2]) {
    test('schema $version upgrades to schema 3 without data loss', () async {
      final directory = await Directory.systemTemp.createTemp(
        'ronditrack-migration-',
      );

      final file = File(
        '${directory.path}${Platform.pathSeparator}legacy.sqlite',
      );

      final createdAt = DateTime.utc(2026, 11, 24, 10);
      final retryAt = createdAt.add(const Duration(minutes: 2));

      final createdSeconds = createdAt.millisecondsSinceEpoch ~/ 1000;
      final retrySeconds = retryAt.millisecondsSinceEpoch ~/ 1000;

      final legacy = sqlite3.open(file.path);

      try {
        legacy.execute('''
          CREATE TABLE cached_api_responses (
            cache_key TEXT NOT NULL,
            account_id TEXT NOT NULL,
            response_json TEXT NOT NULL,
            updated_at_utc INTEGER NOT NULL,
            PRIMARY KEY (cache_key, account_id)
          )
        ''');

        final retryColumn = version == 2
            ? ', next_attempt_at_utc INTEGER NULL'
            : '';

        legacy.execute('''
          CREATE TABLE pending_payment_intents (
            intent_id TEXT NOT NULL PRIMARY KEY,
            account_id TEXT NOT NULL,
            stokvel_id TEXT NOT NULL,
            cycle_id TEXT NOT NULL,
            member_id TEXT NOT NULL,
            amount_in_cents INTEGER NOT NULL,
            idempotency_key TEXT NOT NULL UNIQUE,
            status TEXT NOT NULL DEFAULT 'pending',
            created_at_utc INTEGER NOT NULL
            $retryColumn
          )
        ''');

        legacy.execute(
          '''
          INSERT INTO cached_api_responses
          (cache_key, account_id, response_json, updated_at_utc)
          VALUES (?, ?, ?, ?)
          ''',
          ['home:v1', 'legacy-account', '[]', createdSeconds],
        );

        legacy.execute(
          '''
          INSERT INTO pending_payment_intents
          (intent_id, account_id, stokvel_id, cycle_id,
           member_id, amount_in_cents, idempotency_key,
           status, created_at_utc)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            'legacy-intent',
            'legacy-account',
            'legacy-stokvel',
            'legacy-cycle',
            'legacy-member',
            125050,
            'original-legacy-key',
            'pending',
            createdSeconds,
          ],
        );

        if (version == 2) {
          legacy.execute(
            '''
            UPDATE pending_payment_intents
            SET next_attempt_at_utc = ?
            WHERE intent_id = ?
            ''',
            [retrySeconds, 'legacy-intent'],
          );
        }

        legacy.execute('PRAGMA user_version = $version');
      } finally {
        legacy.close();
      }

      final database = AppDatabase.forTesting(NativeDatabase(file));

      try {
        final repository = PaymentOutboxRepository(database);

        final intents = await repository.pendingForAccount('legacy-account');

        expect(intents, hasLength(1));

        final intent = intents.single;

        expect(intent.intentId, 'legacy-intent');
        expect(intent.idempotencyKey, 'original-legacy-key');
        expect(intent.amountInCents, 125050);
        expect(intent.status, 'pending');
        expect(intent.createdAtUtc.toUtc(), createdAt);

        expect(intent.nextAttemptAtUtc?.toUtc(), version == 2 ? retryAt : null);

        final cached = await database.select(database.cachedApiResponses).get();

        expect(cached, hasLength(1));
        expect(cached.single.accountId, 'legacy-account');
        expect(cached.single.responseJson, '[]');
        expect(cached.single.updatedAtUtc.toUtc(), createdAt);

        final schema = await database
            .customSelect('PRAGMA user_version')
            .getSingle();

        expect(schema.read<int>('user_version'), 3);

        expect(await repository.accountRetryAt('legacy-account'), isNull);

        await repository.deferAccount(
          accountId: 'legacy-account',
          retryAtUtc: retryAt,
          isSessionCurrent: () => true,
        );

        expect(await repository.accountRetryAt('legacy-account'), retryAt);

        await database.clearAccountData('legacy-account');

        expect(await repository.pendingForAccount('legacy-account'), isEmpty);

        expect(await repository.accountRetryAt('legacy-account'), isNull);

        expect(
          await database.select(database.cachedApiResponses).get(),
          isEmpty,
        );
      } finally {
        await database.close();
        await directory.delete(recursive: true);
      }
    });
  }
}
