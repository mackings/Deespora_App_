import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheManager {
  static const int _cacheDurationDays = 7;

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

  /// Generate cache key for fetch operations
  static String getFetchCacheKey(String type) {
    return 'cache_fetch_$type';
  }

  /// Generate cache key for search operations
  static String getSearchCacheKey(String type, String city, String keyword) {
    final normalizedCity = city.toLowerCase().trim();
    final normalizedKeyword = keyword.toLowerCase().trim();
    return 'cache_search_${type}_${normalizedCity}_$normalizedKeyword';
  }
}
