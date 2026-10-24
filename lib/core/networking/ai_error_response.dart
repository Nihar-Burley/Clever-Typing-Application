import 'dart:convert';

import 'ai_service_exception.dart';

/// Parses standard backend error envelopes.
abstract final class AiErrorResponse {
  static AiServiceException fromResponseBody(
    String responseBody, {
    int? statusCode,
  }) {
    final String trimmed = responseBody.trim();
    if (trimmed.isEmpty) {
      return AiServiceException(
        'AI request failed.',
        statusCode: statusCode,
      );
    }

    try {
      final Map<String, dynamic> decoded =
          Map<String, dynamic>.from(jsonDecode(trimmed) as Map);
      final Object? error = decoded['error'];
      if (error is Map) {
        final String message =
            (error['message'] as String?)?.trim().isNotEmpty == true
                ? error['message'] as String
                : 'AI request failed.';
        final String? code = error['code'] as String?;
        return AiServiceException(
          message,
          statusCode: statusCode,
          code: code,
        );
      }
    } catch (_) {
      return AiServiceException(trimmed, statusCode: statusCode);
    }

    return AiServiceException(trimmed, statusCode: statusCode);
  }
}
