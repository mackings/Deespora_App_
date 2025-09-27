import 'package:dspora/App/View/Restaurants/Api/ResService.dart';
import 'package:dspora/App/View/Restaurants/Model/ResModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final restaurantsProvider = FutureProvider<List<Restaurant>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.fetchRestaurants(city: '');
});