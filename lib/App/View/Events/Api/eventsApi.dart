import 'package:dio/dio.dart';
import 'package:dspora/App/View/Events/Model/eventModel.dart';




class EventApiService {
  final Dio _dio;
  EventApiService({Dio? dio}) : _dio = dio ?? Dio();

  static const String _baseUrl = "https://deesporabackend.vercel.app";

  /// ✅ Fetch all events (optionally filter by city)
  Future<List<Event>> fetchAllEvents({String? city}) async {
    try {
      final response = await _dio.get(
        "$_baseUrl/all-events",
        queryParameters: city != null && city.isNotEmpty
            ? {'city': city}     // <-- match your backend query key
            : null,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data.map((e) => Event.fromJson(e)).toList();
      } else {
        throw Exception(
          "Failed to fetch events. Status code: ${response.statusCode}",
        );
      }
    } on DioError catch (e) {
      throw Exception("DioError: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
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
