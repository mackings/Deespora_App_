import 'package:dio/dio.dart';
import 'package:dspora/App/View/Events/Model/eventModel.dart';
import 'package:flutter/material.dart';




class EventApiService {
  final Dio _dio;
  EventApiService({Dio? dio}) : _dio = dio ?? Dio();

  static const String _baseUrl = "https://deesporabackend.vercel.app";

/// ✅ Fetch all events (optionally filter by city) with retries
Future<List<Event>> fetchAllEvents({String? city}) async {
  const int maxRetries = 3;       // number of retry attempts
  const Duration retryDelay = Duration(seconds: 2);

  int attempt = 0;
  DioError? lastError;

  while (attempt < maxRetries) {
    attempt++;
    try {
      debugPrint('🔄 Fetch events attempt $attempt...');

      final response = await _dio.get(
        "$_baseUrl/all-events",
        // queryParameters: (city != null && city.isNotEmpty)
        //     ? {'city': city}
        //     : null,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        debugPrint('✅ Events fetched successfully on attempt $attempt');
        return data.map((e) => Event.fromJson(e)).toList();
      } else {
        // For non-200 status, throw to go into catch and retry
        throw DioError(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Status code: ${response.statusCode}',
          type: DioErrorType.badResponse,
        );
      }
    } on DioError catch (e) {
      lastError = e;
      debugPrint('⚠️ Fetch events failed (attempt $attempt): ${e.message}');

      // Retry for 5xx or network-related errors
      if (attempt < maxRetries &&
          (e.response?.statusCode != null &&
              e.response!.statusCode! >= 500 ||
              e.type == DioErrorType.connectionTimeout ||
              e.type == DioErrorType.receiveTimeout ||
              e.type == DioErrorType.badResponse)) {
        debugPrint('⏳ Retrying in ${retryDelay.inSeconds}s...');
        await Future.delayed(retryDelay);
        continue;
      } else {
        // Not retryable or we’ve exhausted retries
        break;
      }
    } catch (e) {
      debugPrint('❌ Unexpected error fetching events: $e');
      rethrow; // don’t retry unexpected errors
    }
  }

  // If we reach here, retries failed
  throw Exception(
      'Failed to fetch events after $maxRetries attempts: ${lastError?.message}');
}

  /// 🔎 Search events
  Future<List<Event>> searchEvents({
    required String keyword,
    String? city,
    int size = 50,
  }) async {
    try {
      final response = await _dio.post(
        "$_baseUrl/searchEvent",
        data: {
          'keyword': keyword,
          if (city != null) 'city': city,
          'size': size,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data']['events'] as List<dynamic>;
        return data.map((e) => Event.fromJson(e)).toList();
      } else {
        throw Exception(
          "Failed to search events. Status code: ${response.statusCode}",
        );
      }
    } on DioError catch (e) {
      throw Exception("DioError: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  /// 📄 Fetch single event by ID
  Future<Event> fetchEventById(String id) async {
    try {
      final response = await _dio.get("$_baseUrl/events/$id");

      if (response.statusCode == 200) {
        return Event.fromJson(response.data['data']);
      } else {
        throw Exception(
          "Failed to fetch event. Status code: ${response.statusCode}",
        );
      }
    } on DioError catch (e) {
      throw Exception("DioError: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }
}
