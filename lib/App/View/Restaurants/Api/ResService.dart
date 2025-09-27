import 'package:dio/dio.dart';
import 'package:dspora/App/View/Restaurants/Model/ResModel.dart';


class ApiService {
  final Dio _dio = Dio();

  Future<List<Restaurant>> fetchRestaurants() async {
    const url = "https://deesporabackend.vercel.app/restaurants";
    final response = await _dio.get(url);

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'];
      return data.map((e) => Restaurant.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load restaurants');
    }
  }
}
