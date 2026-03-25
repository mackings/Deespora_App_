import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheManager {
  static const int _cacheDurationDays = 7;
  static const String _cacheVersion = 'v2';
  static const String _discoveryImageCacheResetFlag =
      'cache_invalidation_discovery_images_v3_done';
  static const List<String> _discoveryImageCacheTokens = [
    'restaurants',
    'restaurants_nearby',
    'catering',
    'worship',
  ];

  /// Save data to cache with timestamp
  static Future<void> saveToCache(String key, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': data,
      };
      await prefs.setString(key, jsonEncode(cacheData));
      print('💾 Cached data for key: $key');
    } catch (e) {
      print('❌ Failed to save cache for $key: $e');
    }
  }

  /// Get data from cache if valid (not expired)
  static Future<dynamic> getFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString(key);

      if (cachedString == null) {
        print('📭 No cache found for key: $key');
        return null;
      }

      final cacheData = jsonDecode(cachedString);
      final timestamp = cacheData['timestamp'] as int;
      final cachedDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cachedDate);

      // Check if cache is expired (older than 7 days)
      if (difference.inDays >= _cacheDurationDays) {
        print('⏰ Cache expired for key: $key (${difference.inDays} days old)');
        await prefs.remove(key);
        return null;
      }

      print('✅ Cache hit for key: $key (${difference.inDays} days old)');
      return cacheData['data'];
    } catch (e) {
      print('❌ Failed to read cache for $key: $e');
      return null;
    }
  }

  /// Clear all expired caches
  static Future<void> clearExpiredCaches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      int clearedCount = 0;

      for (final key in keys) {
        if (key.startsWith('cache_')) {
          final cachedString = prefs.getString(key);
          if (cachedString != null) {
            try {
              final cacheData = jsonDecode(cachedString);
              final timestamp = cacheData['timestamp'] as int;
              final cachedDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
              final difference = DateTime.now().difference(cachedDate);

              if (difference.inDays >= _cacheDurationDays) {
                await prefs.remove(key);
                clearedCount++;
              }
            } catch (e) {
              // Invalid cache format, remove it
              await prefs.remove(key);
              clearedCount++;
            }
          }
        }
      }

      if (clearedCount > 0) {
        print('🧹 Cleared $clearedCount expired cache(s)');
      }
    } catch (e) {
      print('❌ Failed to clear expired caches: $e');
    }
  }

  /// Clear all caches manually
  static Future<void> clearAllCaches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      int clearedCount = 0;

      for (final key in keys) {
        if (key.startsWith('cache_')) {
          await prefs.remove(key);
          clearedCount++;
        }
      }

      print('🧹 Cleared all $clearedCount cache(s)');
    } catch (e) {
      print('❌ Failed to clear all caches: $e');
    }
  }

  /// Clear stale discovery/search caches once after backend image updates.
  static Future<void> invalidateDiscoveryImageCachesOnce() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyInvalidated =
          prefs.getBool(_discoveryImageCacheResetFlag) ?? false;

      if (alreadyInvalidated) {
        return;
      }

      final keys = prefs.getKeys();
      int clearedCount = 0;

      for (final key in keys) {
        if (!key.startsWith('cache_')) {
          continue;
        }

        final matchesDiscoveryCache = _discoveryImageCacheTokens.any(
          (token) => key.contains(token),
        );

        if (matchesDiscoveryCache) {
          await prefs.remove(key);
          clearedCount++;
        }
      }

      await prefs.setBool(_discoveryImageCacheResetFlag, true);
      print(
        '🧹 Cleared $clearedCount restaurant/catering/worship cache(s) for fresh image URLs',
      );
    } catch (e) {
      print('❌ Failed to invalidate discovery image caches: $e');
    }
  }

  /// Generate cache key for fetch operations
  static String getFetchCacheKey(String type) {
    return 'cache_fetch_${_cacheVersion}_$type';
  }

  /// Generate cache key for fetch operations with city or coordinates
  static String getFetchCacheKeyWithLocation(
    String type, {
    String? city,
    double? lat,
    double? lng,
  }) {
    if (lat != null && lng != null) {
      final latKey = lat.toStringAsFixed(5);
      final lngKey = lng.toStringAsFixed(5);
      return 'cache_fetch_${_cacheVersion}_${type}_coords_${latKey}_$lngKey';
    }

    if (city == null || city.trim().isEmpty) {
      return 'cache_fetch_${_cacheVersion}_${type}_unknown';
    }

    final normalizedCity = city.toLowerCase().trim();
    return 'cache_fetch_${_cacheVersion}_${type}_city_$normalizedCity';
  }

  /// Generate cache key for search operations
  static String getSearchCacheKey(String type, String city, String keyword) {
    final normalizedCity = city.toLowerCase().trim();
    final normalizedKeyword = keyword.toLowerCase().trim();
    return 'cache_search_${_cacheVersion}_${type}_${normalizedCity}_$normalizedKeyword';
  }

  /// Generate cache key for search operations with city or coordinates
  static String getSearchCacheKeyWithLocation(
    String type,
    String keyword, {
    String? city,
    double? lat,
    double? lng,
  }) {
    final normalizedKeyword = keyword.toLowerCase().trim();
    if (lat != null && lng != null) {
      final latKey = lat.toStringAsFixed(5);
      final lngKey = lng.toStringAsFixed(5);
      return 'cache_search_${_cacheVersion}_${type}_coords_${latKey}_${lngKey}_$normalizedKeyword';
    }

    if (city == null || city.trim().isEmpty) {
      return 'cache_search_${_cacheVersion}_${type}_unknown_$normalizedKeyword';
    }

    return getSearchCacheKey(type, city, keyword);
  }

  static bool _matchesString(String? left, String? right) {
    if (left == null || right == null) {
      return false;
    }
    return left.trim().toLowerCase() == right.trim().toLowerCase();
  }

  static List<Map<String, dynamic>> _extractItems(
    dynamic data,
    List<String> collectionKeys,
  ) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }

    if (data is Map<String, dynamic>) {
      for (final key in collectionKeys) {
        final value = data[key];
        if (value is List) {
          return value.whereType<Map<String, dynamic>>().toList();
        }
      }
    }

    return const [];
  }

  static Future<Map<String, dynamic>?> findCachedDiscoveryItem({
    required List<String> typeTokens,
    required List<String> collectionKeys,
    String? placeId,
    String? name,
    String? address,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      for (final key in prefs.getKeys()) {
        if (!key.startsWith('cache_')) {
          continue;
        }

        final matchesType = typeTokens.any((token) => key.contains(token));
        if (!matchesType) {
          continue;
        }

        final cachedString = prefs.getString(key);
        if (cachedString == null) {
          continue;
        }

        final decoded = jsonDecode(cachedString);
        final data = decoded is Map<String, dynamic> ? decoded['data'] : null;
        final items = _extractItems(data, collectionKeys);

        for (final item in items) {
          final candidateId =
              (item['place_id'] ?? item['placeId'] ?? '').toString();
          final candidateName = (item['name'] ?? '').toString();
          final candidateAddress =
              (item['vicinity'] ??
                      item['formatted_address'] ??
                      item['address'] ??
                      '')
                  .toString();

          final idMatches =
              placeId != null && placeId.isNotEmpty && candidateId == placeId;
          final textMatches =
              _matchesString(candidateName, name) &&
              _matchesString(candidateAddress, address);

          if (idMatches || textMatches) {
            return item;
          }
        }
      }
    } catch (e) {
      print('❌ Failed to find cached discovery item: $e');
    }

    return null;
  }
}
