import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BackendApiException implements Exception {
  const BackendApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'BackendApiException($statusCode): $message';
}

class BackendApiClient {
  BackendApiClient({
    Uri? baseUri,
    HttpClient? httpClient,
    String? Function()? accessToken,
  }) : _baseUri = baseUri ?? defaultBaseUri,
       _httpClient = httpClient ?? HttpClient(),
       _accessToken = accessToken ?? _currentSupabaseToken;

  static const _configuredBaseUrl = String.fromEnvironment('BACKEND_BASE_URL');
  static const _developmentAccessToken = String.fromEnvironment(
    'BACKEND_ACCESS_TOKEN',
  );

  static Uri get defaultBaseUri => Uri.parse(
    _configuredBaseUrl.isNotEmpty
        ? _configuredBaseUrl
        : Platform.isAndroid
        ? 'http://10.0.2.2:8000'
        : 'http://127.0.0.1:8000',
  );

  final Uri _baseUri;
  final HttpClient _httpClient;
  final String? Function() _accessToken;

  static String? _currentSupabaseToken() {
    if (kDebugMode && _developmentAccessToken.isNotEmpty) {
      return _developmentAccessToken;
    }
    try {
      return Supabase.instance.client.auth.currentSession?.accessToken;
    } on Object {
      return null;
    }
  }

  Future<Object?> get(String path, {Map<String, String> query = const {}}) =>
      request('GET', path, query: query);

  Future<Object?> post(String path, Object body) =>
      request('POST', path, body: body);

  Future<Object?> put(String path, Object body) =>
      request('PUT', path, body: body);

  Future<Object?> patch(String path, Object body) =>
      request('PATCH', path, body: body);

  Future<Object?> delete(String path, {Map<String, String> query = const {}}) =>
      request('DELETE', path, query: query);

  Future<Object?> request(
    String method,
    String path, {
    Map<String, String> query = const {},
    Object? body,
  }) async {
    final token = _accessToken();
    if (token == null || token.isEmpty) {
      throw const BackendApiException(401, 'Supabase 로그인이 필요합니다.');
    }

    final uri = _baseUri
        .resolve(path)
        .replace(queryParameters: query.isEmpty ? null : query);
    final request = await _httpClient.openUrl(method, uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
    }

    final response = await request.close();
    final responseText = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      var message = response.reasonPhrase;
      if (responseText.isNotEmpty) {
        try {
          final decoded = jsonDecode(responseText);
          if (decoded is Map<String, Object?> && decoded['message'] is String) {
            message = decoded['message']! as String;
          }
        } on FormatException {
          message = responseText;
        }
      }
      throw BackendApiException(response.statusCode, message);
    }
    if (response.statusCode == HttpStatus.noContent || responseText.isEmpty) {
      return null;
    }
    return jsonDecode(responseText);
  }

  void close() => _httpClient.close(force: true);
}
