import 'package:dio/dio.dart';
import 'package:dspora/App/View/RealEstate/Model/realestateModel.dart';
import 'package:dspora/Constants/BaseUrl.dart';
import 'package:dspora/App/Services/CacheManager.dart';

class WorshipService {
  final Dio _dio = Dio();

  /// Fetch all worship/church listings (cached on backend)
  Future<List<WorshipModel>> fetchWorship({
    String? city,
    double? lat,
    double? lng,
  }) async {
    final params = <String, String>{};

    if (lat != null && lng != null) {
      params['lat'] = lat.toString();
      params['lng'] = lng.toString();
    } else if (city != null && city.trim().isNotEmpty) {
      params['city'] = city;
    } else {
      throw Exception('Either lat+lng coordinates or city must be provided');
    }

    final endpoint = Uri.parse('${Baseurl.Url}worship')
        .replace(queryParameters: params)
        .toString();

    // Check cache first
    final cacheKey = CacheManager.getFetchCacheKeyWithLocation(
      'worship',
      city: city,
      lat: lat,
      lng: lng,
    );
    final cachedData = await CacheManager.getFromCache(cacheKey);

    if (cachedData != null) {
      print('🎯 Using cached worship data');
      try {
        final List data = cachedData is Map
            ? (cachedData['worship'] as List? ?? [])
            : (cachedData as List? ?? []);
        return data.map((e) => WorshipModel.fromJson(e)).toList();
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
        // Handle nested data structure: data.worship or data directly
        final dynamic responseData = response.data['data'];
        final List data = responseData is Map
            ? (responseData['worship'] as List? ?? [])
            : (responseData as List? ?? []);

        print('✅ Parsed ${data.length} worship places');

        // Save to cache
        await CacheManager.saveToCache(cacheKey, responseData);

        return data.map((e) => WorshipModel.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response: ${response.data}');
      }
    } catch (e) {
      print('❌ API error: $e');
      throw Exception('Failed to load worship data: $e');
    }
  }

  /// Search worship/church listings by keyword and city
  Future<List<WorshipModel>> searchWorship({
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

    final endpoint = Uri.parse('${Baseurl.Url}search-worship')
        .replace(queryParameters: params)
        .toString();

    // Check cache first
    final cacheKey = CacheManager.getSearchCacheKeyWithLocation(
      'worship',
      keyword,
      city: city,
      lat: lat,
      lng: lng,
    );
    final cachedData = await CacheManager.getFromCache(cacheKey);

    if (cachedData != null) {
      print('🎯 Using cached search results for: $keyword in $city');
      try {
        final List data = cachedData is Map
            ? (cachedData['worship'] as List? ?? [])
            : (cachedData as List? ?? []);
        return data.map((e) => WorshipModel.fromJson(e)).toList();
      } catch (e) {
        print('⚠️ Failed to parse cached search data, fetching fresh: $e');
      }
    }

    print('📡 Searching: $endpoint');

    try {
      final response = await _dio.get(endpoint);

      print('✅ Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Handle nested data structure: data.worship
        final dynamic responseData = response.data['data'];
        final List data = responseData is Map
            ? (responseData['worship'] as List? ?? [])
            : (responseData as List? ?? []);

        print('✅ Found ${data.length} worship places');

        // Save to cache
        await CacheManager.saveToCache(cacheKey, responseData);

        return data.map((e) => WorshipModel.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response: ${response.data}');
      }
    } catch (e) {
      print('❌ API error: $e');
      throw Exception('Failed to search worship: $e');
    }
  }
}
