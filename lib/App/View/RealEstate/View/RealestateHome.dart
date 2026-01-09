import 'package:dspora/App/View/RealEstate/Api/realestateService.dart';
import 'package:dspora/App/View/RealEstate/Model/realestateModel.dart';
import 'package:dspora/App/View/RealEstate/Widget/realEstate.dart';
import 'package:dspora/App/View/RealEstate/Widget/statusFilter.dart';
import 'package:dspora/App/View/Utils/navigator.dart';
import 'package:dspora/App/View/Widgets/GLOBAL/FrontDetails.dart';
import 'package:dspora/App/View/Widgets/GLOBAL/SFront.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureHeader.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureSearch.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/LocPicker.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RealEstateHome extends StatefulWidget {
  const RealEstateHome({super.key});

  @override
  State<RealEstateHome> createState() => _RealEstateHomeState();
}

class _RealEstateHomeState extends State<RealEstateHome> {
  final WorshipService _worshipService = WorshipService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCity = 'US';
  String _cacheKey = 'US'; // Track which cache key has the data
  final Map<String, List<WorshipModel>> _worshipCache = {};
  List<WorshipModel> _filteredWorship = [];
  List<WorshipModel> _originalData = []; // Store original full data

  late Future<List<WorshipModel>> _worshipFuture;

  String _selectedStatus = 'All';
  bool _isDataLoaded = false;
  bool _userHasSelectedCity = false; // Track if user manually selected a city
  bool _isApiSearchActive = false; // Track if we're showing API search results

  final List<String> usCities = [
    "New York", "Los Angeles", "Chicago", "Houston", "Miami",
    "San Francisco", "Boston", "Washington", "Seattle", "Atlanta",
    "Las Vegas", "Orlando", "Dallas", "Denver", "Philadelphia",
    "Phoenix", "San Diego", "Austin", "Nashville", "Portland",
    "Detroit", "Minneapolis", "Charlotte", "Indianapolis", "Columbus",
    "San Antonio", "Tampa", "Baltimore", "Cleveland", "Kansas City",
  ];

