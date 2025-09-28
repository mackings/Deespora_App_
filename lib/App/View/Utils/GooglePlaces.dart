import 'dart:convert';
import 'package:http/http.dart' as http;
 

class GooglePlacesService {
  final String apiKey;

  GooglePlacesService(this.apiKey);

  Future<List<String>> fetchCities(String input) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=$input'
      '&types=(cities)'
      '&key=$apiKey',
    );

    final res = await http.get(url);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final predictions = data['predictions'] as List<dynamic>;

      return predictions.map((p) => p['description'] as String).toList();
    } else {
      throw Exception('Failed to fetch locations');
    }
  }
}
