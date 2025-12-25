import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mysivi_chat_app/core/services/api_service.dart';
import 'package:mysivi_chat_app/core/errors/app_exceptions.dart';

import 'api_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late ApiService apiService;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    apiService = ApiService(client: mockClient);
  });

  group('fetchRandomMessage', () {
    test('should return message from dummyjson API', () async {
      // arrange
      final responseData = {
        'comments': [
          {'body': 'Test comment 1'},
          {'body': 'Test comment 2'},
        ]
      };
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response(json.encode(responseData), 200),
      );

      // act
      final result = await apiService.fetchRandomMessage();

      // assert
      expect(result, isA<String>());
      expect(result.isNotEmpty, true);
      verify(mockClient.get(any)).called(1);
    });

    test('should fallback to alternative API when primary fails', () async {
      // arrange
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response('Error', 500),
      );

      // act
      final result = await apiService.fetchRandomMessage();

      // assert
      expect(result, isA<String>());
      // Should return default message when all APIs fail
      expect(result, 'Hello!');
    });
  });

  group('fetchWordMeaning', () {
    test('should return word meaning when API call succeeds', () async {
      // arrange
      final responseData = [
        {
          'meanings': [
            {
              'definitions': [
                {'definition': 'A test definition'}
              ]
            }
          ]
        }
      ];
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response(json.encode(responseData), 200),
      );

      // act
      final result = await apiService.fetchWordMeaning('test');

      // assert
      expect(result, 'A test definition');
      verify(mockClient.get(any)).called(1);
    });

    test('should return null when word not found', () async {
      // arrange
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response('Not Found', 404),
      );

      // act
      final result = await apiService.fetchWordMeaning('nonexistent');

      // assert
      expect(result, isNull);
    });

    test('should throw exception on server error', () async {
      // arrange
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response('Server Error', 500),
      );

      // act & assert
      expect(
        () => apiService.fetchWordMeaning('test'),
        throwsA(isA<AppException>()),
      );
    });

    test('should return null for empty word', () async {
      // act
      final result = await apiService.fetchWordMeaning('');

      // assert
      expect(result, isNull);
      verifyNever(mockClient.get(any));
    });
  });
}

