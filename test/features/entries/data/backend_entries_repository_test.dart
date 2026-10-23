import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/core/network/backend_api_client.dart';
import 'package:reborn_app/features/entries/data/backend_entries_repository.dart';
import 'package:reborn_app/features/entries/models/emotion.dart';

void main() {
  test('maps entry DTOs and person filter to the Flutter contract', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final subscription = server.listen((request) {
      expect(request.uri.path, '/api/entries');
      expect(request.uri.queryParameters['personId'], 'person-1');
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(
          jsonEncode([
            {
              'id': 'entry-1',
              'body': '오늘 기뻤다',
              'person_id': 'person-1',
              'emotion': 'joy',
              'intensity': 2,
              'score': 2,
              'created_at': '2026-10-24T00:00:00Z',
              'analysis_status': 'done',
              'analysis_keywords': ['기쁨'],
              'analyzed_at': '2026-10-24T00:01:00Z',
            },
          ]),
        )
        ..close();
    });
    final api = BackendApiClient(
      baseUri: Uri.parse('http://127.0.0.1:${server.port}/'),
      accessToken: () => 'token',
    );
    final repository = BackendEntriesRepository(api);
    addTearDown(() async {
      api.close();
      await subscription.cancel();
      await server.close(force: true);
    });

    final entries = await repository.list(personId: 'person-1');
    expect(entries, hasLength(1));
    expect(entries.single.emotion, Emotion.joy);
    expect(entries.single.intensity, 2);
    expect(entries.single.analysis?.keywords, ['기쁨']);
  });
}
