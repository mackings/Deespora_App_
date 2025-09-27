import 'package:dspora/App/View/Restaurants/Api/ResService.dart';
import 'package:dspora/App/View/Restaurants/Model/ResModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// fetches restaurants for the given city
final restaurantsProvider =
    FutureProvider.family<List<Restaurant>, String>((ref, city) async {
  final api = ref.read(apiServiceProvider);
  return api.fetchRestaurants(city: city);
});