import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocationData {
  const AppLocationData({
    required this.city,
    this.lat,
    this.lng,
    this.isUserSelected = false,
  });

  final String city;
  final double? lat;
  final double? lng;
  final bool isUserSelected;

  bool get hasCoordinates => lat != null && lng != null;
}

class AppLocationService {
  AppLocationService._();

  static const String _detectedCityKey = 'app_detected_city';
  static const String _detectedLatKey = 'app_detected_lat';
  static const String _detectedLngKey = 'app_detected_lng';
  static const String _preferredCityKey = 'app_preferred_city';

  static Future<AppLocationData> getActiveLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final preferredCity = prefs.getString(_preferredCityKey);

    if (preferredCity != null && preferredCity.trim().isNotEmpty) {
      return AppLocationData(city: preferredCity.trim(), isUserSelected: true);
    }

    final cachedDetectedLocation = _getCachedDetectedLocation(prefs);
    if (cachedDetectedLocation != null) {
      return cachedDetectedLocation;
    }

    final detectedLocation = await detectAndSaveLocation();
    return detectedLocation ?? const AppLocationData(city: 'US');
  }

  static Future<AppLocationData?> detectAndSaveLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('⚠️ App location unavailable: permission denied');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(const Duration(seconds: 10));

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final locality = placemarks.isNotEmpty ? placemarks.first.locality : null;
      final city = locality == null || locality.trim().isEmpty
          ? 'US'
          : locality.trim();

      final location = AppLocationData(
        city: city,
        lat: position.latitude,
        lng: position.longitude,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_detectedCityKey, city);
      await prefs.setDouble(_detectedLatKey, position.latitude);
      await prefs.setDouble(_detectedLngKey, position.longitude);

      return location;
    } catch (e) {
      debugPrint('❌ Failed to detect app location: $e');
      return null;
    }
  }

  static Future<void> saveUserSelectedCity(String city) async {
    final normalizedCity = city.trim();
    if (normalizedCity.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferredCityKey, normalizedCity);
  }

  static Future<void> clearUserSelectedCity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_preferredCityKey);
  }

  static AppLocationData? _getCachedDetectedLocation(SharedPreferences prefs) {
    final city = prefs.getString(_detectedCityKey);
    final lat = prefs.getDouble(_detectedLatKey);
    final lng = prefs.getDouble(_detectedLngKey);

    if (city == null || city.trim().isEmpty) {
      return null;
    }

    return AppLocationData(city: city.trim(), lat: lat, lng: lng);
  }
}
