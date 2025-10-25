import 'package:dio/dio.dart';
import 'package:dspora/App/View/RealEstate/Model/realestateModel.dart';

class RealEstateService {
  final Dio _dio = Dio();

  Future<List<RealEstateModel>> fetchRealEstate({
    required String city,
    String? keyword,
  }) async {
    final endpoint = (keyword == null || keyword.isEmpty)
        ? 'https://deesporabackend.vercel.app/realestate?city=$city'
        : 'https://deesporabackend.vercel.app/search-realestate?city=$city&keyword=$keyword';

    print('📡 Fetching: $endpoint');

    try {
      final response = await _dio.get(endpoint);

      print('✅ Status: ${response.statusCode}');
      print('✅ Data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'];
        return data.map((e) => RealEstateModel.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response: ${response.data}');
      }
    } catch (e) {
      print('❌ API error: $e');
      throw Exception('Failed to load real estate data: $e');
    }
  }
}