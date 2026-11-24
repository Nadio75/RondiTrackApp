import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ronditrack/core/network/api_auth_client.dart';
import 'package:ronditrack/core/network/auth_interceptor.dart';
import 'package:ronditrack/core/offline/app_database.dart';
import 'package:ronditrack/core/offline/payment_outbox_api.dart';
import 'package:ronditrack/core/offline/payment_outbox_repository.dart';

class MockOutboxAuthClient extends Mock implements ApiAuthClient {}

void main() {
  late Dio dio;
  late AppDatabase database;
  late MockOutboxAuthClient auth;
  late PendingPaymentIntent intent;
  late List<RequestOptions> requests;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());

    final repository = PaymentOutboxRepository(database);

    intent = await repository.enqueue(
      accountId: 'synthetic-account',
      stokvelId: 'synthetic-stokvel',
      cycleId: 'synthetic-cycle',
      memberId: 'synthetic-member',
      amountInCents: 125050,
      isSessionCurrent: () => true,
    );

    auth = MockOutboxAuthClient();

    when(() => auth.sessionGeneration).thenReturn(10);
    when(() => auth.isAuthenticated).thenReturn(true);
    when(() => auth.accessToken).thenReturn('synthetic-token');

    requests = [];

    dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));

    dio.interceptors.add(AuthInterceptor(auth));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);

          handler.resolve(
            Response<dynamic>(requestOptions: options, statusCode: 201),
          );
        },
      ),
    );
  });

  tearDown(() async {
    dio.close(force: true);
    await database.close();
  });

  test('bound sender forwards correct session and persisted key', () async {
    final api = DioPaymentOutboxApi(dio, requiredAuthSessionGeneration: 10);

    await api.send(intent, idempotencyKey: intent.idempotencyKey);

    expect(requests, hasLength(1));

    final request = requests.single;

    expect(request.extra['requiredAuthSessionGeneration'], 10);
    expect(request.headers['Authorization'], 'Bearer synthetic-token');

    final key = request.headers.entries.singleWhere(
      (entry) => entry.key.toLowerCase() == 'idempotency-key',
    );

    expect(key.value, intent.idempotencyKey);
    expect(request.followRedirects, isFalse);

    expect(request.data, {
      'userId': 'synthetic-member',
      'amountInCents': 125050,
    });
  });

  test('bound sender cannot use another account credentials', () async {
    final api = DioPaymentOutboxApi(dio, requiredAuthSessionGeneration: 10);

    when(() => auth.sessionGeneration).thenReturn(11);
    when(() => auth.accessToken).thenReturn('other-synthetic-token');

    await expectLater(
      api.send(intent, idempotencyKey: intent.idempotencyKey),
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.cancel,
        ),
      ),
    );

    expect(requests, isEmpty);
  });

  test('bound sender cannot send after authentication is cleared', () async {
    final api = DioPaymentOutboxApi(dio, requiredAuthSessionGeneration: 10);

    when(() => auth.isAuthenticated).thenReturn(false);
    when(() => auth.accessToken).thenReturn(null);

    await expectLater(
      api.send(intent, idempotencyKey: intent.idempotencyKey),
      throwsA(isA<DioException>()),
    );

    expect(requests, isEmpty);
  });

  test('token refresh within the same session permits retry', () async {
    final api = DioPaymentOutboxApi(dio, requiredAuthSessionGeneration: 10);

    await api.send(intent, idempotencyKey: intent.idempotencyKey);

    when(() => auth.accessToken).thenReturn('refreshed-synthetic-token');

    await api.send(intent, idempotencyKey: intent.idempotencyKey);

    expect(requests, hasLength(2));

    expect(
      requests.last.headers['Authorization'],
      'Bearer refreshed-synthetic-token',
    );

    for (final request in requests) {
      final key = request.headers.entries.singleWhere(
        (entry) => entry.key.toLowerCase() == 'idempotency-key',
      );

      expect(key.value, intent.idempotencyKey);
    }
  });
}
