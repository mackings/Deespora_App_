import 'package:dio/dio.dart';
import 'package:dspora/App/View/Restaurants/Model/ResModel.dart';
import 'package:dspora/Constants/BaseUrl.dart';
import 'package:dspora/App/Services/CacheManager.dart';

class ApiService {
  final Dio _dio = Dio();

  /// Fetch all restaurants (cached on backend)
  Future<List<Restaurant>> fetchRestaurants() async {
    const endpoint = '${Baseurl.Url}restaurants';

    // Check cache first
    final cacheKey = CacheManager.getFetchCacheKey('restaurants');
    final cachedData = await CacheManager.getFromCache(cacheKey);

    if (cachedData != null) {
      print('🎯 Using cached restaurants data');
      try {
        final List restaurants = cachedData is List
            ? cachedData
            : (cachedData is Map<String, dynamic> ? (cachedData['restaurants'] ?? []) : []);
        return restaurants.map((e) => Restaurant.fromJson(e)).toList();
      } catch (e) {
        print('⚠️ Failed to parse cached data, fetching fresh: $e');
      }
    }

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

        // Save to cache
        await CacheManager.saveToCache(cacheKey, data);

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
    required String keyword,
    String? city,
    double? lat,
    double? lng,
  }) async {
    if (keyword.trim().isEmpty) {
      throw Exception('Keyword is required for search');
    }

    final params = <String, String>{
      'keyword': keyword,
    };

    if (lat != null && lng != null) {
      params['lat'] = lat.toString();
      params['lng'] = lng.toString();
    } else if (city != null && city.trim().isNotEmpty) {
      params['city'] = city;
    } else {
      throw Exception('Either lat+lng coordinates or city must be provided');
    }

    final endpoint = Uri.parse('${Baseurl.Url}search-restaurants')
        .replace(queryParameters: params)
        .toString();

    // Check cache first
    final cacheKey = CacheManager.getSearchCacheKeyWithLocation(
      'restaurants',
      keyword,
      city: city,
      lat: lat,
      lng: lng,
    );
    final cachedData = await CacheManager.getFromCache(cacheKey);

    if (cachedData != null) {
      print('🎯 Using cached search results for: $keyword in $city');
      try {
        final List restaurants = cachedData is List
            ? cachedData
            : (cachedData is Map<String, dynamic> ? (cachedData['restaurants'] ?? []) : []);
        return restaurants.map((e) => Restaurant.fromJson(e)).toList();
      } catch (e) {
        print('⚠️ Failed to parse cached search data, fetching fresh: $e');
      }
    }

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

        // Save to cache
        await CacheManager.saveToCache(cacheKey, data);

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
    String cacheKeySuffix = '';

    if (lat != null && lng != null) {
      endpoint += 'lat=$lat&lng=$lng';
      cacheKeySuffix = '${lat}_$lng';
    } else if (city != null) {
      endpoint += 'city=$city';
      cacheKeySuffix = city;
    }

    // Check cache first
    final cacheKey = 'cache_nearby_restaurants_$cacheKeySuffix';
    final cachedData = await CacheManager.getFromCache(cacheKey);

    if (cachedData != null) {
      print('🎯 Using cached nearby restaurants data');
      try {
        final List restaurants = cachedData is List ? cachedData : [];
        return restaurants.map((e) => Restaurant.fromJson(e)).toList();
      } catch (e) {
        print('⚠️ Failed to parse cached nearby data, fetching fresh: $e');
      }
    }

    print('📡 Fetching nearby: $endpoint');

    try {
      final response = await _dio.get(endpoint);

      print('✅ Status: ${response.statusCode}');
      print('✅ Data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'];

        // Save to cache
        await CacheManager.saveToCache(cacheKey, data);

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
