import 'package:dspora/App/View/Restaurants/Api/ResService.dart';
import 'package:dspora/App/View/Restaurants/Model/ResModel.dart';
import 'package:dspora/App/View/Restaurants/Providers/resProvider.dart';
import 'package:dspora/App/View/Restaurants/View/Details.dart';
import 'package:dspora/App/View/Restaurants/Widgets/storefront.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureHeader.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/LocPicker.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class RestaurantHome extends StatefulWidget {
  const RestaurantHome({super.key});

  @override
  State<RestaurantHome> createState() => _RestaurantHomeState();
}

class _RestaurantHomeState extends State<RestaurantHome> {
  final ApiService _apiService = ApiService();

  String _selectedCity = 'London';

  // ✅ Cache for all cities
  final Map<String, List<Restaurant>> _restaurantsCache = {};

  late Future<List<Restaurant>> _restaurantsFuture;

  @override
  void initState() {
    super.initState();
    _restaurantsFuture = _fetchAndCacheRestaurants(_selectedCity);
  }

  /// ✅ Fetch from cache first, otherwise call API
  Future<List<Restaurant>> _fetchAndCacheRestaurants(String city) async {
    // if we have the city cached, return it immediately
    if (_restaurantsCache.containsKey(city)) {
      return _restaurantsCache[city]!;
    }

    // otherwise fetch from API
    final result = await _apiService.fetchRestaurants(city: city);
    _restaurantsCache[city] = result; // save to cached
    return result;
  }

  void _loadRestaurants(String city) {
    setState(() {
      _selectedCity = city;
      _restaurantsFuture = _fetchAndCacheRestaurants(city);
    });
  }

  /// ✅ Force refresh (ignore cache)
  Future<void> _onRefresh() async {
    final freshData = await _apiService.fetchRestaurants(city: _selectedCity);
    setState(() {
      _restaurantsCache[_selectedCity] = freshData;
      _restaurantsFuture = Future.value(freshData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FeatureHeader(
        title: "Restaurants",
        location: _selectedCity,
        onBack: () => Navigator.pop(context),
        onLocationTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            builder: (context) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: CitySelector(
                  cities: [
                    'London','Lagos','New York','Paris','Tokyo',
                    'Dubai','Johannesburg','Cairo','Nairobi',
                    'Toronto','Sydney','Berlin','Moscow','Rio de Janeiro',
                  ],
                  onCitySelected: (city) {
                    Navigator.pop(context);
                    _loadRestaurants(city);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected: $city')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),

      body: FutureBuilder<List<Restaurant>>(
        future: _restaurantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // show cached data if available while loading new data
            if (_restaurantsCache.containsKey(_selectedCity)) {
              return _buildListView(_restaurantsCache[_selectedCity]!);
            }
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return _buildListView(snapshot.data!);
          }

          return const Center(child: Text('No restaurants found.'));
        },
      ),
    );
  }

  Widget _buildListView(List<Restaurant> restaurants) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final r = restaurants[index];
          return StoreFront(
            imageUrl: r.photoReferences.isNotEmpty
                ? r.photoReferences.first
                : Images.Store,
            storeName: r.name,
            category: "Restaurant",
            location: r.vicinity,
            rating: r.rating,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RestaurantDetailScreen(restaurant: r),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
