import 'package:dio/dio.dart';
import 'package:dspora/App/View/Catering/Model/cateringModel.dart';
import 'package:dspora/Constants/BaseUrl.dart';
import 'package:dspora/App/Services/CacheManager.dart';

class CateringService {
  final Dio _dio = Dio();

  /// Fetch all catering services (cached on backend)
  Future<List<Catering>> fetchCaterings({
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

    final endpoint = Uri.parse('${Baseurl.Url}catering')
        .replace(queryParameters: params)
        .toString();

    // Check cache first
    final cacheKey = CacheManager.getFetchCacheKeyWithLocation(
      'catering',
      city: city,
      lat: lat,
      lng: lng,
    );
    final cachedData = await CacheManager.getFromCache(cacheKey);

    if (cachedData != null) {
      print('🎯 Using cached catering data');
      try {
        final List caterings = cachedData is List
            ? cachedData
            : (cachedData is Map<String, dynamic>
                ? (cachedData['catering'] ??
                    cachedData['caterings'] ??
                    cachedData['restaurants'] ??
                    [])
                : []);
        return caterings.map((e) => Catering.fromJson(e)).toList();
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
        final List caterings = data is List
            ? data
            : (data is Map<String, dynamic>
                ? (data['catering'] ??
                    data['caterings'] ??
                    data['restaurants'] ??
                    [])
                : []);
        if (caterings is! List) {
          throw Exception('Invalid data format: ${response.data}');
        }

        // Save to cache
        await CacheManager.saveToCache(cacheKey, data);

        return caterings.map((e) => Catering.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response: ${response.data}');
      }
    } catch (e) {
      print('❌ API error: $e');
      throw Exception('Failed to load catering data: $e');
    }
  }

  /// Search catering by keyword and city
  Future<List<Catering>> searchCatering({
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

    final endpoint = Uri.parse('${Baseurl.Url}search-catering')
        .replace(queryParameters: params)
        .toString();

    // Check cache first
    final cacheKey = CacheManager.getSearchCacheKeyWithLocation(
      'catering',
      keyword,
      city: city,
      lat: lat,
      lng: lng,
    );
    final cachedData = await CacheManager.getFromCache(cacheKey);

    if (cachedData != null) {
      print('🎯 Using cached search results for: $keyword in $city');
      try {
        final List caterings = cachedData is List
            ? cachedData
            : (cachedData is Map<String, dynamic>
                ? (cachedData['catering'] ??
                    cachedData['caterings'] ??
                    cachedData['restaurants'] ??
                    [])
                : []);
        return caterings.map((e) => Catering.fromJson(e)).toList();
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
        final List caterings = data is List
            ? data
            : (data is Map<String, dynamic>
                ? (data['catering'] ??
                    data['caterings'] ??
                    data['restaurants'] ??
                    [])
                : []);
        if (caterings is! List) {
          throw Exception('Invalid data format: ${response.data}');
        }

        // Save to cache
        await CacheManager.saveToCache(cacheKey, data);

        return caterings.map((e) => Catering.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response: ${response.data}');
      }
    } catch (e) {
      print('❌ API error: $e');
      throw Exception('Failed to search catering: $e');
    }
  }
}
