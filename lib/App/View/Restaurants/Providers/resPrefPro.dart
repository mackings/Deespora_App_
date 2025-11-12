import 'dart:convert';
import 'package:dspora/App/View/Restaurants/Model/saveRes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantPreferencesService {
  static const String _restaurantKey = 'saved_restaurants';

  static Future<bool> saveRestaurant(SavedRestaurant restaurant) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<SavedRestaurant> restaurants = await getSavedRestaurants();
      
      final exists = restaurants.any((r) => r.name == restaurant.name);
      if (exists) return false;
      
      restaurants.add(restaurant);
      final jsonList = restaurants.map((r) => r.toJson()).toList();
      return await prefs.setString(_restaurantKey, jsonEncode(jsonList));
    } catch (e) {
      return false;
    }
  }

  static Future<List<SavedRestaurant>> getSavedRestaurants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_restaurantKey);
      
      if (jsonString == null || jsonString.isEmpty) return [];
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => SavedRestaurant.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}