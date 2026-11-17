import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/network/trusted_origin_http_adapter.dart';

class RecordingAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;
  bool closed = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString('ok', 200);
  }

  @override
  void close({bool force = false}) {
    closed = true;
  }
}

void main() {
  const apiBaseUrl = 'https://api.example.com:8443';

  late RecordingAdapter recording;
  late TrustedOriginHttpAdapter adapter;

  setUp(() {
    recording = RecordingAdapter();
    adapter = TrustedOriginHttpAdapter(
      inner: recording,
      apiBaseUrl: apiBaseUrl,
    );
  });

  Future<bool?> send(String url, {bool? suppliedCredentials}) async {
    final options = RequestOptions(
      path: url,
      baseUrl: apiBaseUrl,
      extra: {'withCredentials': ?suppliedCredentials},
    );

    await adapter.fetch(options, null, null);

    return recording.lastRequest?.extra['withCredentials'] as bool?;
  }

  test('trusted API receives credentials', () async {
    expect(await send('/api/v1/auth/refresh'), isTrue);
  });

  test('external host cannot force credentials', () async {
    expect(
      await send(
        'https://other.example.com:8443/data',
        suppliedCredentials: true,
      ),
      isFalse,
    );
  });

  test('different scheme cannot receive credentials', () async {
    expect(await send('http://api.example.com:8443/data'), isFalse);
  });

  test('different port cannot receive credentials', () async {
    expect(await send('https://api.example.com:9443/data'), isFalse);
  });

  test('trusted API overrides a false credential flag', () async {
    expect(
      await send('/api/v1/auth/login', suppliedCredentials: false),
      isTrue,
    );
  });

  test('closing wrapper closes inner adapter', () {
    adapter.close(force: true);
    expect(recording.closed, isTrue);
  });
}
