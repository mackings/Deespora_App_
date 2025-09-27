import 'package:dio/dio.dart';
import 'package:dspora/App/View/Events/Model/eventModel.dart';


class EventApiService {
  final Dio _dio;

  EventApiService({Dio? dio}) : _dio = dio ?? Dio();

  // Base URL
  static const String _baseUrl = "https://deesporabackend.vercel.app";

  /// Fetch all events
  Future<List<Event>> fetchAllEvents() async {
    try {
      final response = await _dio.get("$_baseUrl/all-events");

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data.map((e) => Event.fromJson(e)).toList();
      } else {
        throw Exception(
            "Failed to fetch events. Status code: ${response.statusCode}");
      }
    } on DioError catch (e) {
      throw Exception("DioError: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  /// Fetch single event by ID
  Future<Event> fetchEventById(String id) async {
    try {
      final response = await _dio.get("$_baseUrl/events/$id");

      if (response.statusCode == 200) {
        return Event.fromJson(response.data['data']);
      } else {
        throw Exception(
            "Failed to fetch event. Status code: ${response.statusCode}");
      }
    } on DioError catch (e) {
      throw Exception("DioError: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }
}
