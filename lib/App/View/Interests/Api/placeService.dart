import 'package:dspora/App/View/Catering/Model/cateringModel.dart';
import 'package:dspora/App/View/RealEstate/Model/realestateModel.dart';
import 'package:dspora/App/View/Restaurants/Model/ResModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlaceFetchService {
  // Base API URL - adjust to your backend
  static const String baseUrl = 'https://deesporabackend.vercel.app';

  /// Fetch Restaurant by ID
  static Future<Restaurant?> fetchRestaurantById(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/restaurants/details?placeId=$placeId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Restaurant.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching restaurant: $e');
      return null;
    }
  }

  /// Fetch RealEstate by ID
  static Future<RealEstateModel?> fetchRealEstateById(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/realestate/details?placeId=$placeId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return RealEstateModel.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching real estate: $e');
      return null;
    }
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
          return Catering.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching catering: $e');
      return null;
    }
  }
}