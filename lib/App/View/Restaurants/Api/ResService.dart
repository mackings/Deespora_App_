import 'package:dio/dio.dart';
import 'package:dspora/App/View/Restaurants/Model/ResModel.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<List<Restaurant>> fetchRestaurants({
    required String city,
    String? keyword,
  }) async {
    // Build endpoint dynamically
    final endpoint = (keyword == null || keyword.isEmpty)
        ? 'https://deesporabackend.vercel.app/restaurants?city=$city'
        : 'https://deesporabackend.vercel.app/search-restaurants?city=$city&keyword=$keyword';

    final response = await _dio.get(endpoint);

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'];
      return data.map((e) => Restaurant.fromJson(e)).toList();
    } else {
      print(response.data);
      throw Exception('Failed to load restaurants');
    }
  }
}
