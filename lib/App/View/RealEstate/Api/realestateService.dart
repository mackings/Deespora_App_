import 'package:dio/dio.dart';
import 'package:dspora/App/View/RealEstate/Model/realestateModel.dart';
import 'package:dspora/Constants/BaseUrl.dart';

class WorshipService {
  final Dio _dio = Dio();

  /// Fetch all worship/church listings (cached on backend)
  Future<List<WorshipModel>> fetchWorship() async {
    const endpoint = '${Baseurl.Url}worship';

    print('📡 Fetching: $endpoint');

    try {
      final response = await _dio.get(endpoint);

      print('✅ Status: ${response.statusCode}');
      print('✅ Data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Handle nested data structure: data.worship or data directly
        final dynamic responseData = response.data['data'];
        final List data = responseData is Map
            ? (responseData['worship'] as List? ?? [])
            : (responseData as List? ?? []);

        print('✅ Parsed ${data.length} worship places');
        return data.map((e) => WorshipModel.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response: ${response.data}');
      }
    } catch (e) {
      print('❌ API error: $e');
      throw Exception('Failed to load worship data: $e');
    }
  }

  /// Search worship/church listings by keyword and city
  Future<List<WorshipModel>> searchWorship({
    required String city,
    required String keyword,
  }) async {
    final endpoint =
        '${Baseurl.Url}search-worship?city=$city&keyword=$keyword';

    print('📡 Searching: $endpoint');

    try {
      final response = await _dio.get(endpoint);

      print('✅ Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Handle nested data structure: data.worship
        final dynamic responseData = response.data['data'];
        final List data = responseData is Map
            ? (responseData['worship'] as List? ?? [])
            : (responseData as List? ?? []);

        print('✅ Found ${data.length} worship places');
        return data.map((e) => WorshipModel.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response: ${response.data}');
      }
    } catch (e) {
      print('❌ API error: $e');
      throw Exception('Failed to search worship: $e');
    }
  }
}
