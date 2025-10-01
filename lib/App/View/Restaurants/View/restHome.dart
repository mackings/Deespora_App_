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




import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class RestaurantHome extends StatefulWidget {
  const RestaurantHome({super.key});

  @override
  State<RestaurantHome> createState() => _RestaurantHomeState();
}

class _RestaurantHomeState extends State<RestaurantHome> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCity = 'US'; // default to load all
  final Map<String, List<Restaurant>> _restaurantsCache = {};
  List<Restaurant> _filteredRestaurants = [];

  late Future<List<Restaurant>> _restaurantsFuture;
  
final List<String> usCities = [
  "New York",
  "Los Angeles",
  "Chicago",
  "Houston",
  "Miami",
  "San Francisco",
  "Boston",
  "Washington",
  "Seattle",
  "Atlanta",
  "Las Vegas",
  "Orlando",
  "Dallas",
  "Denver",
  "Philadelphia",
  "Phoenix",
  "San Diego",
  "Austin",
  "Nashville",
  "Portland",
  "Detroit",
  "Minneapolis",
  "Charlotte",
  "Indianapolis",
  "Columbus",
  "San Antonio",
  "Tampa",
  "Baltimore",
  "Cleveland",
  "Kansas City",
];


  @override
  void initState() {
    super.initState();

    // ✅ Load all US restaurants first
    _restaurantsFuture = _fetchAndCacheRestaurants('US');

    // ✅ Detect user’s location, but don’t override the list yet
    _loadUserLocation();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// ✅ Detect user’s location (but do not reload restaurants automatically)
  Future<void> _loadUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('⚠️ Location permission denied');
        return; // stay on US restaurants
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 10));

      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (placemarks.isNotEmpty) {
        final detectedCity = placemarks.first.locality ?? 'US';
        debugPrint("📍 User city detected: $detectedCity");

        // ✅ just update the header display
        setState(() {
          _selectedCity = detectedCity;
        });
      }
    } catch (e) {
      debugPrint("❌ Error getting location: $e");
      // keep default US
    }
  }

  /// ✅ Fetch from cache or API
  Future<List<Restaurant>> _fetchAndCacheRestaurants(String city) async {
    if (_restaurantsCache.containsKey(city)) {
      _applyCityFilter(city);
      return _restaurantsCache[city]!;
    }

    final result = await _apiService.fetchRestaurants(city: city);
    _restaurantsCache[city] = result;
    _applyCityFilter(city);
    return result;
  }

  /// ✅ Apply filtering
  void _applyCityFilter(String city) {
    final allRestaurants = _restaurantsCache[city] ?? [];
    _filteredRestaurants = allRestaurants
        .where((r) =>
            r.vicinity.toLowerCase().contains(city.toLowerCase()) ||
            r.name.toLowerCase().contains(city.toLowerCase()))
        .toList();

    if (_filteredRestaurants.isEmpty) {
      _filteredRestaurants = allRestaurants;
    }
  }

  /// ✅ Called when user selects city
  void _loadRestaurants(String city) {
    setState(() {
      _selectedCity = city;
      _restaurantsFuture = _fetchAndCacheRestaurants(city);
      _searchController.clear();
    });
  }

  /// ✅ Refresh ignoring cache
  Future<void> _onRefresh() async {
    final freshData = await _apiService.fetchRestaurants(city: _selectedCity);
    setState(() {
      _restaurantsCache[_selectedCity] = freshData;
      _applyCityFilter(_selectedCity);
      _restaurantsFuture = Future.value(freshData);
    });
  }

  /// ✅ Search filtering
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (_restaurantsCache.containsKey(_selectedCity)) {
      setState(() {
        _filteredRestaurants = _restaurantsCache[_selectedCity]!
            .where((r) =>
                r.name.toLowerCase().contains(query) ||
                r.vicinity.toLowerCase().contains(query))
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
                  cities: usCities,
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
                    child: CircularProgressIndicator(color: Colors.teal),
                  );
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