  @override
  void initState() {
    super.initState();
    _worshipFuture = _fetchAndCacheWorship('US');
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

      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (placemarks.isNotEmpty) {
        final detectedCity = placemarks.first.locality ?? 'US';
        debugPrint("📍 User city detected: $detectedCity");
        setState(() {
          _selectedCity = detectedCity;
        });

        // Apply filters using the cache key (which is 'US')
        if (_worshipCache.containsKey(_cacheKey)) {
          _applyAllFilters(_cacheKey);
        }
      }
    } catch (e) {
      debugPrint("❌ Error getting location: $e");
    }
  }

  Future<List<WorshipModel>> _fetchAndCacheWorship(String city) async {
    if (_worshipCache.containsKey(city)) {
      setState(() {
        _isDataLoaded = true;
        _cacheKey = city;
      });
      _applyAllFilters(city);
      return _worshipCache[city]!;
    }

    // Use API method - backend handles caching
    final result = await _worshipService.fetchWorship();
    _worshipCache[city] = result;
    _originalData = result; // Store original full data
    setState(() {
      _isDataLoaded = true;
      _cacheKey = city;
    });
    _applyAllFilters(city);
    return result;
  }

  // Apply all filters (city, search, status)
  void _applyAllFilters(String city) {
    if (!_isDataLoaded || !_worshipCache.containsKey(city)) {
      debugPrint('⚠️ Cannot apply filters - data not loaded yet');
      return;
    }

    final allWorship = _worshipCache[city] ?? [];

    debugPrint('🔍 Applying filters to ${allWorship.length} worship places');
    debugPrint('   City: $city');
    debugPrint('   Search query: "${_searchController.text}"');
    debugPrint('   Status filter: $_selectedStatus');

    List<WorshipModel> filtered = allWorship;

    // Step 1: Apply city filter (only if city is not 'US')
    if (city != 'US') {
      filtered = filtered
          .where((w) =>
              w.address.toLowerCase().contains(city.toLowerCase()) ||
              w.name.toLowerCase().contains(city.toLowerCase()))
          .toList();

      // If no results, show all
      if (filtered.isEmpty) {
        debugPrint('   ⚠️ No city matches, showing all');
        filtered = allWorship;
      } else {
        debugPrint('   ✅ After city filter: ${filtered.length} worship places');
      }
    }

    // Step 2: Apply search query
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((w) =>
              w.name.toLowerCase().contains(query) ||
              w.address.toLowerCase().contains(query))
          .toList();
      debugPrint('   ✅ After search filter: ${filtered.length} worship places');
    }

    // Step 3: Apply status filter (Open/Closed)
    if (_selectedStatus == 'Open') {
      filtered = filtered.where((w) => w.openNow == true).toList();
      debugPrint('   ✅ After status filter (Open): ${filtered.length} worship places');
    } else if (_selectedStatus == 'Closed') {
      filtered = filtered.where((w) => w.openNow == false).toList();
      debugPrint('   ✅ After status filter (Closed): ${filtered.length} worship places');
    }

    debugPrint('   🎯 Final filtered count: ${filtered.length}');

    setState(() {
      _filteredWorship = filtered;
    });
  }

  void _loadWorship(String city) {
    setState(() {
      _selectedCity = city;
      _cacheKey = city;
      _isDataLoaded = false;
      _filteredWorship = []; // Clear filtered list
      _worshipFuture = _fetchAndCacheWorship(city);
      _searchController.clear();
      _selectedStatus = 'All'; // Reset status filter
      _userHasSelectedCity = true; // Mark that user manually selected a city
      _isApiSearchActive = false; // Reset API search mode
    });
  }

  Future<void> _onRefresh() async {
    // Use API method - backend handles caching
    final freshData = await _worshipService.fetchWorship();
    setState(() {
      _worshipCache[_cacheKey] = freshData;
      _isDataLoaded = true;
      _applyAllFilters(_cacheKey);
      _worshipFuture = Future.value(freshData);
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    // If search is empty, restore original data
    if (query.isEmpty) {
      setState(() {
        _isApiSearchActive = false;
      });
      // Restore original full data to cache
      if (_originalData.isNotEmpty) {
        _worshipCache[_cacheKey] = _originalData;
      }
      // Apply filters on original data
      if (_isDataLoaded && _worshipCache.containsKey(_cacheKey)) {
        _applyAllFilters(_cacheKey);
      }
      return;
    }

    // If search has 3+ characters, use API search
    if (query.length >= 3) {
      _performApiSearch(query);
    } else {
      // For short queries, filter locally on original data
      setState(() {
        _isApiSearchActive = false;
      });
      // Make sure we're filtering original data
      if (_originalData.isNotEmpty) {
        _worshipCache[_cacheKey] = _originalData;
      }
      if (_isDataLoaded && _worshipCache.containsKey(_cacheKey)) {
        _applyAllFilters(_cacheKey);
      }
    }
  }

  // New method to search via API
  Future<void> _performApiSearch(String keyword) async {
    setState(() {
      _isDataLoaded = false;
      _userHasSelectedCity = true; // User is actively searching
      _isApiSearchActive = true; // Mark as API search mode
    });

    try {
      debugPrint('🔍 Searching via API: $keyword in $_selectedCity');
      final results = await _worshipService.searchWorship(
        city: _selectedCity,
        keyword: keyword,
      );

      setState(() {
        _worshipCache[_cacheKey] = results;
        _isDataLoaded = true;
        _worshipFuture = Future.value(results);
      });

      // Don't apply local filters - API already filtered
      // Just apply status filter only
      _applyStatusFilterOnly();
    } catch (e) {
      debugPrint('❌ Search error: $e');
      setState(() {
        _isDataLoaded = true;
        _isApiSearchActive = false;
      });
    }
  }

  // Apply only status filter (used after API search)
  void _applyStatusFilterOnly() {
    if (!_isDataLoaded || !_worshipCache.containsKey(_cacheKey)) {
      return;
    }

    final allWorship = _worshipCache[_cacheKey] ?? [];
    List<WorshipModel> filtered = allWorship;

    // Only apply status filter - don't filter by search or city
    if (_selectedStatus == 'Open') {
      filtered = filtered.where((w) => w.openNow == true).toList();
    } else if (_selectedStatus == 'Closed') {
      filtered = filtered.where((w) => w.openNow == false).toList();
    }

    debugPrint('✅ Applied status-only filter: ${filtered.length} worship places');

    setState(() {
      _filteredWorship = filtered;
    });
  }

  void _onStatusChanged(String status) {
    setState(() {
      _selectedStatus = status;
    });

    // If API search is active, only apply status filter
    // Otherwise apply all filters (including local search)
    if (_isApiSearchActive) {
      _applyStatusFilterOnly();
    } else {
      _applyAllFilters(_cacheKey);
    }

    Navigator.pop(context);
  }

  // Show filter modal
  void _showFilterModal() {
    if (!_isDataLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for worship places to load'),
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
                'Filter Worship',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 24),

              // Status filter buttons
              RealEstateStatusFilter(
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
        title: "Worship",
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
                    _loadWorship(city);
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
                    hintText: 'Search Worship',
                    onChanged: (value) => _onSearchChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                // Filter button
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

          // Worship list
          Expanded(
            child: FutureBuilder<List<WorshipModel>>(
              future: _worshipFuture,
              builder: (context, snapshot) {
                // Show loading only if data isn't cached
                if (snapshot.connectionState == ConnectionState.waiting) {
                  if (_isDataLoaded && _filteredWorship.isNotEmpty) {
                    // Show cached data while refreshing
                    return _buildListView(_filteredWorship);
                  }
                  return _buildSkeletonLoader();
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

                // Show filtered worship (not snapshot.data)
                if (_isDataLoaded) {
                  if (_filteredWorship.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isNotEmpty
                                ? 'No worship places found matching "${_searchController.text}"'
                                : 'No worship places found',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          if (_searchController.text.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged();
                              },
                              child: const Text('Clear Search'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }
                  return _buildListView(_filteredWorship);
                }

                return const Center(child: Text('No worship places found.'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 20,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 150,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView(List<WorshipModel> worshipList) {
    return RefreshIndicator(
      color: Colors.teal,
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: worshipList.length,
        itemBuilder: (context, index) {
          final w = worshipList[index];
          return GlobalStoreFront(
            imageUrl: w.photoReferences.isNotEmpty
                ? w.photoReferences.first
                : '',
            storeName: w.name,
            category: "Worship",
            location: w.address,
            rating: w.rating,
            onTap: () {
              Nav.push(RealestateStoreDetails(realestate: w));
            },
          );
        },
      ),
    );
  }
}

// Status Filter Widget
class RealEstateStatusFilter extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;

  const RealEstateStatusFilter({
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
