import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/core/network/backend_api_client.dart';

void main() {
  test('sends the Supabase bearer token and JSON request body', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final received = Completer<(String, String, String?)>();
    final subscription = server.listen((request) async {
      final body = await utf8.decoder.bind(request).join();
      received.complete((
        request.method,
        request.headers.value(HttpHeaders.authorizationHeader) ?? '',
        body,
      ));
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write('{"ok":true}')
        ..close();
    });
    final client = BackendApiClient(
      baseUri: Uri.parse('http://127.0.0.1:${server.port}/'),
      accessToken: () => 'test-access-token',
    );

    addTearDown(() async {
      client.close();
      await subscription.cancel();
      await server.close(force: true);
    });

    final result = await client.post('/api/test', {'value': 7});
    expect(result, {'ok': true});
    expect(await received.future, (
      'POST',
      'Bearer test-access-token',
      '{"value":7}',
    ));
  });

  test('returns null for a successful no-content response', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final subscription = server.listen((request) {
      request.response
        ..statusCode = HttpStatus.noContent
        ..close();
    });
    final client = BackendApiClient(
      baseUri: Uri.parse('http://127.0.0.1:${server.port}/'),
      accessToken: () => 'token',
    );
    addTearDown(() async {
      client.close();
      await subscription.cancel();
      await server.close(force: true);
    });

    expect(await client.delete('/api/test/1'), isNull);
  });

  test('fails before making a request when no access token exists', () async {
    final client = BackendApiClient(accessToken: () => null);
    addTearDown(client.close);

    await expectLater(
      client.get('/api/people'),
      throwsA(
        isA<BackendApiException>().having(
          (error) => error.statusCode,
          'statusCode',
          401,
        ),
      ),
    );
  });
}
