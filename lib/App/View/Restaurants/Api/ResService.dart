import 'package:dio/dio.dart';
import 'package:dspora/App/View/Restaurants/Model/ResModel.dart';
import 'package:dspora/Constants/BaseUrl.dart';

class ApiService {
  final Dio _dio = Dio();

  /// Fetch all restaurants (cached on backend)
  Future<List<Restaurant>> fetchRestaurants() async {
    const endpoint = '${Baseurl.Url}restaurants';

    print('📡 Fetching: $endpoint');

    try {
      final response = await _dio.get(endpoint);

      print('✅ Status: ${response.statusCode}');
      print('✅ Data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final dynamic data = response.data['data'];
        final List restaurants = data is List
            ? data
            : (data is Map<String, dynamic> ? (data['restaurants'] ?? []) : []);
        if (restaurants is! List) {
          throw Exception('Invalid data format: ${response.data}');
        }
        return restaurants.map((e) => Restaurant.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response: ${response.data}');
      }
    } catch (e) {
      print('❌ API error: $e');
      throw Exception('Failed to load restaurants: $e');
    }
  }

  /// Search restaurants by keyword and city
  Future<List<Restaurant>> searchRestaurants({
    required String city,
    required String keyword,
  }) async {
    final endpoint =
        '${Baseurl.Url}search-restaurants?city=$city&keyword=$keyword';

    print('📡 Searching: $endpoint');

    try {
      final response = await _dio.get(endpoint);

      print('✅ Status: ${response.statusCode}');
      print('✅ Data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final dynamic data = response.data['data'];
        final List restaurants = data is List
            ? data
            : (data is Map<String, dynamic> ? (data['restaurants'] ?? []) : []);
        if (restaurants is! List) {
          throw Exception('Invalid data format: ${response.data}');
        }
        return restaurants.map((e) => Restaurant.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response: ${response.data}');
      }
    } catch (e) {
      print('❌ API error: $e');
      throw Exception('Failed to search restaurants: $e');
    }
  }

  /// Find nearby restaurants using location (cache-first)
  /// Either lat+lng or city is required
  Future<List<Restaurant>> fetchNearbyRestaurants({
    double? lat,
    double? lng,
    String? city,
  }) async {
    if ((lat == null || lng == null) && city == null) {
      throw Exception(
          'Either lat+lng coordinates or city must be provided for nearby search');
    }

    String endpoint = '${Baseurl.Url}restaurants/nearby?';
    if (lat != null && lng != null) {
      endpoint += 'lat=$lat&lng=$lng';
    } else if (city != null) {
      endpoint += 'city=$city';
    }

    print('📡 Fetching nearby: $endpoint');

    try {
      final response = await _dio.get(endpoint);

      print('✅ Status: ${response.statusCode}');
      print('✅ Data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'];
        return data.map((e) => Restaurant.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response: ${response.data}');
      }
    } catch (e) {
      print('❌ API error: $e');
      throw Exception('Failed to load nearby restaurants: $e');
    }
  }
}
