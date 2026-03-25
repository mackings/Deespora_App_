import 'package:dspora/App/Services/CacheManager.dart';
import 'package:dspora/App/View/Catering/Model/cateringModel.dart';
import 'package:dspora/App/View/RealEstate/Model/realestateModel.dart';
import 'package:dspora/App/View/Restaurants/Model/ResModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlaceFetchService {
  // Base API URL - adjust to your backend
  static const String baseUrl = 'https://deesporabackend.vercel.app';

  static String _normalize(String value) {
    return value.trim().toLowerCase();
  }

  static String? _extractCityFromAddress(String address) {
    final parts = address
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length >= 2) {
      return parts.last;
    }

    return parts.isNotEmpty ? parts.first : null;
  }

  static bool _matchesItem(
    Map<String, dynamic> item, {
    required String placeId,
    required String name,
    required String address,
  }) {
    final candidateId =
        (item['place_id'] ?? item['placeId'] ?? item['id'] ?? '').toString();
    final candidateName = (item['name'] ?? '').toString();
    final candidateAddress =
        (item['vicinity'] ?? item['formatted_address'] ?? item['address'] ?? '')
            .toString();

    if (placeId.isNotEmpty && candidateId == placeId) {
      return true;
    }

    return _normalize(candidateName) == _normalize(name) &&
        _normalize(candidateAddress) == _normalize(address);
  }

  static List<Map<String, dynamic>> _extractCollection(
    dynamic data,
    List<String> keys,
  ) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }

    if (data is Map<String, dynamic>) {
      for (final key in keys) {
        final value = data[key];
        if (value is List) {
          return value.whereType<Map<String, dynamic>>().toList();
        }
      }
    }

    return const [];
  }

  static Future<List<Map<String, dynamic>>> _fetchDiscoveryItems({
    required String endpoint,
    required Map<String, String> queryParameters,
    required List<String> collectionKeys,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/$endpoint',
      ).replace(queryParameters: queryParameters);
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        return const [];
      }

      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['success'] != true) {
        return const [];
      }

      return _extractCollection(decoded['data'], collectionKeys);
    } catch (e) {
      debugPrint('❌ Error fetching discovery items from $endpoint: $e');
      return const [];
    }
  }

  static Map<String, dynamic>? _findMatchingItem(
    List<Map<String, dynamic>> items, {
    required String placeId,
    required String name,
    required String address,
  }) {
    for (final item in items) {
      if (_matchesItem(item, placeId: placeId, name: name, address: address)) {
        return item;
      }
    }
    return null;
  }

  static Map<String, dynamic>? _extractDetailsPayload(
    dynamic data,
    List<String> keys,
  ) {
    if (data is Map<String, dynamic>) {
      for (final key in keys) {
        final value = data[key];
        if (value is Map<String, dynamic>) {
          return value;
        }
      }
      return data;
    }
    return null;
  }

  /// Fetch Restaurant by ID
  static Future<Restaurant?> fetchRestaurantById(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/restaurants/details?placeId=$placeId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final payload = _extractDetailsPayload(data['data'], [
            'restaurant',
            'place',
            'data',
          ]);
          if (payload != null) {
            return Restaurant.fromJson(payload);
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching restaurant: $e');
      return null;
    }
  }

  static Future<Restaurant?> findCachedRestaurant({
    required String placeId,
    required String name,
    required String address,
  }) async {
    final item = await CacheManager.findCachedDiscoveryItem(
      typeTokens: ['restaurants', 'restaurants_nearby'],
      collectionKeys: ['restaurants'],
      placeId: placeId,
      name: name,
      address: address,
    );
    return item != null ? Restaurant.fromJson(item) : null;
  }

  static Future<Restaurant?> fetchRestaurantDiscoverySnapshot({
    required String placeId,
    required String name,
    required String address,
  }) async {
    final city = _extractCityFromAddress(address);
    if (city == null || city.isEmpty) {
      return null;
    }

    final searchItems = await _fetchDiscoveryItems(
      endpoint: 'search-restaurants',
      queryParameters: {'city': city, 'keyword': name},
      collectionKeys: ['restaurants'],
    );
    final searchMatch = _findMatchingItem(
      searchItems,
      placeId: placeId,
      name: name,
      address: address,
    );
    if (searchMatch != null) {
      return Restaurant.fromJson(searchMatch);
    }

    final discoveryItems = await _fetchDiscoveryItems(
      endpoint: 'restaurants',
      queryParameters: {'city': city},
      collectionKeys: ['restaurants'],
    );
    final discoveryMatch = _findMatchingItem(
      discoveryItems,
      placeId: placeId,
      name: name,
      address: address,
    );
    return discoveryMatch != null ? Restaurant.fromJson(discoveryMatch) : null;
  }

  /// Fetch RealEstate by ID
  static Future<RealEstateModel?> fetchRealEstateById(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/worship/details?placeId=$placeId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final payload = _extractDetailsPayload(data['data'], [
            'worship',
            'realestate',
            'place',
            'data',
          ]);
          if (payload != null) {
            return RealEstateModel.fromJson(payload);
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching real estate: $e');
      return null;
    }
  }

  static Future<RealEstateModel?> findCachedWorship({
    required String placeId,
    required String name,
    required String address,
  }) async {
    final item = await CacheManager.findCachedDiscoveryItem(
      typeTokens: ['worship'],
      collectionKeys: ['worship'],
      placeId: placeId,
      name: name,
      address: address,
    );
    return item != null ? RealEstateModel.fromJson(item) : null;
  }

  static Future<RealEstateModel?> fetchWorshipDiscoverySnapshot({
    required String placeId,
    required String name,
    required String address,
  }) async {
    final city = _extractCityFromAddress(address);
    if (city == null || city.isEmpty) {
      return null;
    }

    final searchItems = await _fetchDiscoveryItems(
      endpoint: 'search-worship',
      queryParameters: {'city': city, 'keyword': name},
      collectionKeys: ['worship'],
    );
    final searchMatch = _findMatchingItem(
      searchItems,
      placeId: placeId,
      name: name,
      address: address,
    );
    if (searchMatch != null) {
      return RealEstateModel.fromJson(searchMatch);
    }

    final discoveryItems = await _fetchDiscoveryItems(
      endpoint: 'worship',
      queryParameters: {'city': city},
      collectionKeys: ['worship'],
    );
    final discoveryMatch = _findMatchingItem(
      discoveryItems,
      placeId: placeId,
      name: name,
      address: address,
    );
    return discoveryMatch != null
        ? RealEstateModel.fromJson(discoveryMatch)
        : null;
  }

  /// Fetch Catering by ID
  static Future<Catering?> fetchCateringById(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/catering/details?placeId=$placeId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final payload = _extractDetailsPayload(data['data'], [
            'catering',
            'place',
            'data',
          ]);
          if (payload != null) {
            return Catering.fromJson(payload);
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching catering: $e');
      return null;
    }
  }

  static Future<Catering?> findCachedCatering({
    required String placeId,
    required String name,
    required String address,
  }) async {
    final item = await CacheManager.findCachedDiscoveryItem(
      typeTokens: ['catering'],
      collectionKeys: ['catering', 'caterings', 'restaurants'],
      placeId: placeId,
      name: name,
      address: address,
    );
    return item != null ? Catering.fromJson(item) : null;
  }

  static Future<Catering?> fetchCateringDiscoverySnapshot({
    required String placeId,
    required String name,
    required String address,
  }) async {
    final city = _extractCityFromAddress(address);
    if (city == null || city.isEmpty) {
      return null;
    }

    final searchItems = await _fetchDiscoveryItems(
      endpoint: 'search-catering',
      queryParameters: {'city': city, 'keyword': name},
      collectionKeys: ['catering', 'caterings'],
    );
    final searchMatch = _findMatchingItem(
      searchItems,
      placeId: placeId,
      name: name,
      address: address,
    );
    if (searchMatch != null) {
      return Catering.fromJson(searchMatch);
    }

    final discoveryItems = await _fetchDiscoveryItems(
      endpoint: 'catering',
      queryParameters: {'city': city},
      collectionKeys: ['catering', 'caterings'],
    );
    final discoveryMatch = _findMatchingItem(
      discoveryItems,
      placeId: placeId,
      name: name,
      address: address,
    );
    return discoveryMatch != null ? Catering.fromJson(discoveryMatch) : null;
  }
}
