import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/error_handler.dart';

class ApiService {
  final http.Client _client;
  static const Duration _timeoutDuration = Duration(seconds: 10);

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch random comments/messages from dummyjson API
  Future<String> fetchRandomMessage() async {
    try {
      final response = await _client
          .get(
            Uri.parse('https://dummyjson.com/comments?limit=10'),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final comments = data['comments'] as List;
        if (comments.isNotEmpty) {
          final randomComment = comments[
              DateTime.now().millisecondsSinceEpoch % comments.length];
          return randomComment['body'] as String? ?? 'Hello!';
        }
        // If no comments, fall through to alternative API
      } else {
        throw ErrorHandler.handleHttpResponse(response);
      }
    } catch (e) {
      // Fallback to alternative API
      try {
        return await _fetchFromAlternativeApi();
      } catch (fallbackError) {
        // If all APIs fail, return a default message
        // This is graceful degradation - the app continues to work
        return 'Hello!';
      }
    }
    // If primary API returns empty comments, try alternative
    try {
      return await _fetchFromAlternativeApi();
    } catch (fallbackError) {
      return 'Hello!';
    }
  }

  Future<String> _fetchFromAlternativeApi() async {
    try {
      final response = await _client
          .get(
            Uri.parse('https://api.quotable.io/random'),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['content'] as String? ?? 'Hello!';
      } else {
        throw ErrorHandler.handleHttpResponse(response);
      }
    } catch (e) {
      // Return default message if all APIs fail
      // This is graceful degradation
      return 'Hello!';
    }
  }

  /// Fetch word meaning from dictionary API
  Future<String?> fetchWordMeaning(String word) async {
    if (word.trim().isEmpty) {
      return null;
    }

    try {
      final response = await _client
          .get(
            Uri.parse(
                'https://api.dictionaryapi.dev/api/v2/entries/en/${Uri.encodeComponent(word.trim())}'),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final entry = data[0];
          final meanings = entry['meanings'] as List?;
          if (meanings != null && meanings.isNotEmpty) {
            final firstMeaning = meanings[0];
            final definitions = firstMeaning['definitions'] as List?;
            if (definitions != null && definitions.isNotEmpty) {
              return definitions[0]['definition'] as String?;
            }
          }
        }
        return null;
      } else if (response.statusCode == 404) {
        // Word not found - this is not an error, just no definition available
        return null;
      } else {
        throw ErrorHandler.handleHttpResponse(response);
      }
    } catch (e) {
      // Re-throw as AppException for proper handling upstream
      throw ErrorHandler.handleError(e);
    }
  }
}

