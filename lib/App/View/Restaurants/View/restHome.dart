import 'package:dspora/App/View/Restaurants/Api/ResService.dart';
import 'package:dspora/App/View/Restaurants/Model/ResModel.dart';
import 'package:dspora/App/View/Restaurants/View/Details.dart';
import 'package:dspora/App/View/Restaurants/Widgets/storefront.dart';
import 'package:dspora/App/View/Widgets/GLOBAL/SFront.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureHeader.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureSearch.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/LocPicker.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:dspora/App/View/Widgets/ResFilter.dart';
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

  String _selectedCity = 'US';
  String _cacheKey = 'US'; // Track which cache key has the data
  final Map<String, List<Restaurant>> _restaurantsCache = {};
  List<Restaurant> _filteredRestaurants = [];

  late Future<List<Restaurant>> _restaurantsFuture;

  // ✅ Simple filter state - only status
  String _selectedStatus = 'All';
  bool _isDataLoaded = false;
  bool _isApiSearch = false;
  bool _isLocationSearch = false;
  bool _useLocationResults = false;
  bool _userSelectedCity = false;
  double? _userLat;
  double? _userLng;

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
    _restaurantsFuture = _fetchAndCacheRestaurants('US');
    _loadUserLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('⚠️ Location permission denied');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 10));
      _userLat = pos.latitude;
      _userLng = pos.longitude;

      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (placemarks.isNotEmpty) {
        final detectedCity = placemarks.first.locality ?? 'US';
        debugPrint("📍 User city detected: $detectedCity");
        if (_userSelectedCity) {
          return;
        }

        setState(() {
          _selectedCity = detectedCity;
        });

        if (_userLat != null && _userLng != null) {
          await _loadNearbyRestaurants(_userLat!, _userLng!);
        } else if (_restaurantsCache.containsKey(_cacheKey)) {
          // Apply filters using the cache key (which is 'US')
          _applyAllFilters(_cacheKey);
        }
      }
    } catch (e) {
      debugPrint("❌ Error getting location: $e");
    }
  }

  String _locationCacheKey(double lat, double lng) {
    return 'nearby_${lat.toStringAsFixed(5)}_${lng.toStringAsFixed(5)}';
  }

  Future<void> _loadNearbyRestaurants(double lat, double lng) async {
    setState(() {
      _isDataLoaded = false;
      _useLocationResults = true;
      _cacheKey = _locationCacheKey(lat, lng);
    });

    try {
      final results = await _apiService.fetchNearbyRestaurants(
        lat: lat,
        lng: lng,
      );
      setState(() {
        _restaurantsCache[_cacheKey] = results;
        _isDataLoaded = true;
        _restaurantsFuture = Future.value(results);
      });
      _applyAllFilters(_cacheKey);
    } catch (e) {
      debugPrint('❌ Nearby fetch error: $e');
      setState(() {
        _isDataLoaded = true;
        _useLocationResults = false;
      });
    }
  }

  Future<List<Restaurant>> _fetchAndCacheRestaurants(String city) async {
    if (_restaurantsCache.containsKey(city)) {
      setState(() {
        _isDataLoaded = true;
        _cacheKey = city;
      });
      _applyAllFilters(city);
      return _restaurantsCache[city]!;
    }

    // Use new API method - backend handles caching
    final result = await _apiService.fetchRestaurants();
    _restaurantsCache[city] = result;
    setState(() {
      _isDataLoaded = true;
      _cacheKey = city;
    });
    _applyAllFilters(city);
    return result;
  }

  void _applyAllFilters(String city) {
    if (!_isDataLoaded || !_restaurantsCache.containsKey(city)) {
      debugPrint('⚠️ Cannot apply filters - data not loaded yet');
      return;
    }

    final allRestaurants = _restaurantsCache[city] ?? [];
    
    // 🔥 DEBUG: Print what we're working with
    debugPrint('🔍 Applying filters to ${allRestaurants.length} restaurants');
    debugPrint('   City: $city');
    debugPrint('   Search query: "${_searchController.text}"');
    debugPrint('   Status filter: $_selectedStatus');
    
    List<Restaurant> filtered = allRestaurants;

    // Step 1: Apply city filter (only if city is not 'US')
    if (!_useLocationResults && !_isLocationSearch && city != 'US') {
      filtered = filtered
          .where((r) =>
              r.vicinity.toLowerCase().contains(city.toLowerCase()) ||
              r.name.toLowerCase().contains(city.toLowerCase()))
          .toList();

      // If no results, show all
      if (filtered.isEmpty) {
        debugPrint('   ⚠️ No city matches, showing all');
        filtered = allRestaurants;
      } else {
        debugPrint('   ✅ After city filter: ${filtered.length} restaurants');
      }
    }

    // Step 2: Apply search query
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty && !_isApiSearch) {
      filtered = filtered
          .where((r) =>
              r.name.toLowerCase().contains(query) ||
              r.vicinity.toLowerCase().contains(query))
          .toList();
      debugPrint('   ✅ After search filter: ${filtered.length} restaurants');
    }

    // Step 3: Apply status filter (Open/Closed)
    if (_selectedStatus == 'Open') {
      filtered = filtered.where((r) => r.openNow == true).toList();
      debugPrint('   ✅ After status filter (Open): ${filtered.length} restaurants');
    } else if (_selectedStatus == 'Closed') {
      filtered = filtered.where((r) => r.openNow == false).toList();
      debugPrint('   ✅ After status filter (Closed): ${filtered.length} restaurants');
    }

    debugPrint('   🎯 Final filtered count: ${filtered.length}');

    setState(() {
      _filteredRestaurants = filtered;
    });
  }

  void _loadRestaurants(String city) {
    setState(() {
      _selectedCity = city;
      _cacheKey = city;
      _isDataLoaded = false;
      _isApiSearch = false;
      _isLocationSearch = false;
      _useLocationResults = false;
      _userSelectedCity = true;
      _filteredRestaurants = []; // 🔥 Clear filtered list
      _restaurantsFuture = _fetchAndCacheRestaurants(city);
      _searchController.clear();
      _selectedStatus = 'All'; // 🔥 Reset status filter
    });
  }

  Future<void> _onRefresh() async {
    // Use new API method - backend handles caching
    final freshData = await _apiService.fetchRestaurants();
    setState(() {
      _restaurantsCache[_cacheKey] = freshData;
      _isDataLoaded = true;
      _applyAllFilters(_cacheKey);
      _restaurantsFuture = Future.value(freshData);
    });
  }

  void _onSearchChanged() {
    debugPrint('🔍 _onSearchChanged called');
    final query = _searchController.text.trim();
    debugPrint('   Search text: "$query"');

    // If search is empty, just filter locally
    if (query.isEmpty) {
      _isApiSearch = false;
      _isLocationSearch = false;
      if (_isDataLoaded && _restaurantsCache.containsKey(_cacheKey)) {
        _applyAllFilters(_cacheKey);
      }
      return;
    }

    // If search has 3+ characters, use API search
    if (query.length >= 3) {
      _performApiSearch(query);
    } else {
      // For short queries, filter locally
      if (_isDataLoaded && _restaurantsCache.containsKey(_cacheKey)) {
        _applyAllFilters(_cacheKey);
      }
    }
  }

  // New method to search via API
  Future<void> _performApiSearch(String keyword) async {
    setState(() {
      _isDataLoaded = false;
      _isApiSearch = true;
    });

    try {
      final useLocation =
          !_userSelectedCity && _userLat != null && _userLng != null;
      _isLocationSearch = useLocation;
      debugPrint(
        useLocation
            ? '🔍 Searching via API: $keyword near ($_userLat, $_userLng)'
            : '🔍 Searching via API: $keyword in $_selectedCity',
      );
      final results = await _apiService.searchRestaurants(
        keyword: keyword,
        city: useLocation ? null : _selectedCity,
        lat: useLocation ? _userLat : null,
        lng: useLocation ? _userLng : null,
      );

      setState(() {
        _restaurantsCache[_cacheKey] = results;
        _isDataLoaded = true;
        _restaurantsFuture = Future.value(results);
      });

      _applyAllFilters(_cacheKey);
    } catch (e) {
      debugPrint('❌ Search error: $e');
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  void _onStatusChanged(String status) {
    setState(() {
      _selectedStatus = status;
      _applyAllFilters(_cacheKey);
    });
    Navigator.pop(context); // Close the modal after selection
  }

  // ✅ Show filter modal
  void _showFilterModal() {
    if (!_isDataLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for restaurants to load'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              
              // Filter title
              const Text(
                'Filter Restaurants',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Status filter buttons
              RestaurantStatusFilter(
                selectedStatus: _selectedStatus,
                onStatusChanged: _onStatusChanged,
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
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
          // Search bar with filter button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: FeatureSearch(
                    controller: _searchController,
                    hintText: 'Search Restaurants',
                    onChanged: (value) => _onSearchChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                // ✅ Filter button
                GestureDetector(
                  onTap: _showFilterModal,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF37B6AF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.filter_list,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Restaurant list
          Expanded(
            child: FutureBuilder<List<Restaurant>>(
              future: _restaurantsFuture,
              builder: (context, snapshot) {
                // 🔥 Show loading only if data isn't cached
                if (snapshot.connectionState == ConnectionState.waiting) {
                  if (_isDataLoaded && _filteredRestaurants.isNotEmpty) {
                    // Show cached data while refreshing
                    return _buildListView(_filteredRestaurants);
                  }
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.teal),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _onRefresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // 🔥 Show filtered restaurants (not snapshot.data)
                if (_isDataLoaded) {
                  if (_filteredRestaurants.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isNotEmpty
                                ? 'No restaurants found matching "${_searchController.text}"'
                                : 'No restaurants found',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          if (_searchController.text.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                _searchController.clear();
                              },
                              child: const Text('Clear Search'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }
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

// ✅ Simple Status Filter Component
class RestaurantStatusFilter extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;

  const RestaurantStatusFilter({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  final List<String> _statusOptions = const ['All', 'Open', 'Closed'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _statusOptions.map((status) {
          final isSelected = selectedStatus == status;
          return GestureDetector(
            onTap: () => onStatusChanged(status),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF37B6AF)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
