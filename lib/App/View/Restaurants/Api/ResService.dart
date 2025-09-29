import 'package:dio/dio.dart';
import 'package:dspora/App/View/Restaurants/Model/ResModel.dart';

class ApiService {
  
  final Dio _dio = Dio();

  Future<List<Restaurant>> fetchRestaurants({
    required String city,
    String? keyword,
  }) async {
    final endpoint = (keyword == null || keyword.isEmpty)
        ? 'https://deesporabackend.vercel.app/restaurants'
        : 'https://deesporabackend.vercel.app/search-restaurants?city=$city&keyword=$keyword';

    print('📡 Fetching: $endpoint');

    try {
      final response = await _dio.get(endpoint);

      print('✅ Status: ${response.statusCode}');
      print('✅ Data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'];
        return data.map((e) => Restaurant.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response: ${response.data}');
      }
    } catch (e) {
      print('❌ API error: $e');
      throw Exception('Failed to load restaurants: $e');
    }
  }
}
