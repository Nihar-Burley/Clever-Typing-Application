import 'dart:convert';
import 'dart:io';

import '../analytics/analytics_event.dart';
import '../analytics/analytics_service.dart';
import '../storage/secure_token_store.dart';
import 'ai_auth_session.dart';
import 'ai_backend_config.dart';
import 'ai_error_response.dart';
import 'ai_http_client.dart';
import 'ai_service_exception.dart';

/// Mobile HTTP client implementation for AI backend requests.
class DartAiHttpClient implements AiHttpClient {
  /// Creates the HTTP client.
  DartAiHttpClient(
    this._config,
    this._tokenStore,
    this._analyticsService,
  );

  final AiBackendConfig _config;
  final SecureTokenStore _tokenStore;
  final AnalyticsService _analyticsService;

  @override
  Future<Map<String, dynamic>> getJson(String path) {
    return _requestJson(
      method: 'GET',
      path: path,
    );
  }

  @override
  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
  }) {
    return _requestJson(
      method: 'POST',
      path: path,
      body: body,
    );
  }

  Future<Map<String, dynamic>> _requestJson({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    bool allowRefresh = true,
    int attempt = 0,
  }) async {
    if (!_config.isConfigured) {
      throw const AiServiceException(
        'AI backend is not configured. Pass AI_BASE_URL and AI_API_KEY using dart-define.',
      );
    }

    final Uri uri = Uri.parse('${_config.baseUrl}$path');
    final HttpClient httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 12);
    final AiAuthSession session = await _tokenStore.read();
    final String authToken =
        session.hasAccessToken ? session.accessToken : _config.apiKey;

    try {
      final HttpClientRequest request = await httpClient.openUrl(method, uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $authToken',
      );
      if (body != null) {
        request.write(jsonEncode(body));
      }

      final HttpClientResponse response =
          await request.close().timeout(const Duration(seconds: 20));
      final String responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 401 &&
          allowRefresh &&
          session.hasRefreshToken &&
          path != _config.refreshPath) {
        final bool refreshed = await _refreshSession(session.refreshToken);
        if (refreshed) {
          return _requestJson(
            method: method,
            path: path,
            body: body,
            allowRefresh: false,
            attempt: attempt,
          );
        }
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AiErrorResponse.fromResponseBody(
          responseBody,
          statusCode: response.statusCode,
        );
      }

      if (responseBody.trim().isEmpty) {
        return <String, dynamic>{};
      }

      final Object? decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, dynamic>) {
        throw const AiServiceException('AI backend returned an invalid response.');
      }

      await _analyticsService.track(
        AnalyticsEvent(
          name: 'request_success',
          feature: 'networking',
          properties: <String, Object?>{
            'method': method,
            'path': path,
            'attempt': attempt,
          },
        ),
      );
      return decoded;
    } on SocketException {
      if (attempt < 1) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        return _requestJson(
          method: method,
          path: path,
          body: body,
          allowRefresh: allowRefresh,
          attempt: attempt + 1,
        );
      }
      throw const AiServiceException('No internet connection available.');
    } on HttpException catch (error) {
      throw AiServiceException(error.message);
    } on FormatException {
      throw const AiServiceException('AI backend returned malformed JSON.');
    } on AiServiceException catch (error) {
      await _analyticsService.track(
        AnalyticsEvent(
          name: 'request_failed',
          feature: 'networking',
          properties: <String, Object?>{
            'method': method,
            'path': path,
            'statusCode': error.statusCode,
            'code': error.code,
          },
        ),
      );
      rethrow;
    } finally {
      httpClient.close(force: true);
    }
  }

  Future<bool> _refreshSession(String refreshToken) async {
    final HttpClient httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 12);
    final Uri uri = Uri.parse('${_config.baseUrl}${_config.refreshPath}');

    try {
      final HttpClientRequest request = await httpClient.postUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.write(
        jsonEncode(
          <String, Object?>{
            'refreshToken': refreshToken,
          },
        ),
      );

      final HttpClientResponse response =
          await request.close().timeout(const Duration(seconds: 15));
      final String responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return false;
      }

      final Object decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, dynamic>) {
        return false;
      }

      final String accessToken = decoded['accessToken'] as String? ?? '';
      final String nextRefreshToken =
          decoded['refreshToken'] as String? ?? refreshToken;
      if (accessToken.isEmpty) {
        return false;
      }

      await _tokenStore.write(
        AiAuthSession(
          accessToken: accessToken,
          refreshToken: nextRefreshToken,
        ),
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      httpClient.close(force: true);
    }
  }
}
