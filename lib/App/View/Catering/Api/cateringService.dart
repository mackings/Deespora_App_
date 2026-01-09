import 'package:dio/dio.dart';
import 'package:dspora/App/View/Catering/Model/cateringModel.dart';
import 'package:dspora/Constants/BaseUrl.dart';

class CateringService {
  final Dio _dio = Dio();

  /// Fetch all catering services (cached on backend)
  Future<List<Catering>> fetchCaterings() async {
    const endpoint = '${Baseurl.Url}catering';

    print('📡 Fetching: $endpoint');

    try {
      final response = await _dio.get(endpoint);

      print('✅ Status: ${response.statusCode}');
      print('✅ Data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final dynamic data = response.data['data'];
        final List caterings = data is List
            ? data
            : (data is Map<String, dynamic>
                ? (data['catering'] ??
                    data['caterings'] ??
                    data['restaurants'] ??
                    [])
                : []);
        if (caterings is! List) {
          throw Exception('Invalid data format: ${response.data}');
        }
        return caterings.map((e) => Catering.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response: ${response.data}');
      }
    } catch (e) {
      print('❌ API error: $e');
      throw Exception('Failed to load catering data: $e');
    }
  }

  /// Search catering by keyword and city
  Future<List<Catering>> searchCatering({
    required String city,
    required String keyword,
  }) async {
    final endpoint =
        '${Baseurl.Url}search-catering?city=$city&keyword=$keyword';

    print('📡 Searching: $endpoint');

    try {
      final response = await _dio.get(endpoint);

      print('✅ Status: ${response.statusCode}');
      print('✅ Data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final dynamic data = response.data['data'];
        final List caterings = data is List
            ? data
            : (data is Map<String, dynamic>
                ? (data['catering'] ??
                    data['caterings'] ??
                    data['restaurants'] ??
                    [])
                : []);
        if (caterings is! List) {
          throw Exception('Invalid data format: ${response.data}');
        }
        return caterings.map((e) => Catering.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response: ${response.data}');
      }
    } catch (e) {
      print('❌ API error: $e');
      throw Exception('Failed to search catering: $e');
    }
  }
}
