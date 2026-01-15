import 'package:dspora/App/View/Catering/Api/cateringService.dart';
import 'package:dspora/App/View/Catering/Model/cateringModel.dart';
import 'package:dspora/App/View/Utils/navigator.dart';
import 'package:dspora/App/View/Widgets/GLOBAL/FrontDetails.dart';
import 'package:dspora/App/View/Widgets/GLOBAL/SFront.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureHeader.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureSearch.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/LocPicker.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class CateringHome extends StatefulWidget {
  const CateringHome({super.key});

  @override
  State<CateringHome> createState() => _CateringHomeState();
}

class _CateringHomeState extends State<CateringHome> {
  final CateringService _cateringService = CateringService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCity = 'US';
  String _cacheKey = 'US'; // Track which cache key has the data
  final Map<String, List<Catering>> _cateringCache = {};
  List<Catering> _filteredCatering = [];
  bool _isApiSearch = false;
  bool _isLocationSearch = false;
  bool _userSelectedCity = false;
  double? _userLat;
  double? _userLng;

  late Future<List<Catering>> _cateringFuture;

  // ✅ Filter state
  String _selectedStatus = 'All';
  bool _isDataLoaded = false;

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
    _cateringFuture = _fetchAndCacheCatering('US');
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

        // Apply filters using the cache key (which is 'US')
        if (_cateringCache.containsKey(_cacheKey)) {
          _applyAllFilters(_cacheKey);
        }
      }
    } catch (e) {
      debugPrint("❌ Error getting location: $e");
    }
  }

  Future<List<Catering>> _fetchAndCacheCatering(String city) async {
    if (_cateringCache.containsKey(city)) {
      setState(() {
        _isDataLoaded = true;
        _cacheKey = city;
      });
      _applyAllFilters(city);
      return _cateringCache[city]!;
    }

    // Use new API method - backend handles caching
    final result = await _cateringService.fetchCaterings();
    _cateringCache[city] = result;
    setState(() {
      _isDataLoaded = true;
      _cacheKey = city;
    });
    _applyAllFilters(city);
    return result;
  }

  // ✅ Apply all filters (city, search, status)
  void _applyAllFilters(String city) {
    if (!_isDataLoaded || !_cateringCache.containsKey(city)) {
      debugPrint('⚠️ Cannot apply filters - data not loaded yet');
      return;
    }

    final allCatering = _cateringCache[city] ?? [];
    
    // 🔥 DEBUG: Print what we're working with
    debugPrint('🔍 Applying filters to ${allCatering.length} catering companies');
    debugPrint('   City: $city');
    debugPrint('   Search query: "${_searchController.text}"');
    debugPrint('   Status filter: $_selectedStatus');
    
    List<Catering> filtered = allCatering;

    // Step 1: Apply city filter (only if city is not 'US')
    if (!_isLocationSearch && city != 'US') {
      filtered = filtered
          .where((r) =>
              r.address.toLowerCase().contains(city.toLowerCase()) ||
              r.name.toLowerCase().contains(city.toLowerCase()))
          .toList();

      // If no results, show all
      if (filtered.isEmpty) {
        debugPrint('   ⚠️ No city matches, showing all');
        filtered = allCatering;
      } else {
        debugPrint('   ✅ After city filter: ${filtered.length} catering companies');
      }
    }

    // Step 2: Apply search query (skip if API already filtered)
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty && !_isApiSearch) {
      filtered = filtered
          .where((r) =>
              r.name.toLowerCase().contains(query) ||
              r.address.toLowerCase().contains(query))
          .toList();
      debugPrint('   ✅ After search filter: ${filtered.length} catering companies');
    }

    // Step 3: Apply status filter (Open/Closed)
    if (_selectedStatus == 'Open') {
      filtered = filtered.where((c) => c.openNow == true).toList();
      debugPrint('   ✅ After status filter (Open): ${filtered.length} catering companies');
    } else if (_selectedStatus == 'Closed') {
      filtered = filtered.where((c) => c.openNow == false).toList();
      debugPrint('   ✅ After status filter (Closed): ${filtered.length} catering companies');
    }

    debugPrint('   🎯 Final filtered count: ${filtered.length}');

    setState(() {
      _filteredCatering = filtered;
    });
  }

  void _loadCatering(String city) {
    setState(() {
      _selectedCity = city;
      _cacheKey = city;
      _isDataLoaded = false;
      _isApiSearch = false;
      _isLocationSearch = false;
      _userSelectedCity = true;
      _filteredCatering = []; // 🔥 Clear filtered list
      _cateringFuture = _fetchAndCacheCatering(city);
      _searchController.clear();
      _selectedStatus = 'All'; // 🔥 Reset status filter
    });
  }

  Future<void> _onRefresh() async {
    // Use new API method - backend handles caching
    final freshData = await _cateringService.fetchCaterings();
    setState(() {
      _cateringCache[_cacheKey] = freshData;
      _isDataLoaded = true;
      _applyAllFilters(_cacheKey);
      _cateringFuture = Future.value(freshData);
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    // If search is empty, just filter locally
    if (query.isEmpty) {
      _isApiSearch = false;
      _isLocationSearch = false;
      if (_isDataLoaded && _cateringCache.containsKey(_cacheKey)) {
        _applyAllFilters(_cacheKey);
      }
      return;
    }

    // If search has 3+ characters, use API search
    if (query.length >= 3) {
      _performApiSearch(query);
    } else {
      _isApiSearch = false;
      // For short queries, filter locally
      if (_isDataLoaded && _cateringCache.containsKey(_cacheKey)) {
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
      final results = await _cateringService.searchCatering(
        keyword: keyword,
        city: useLocation ? null : _selectedCity,
        lat: useLocation ? _userLat : null,
        lng: useLocation ? _userLng : null,
      );

      setState(() {
        _cateringCache[_cacheKey] = results;
        _isDataLoaded = true;
        _cateringFuture = Future.value(results);
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
    Navigator.pop(context);
  }

  // ✅ Show filter modal
  void _showFilterModal() {
    if (!_isDataLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for catering companies to load'),
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
                'Filter Catering',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Status filter buttons
              CateringStatusFilter(
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
        title: "Catering",
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
                    _loadCatering(city);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Selected $city')));
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
                    hintText: 'Search Catering Companies',
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
          
          // Catering list
          Expanded(
            child: FutureBuilder<List<Catering>>(
              future: _cateringFuture,
              builder: (context, snapshot) {
                // 🔥 Show loading only if data isn't cached
                if (snapshot.connectionState == ConnectionState.waiting) {
                  if (_isDataLoaded && _filteredCatering.isNotEmpty) {
                    // Show cached data while refreshing
                    return _buildListView(_filteredCatering);
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

                // 🔥 Show filtered catering (not snapshot.data)
                if (_isDataLoaded) {
                  if (_filteredCatering.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isNotEmpty
                                ? 'No catering companies found matching "${_searchController.text}"'
                                : 'No catering companies found',
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
                  return _buildListView(_filteredCatering);
                }

                return const Center(
                  child: Text('No catering companies found.'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Catering> cateringList) {
    return RefreshIndicator(
      color: Colors.teal,
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cateringList.length,
        itemBuilder: (context, index) {
          final c = cateringList[index];
          return GlobalStoreFront(
            imageUrl: c.photoReferences.isNotEmpty
                ? c.photoReferences.first
                : '',
            storeName: c.name,
            category: "Catering",
            location: c.address,
            rating: c.rating,
            onTap: () {
              Nav.push(GlobalStoreDetails(catering: c));
            },
          );
        },
      ),
    );
  }
}

// ✅ Catering Status Filter Component
class CateringStatusFilter extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;

  const CateringStatusFilter({
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
