import 'package:dspora/App/View/Restaurants/Api/ResService.dart';
import 'package:dspora/App/View/Restaurants/Model/ResModel.dart';
import 'package:dspora/App/View/Restaurants/Providers/resProvider.dart';
import 'package:dspora/App/View/Restaurants/View/Details.dart';
import 'package:dspora/App/View/Restaurants/Widgets/storefront.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureHeader.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureSearch.dart';
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
  final TextEditingController _searchController = TextEditingController();

  String _selectedCity = 'US';

  // ✅ Cache for all cities
  final Map<String, List<Restaurant>> _restaurantsCache = {};
  List<Restaurant> _filteredRestaurants = [];

  late Future<List<Restaurant>> _restaurantsFuture;

  @override
  void initState() {
    super.initState();
    _restaurantsFuture = _fetchAndCacheRestaurants(_selectedCity);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// ✅ Fetch from cache first, otherwise call API
  Future<List<Restaurant>> _fetchAndCacheRestaurants(String city) async {
    if (_restaurantsCache.containsKey(city)) {
      _filteredRestaurants = _restaurantsCache[city]!;
      return _restaurantsCache[city]!;
    }

    final result = await _apiService.fetchRestaurants(city: city);
    _restaurantsCache[city] = result;
    _filteredRestaurants = result;
    return result;
  }

  void _loadRestaurants(String city) {
    setState(() {
      _selectedCity = city;
      _restaurantsFuture = _fetchAndCacheRestaurants(city);
      _searchController.clear();
    });
  }

  /// ✅ Force refresh (ignore cache)
  Future<void> _onRefresh() async {
    final freshData = await _apiService.fetchRestaurants(city: _selectedCity);
    setState(() {
      _restaurantsCache[_selectedCity] = freshData;
      _filteredRestaurants = freshData;
      _restaurantsFuture = Future.value(freshData);
    });
  }

  /// ✅ Filter restaurants based on search input
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (_restaurantsCache.containsKey(_selectedCity)) {
      setState(() {
        _filteredRestaurants = _restaurantsCache[_selectedCity]!
            .where((r) => r.name.toLowerCase().contains(query))
            .toList();
      });
    }
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
                    'US',
                  ],
                  onCitySelected: (city) {
                    Navigator.pop(context);
                    _loadRestaurants(city);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected $city')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FeatureSearch(
              controller: _searchController,
              hintText: 'Search Restaurants',
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Restaurant>>(
              future: _restaurantsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  if (_restaurantsCache.containsKey(_selectedCity)) {
                    return _buildListView(_filteredRestaurants);
                  }
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.teal));
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return _buildListView(_filteredRestaurants);
                }

                return const Center(child: Text('No restaurants found.'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Restaurant> restaurants) {
    return RefreshIndicator(
      color: Colors.teal,
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
