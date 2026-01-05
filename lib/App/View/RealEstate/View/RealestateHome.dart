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



class RealEstateHome extends StatefulWidget {
  const RealEstateHome({super.key});

  @override
  State<RealEstateHome> createState() => _RealEstateHomeState();
}

class _RealEstateHomeState extends State<RealEstateHome> {
  final RealEstateService _realEstateService = RealEstateService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCity = 'US';
  String _cacheKey = 'US'; // Track which cache key has the data
  final Map<String, List<RealEstateModel>> _realEstateCache = {};
  List<RealEstateModel> _displayedRealEstate = []; // ✅ What actually shows

  String _selectedStatus = 'All';
  bool _isLoading = false;
  String? _errorMessage;

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
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ Step 1: Load initial data
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load US data first
      debugPrint('🔄 Loading US data...');
      final usData = await _realEstateService.fetchRealEstate(city: 'US');
      
      debugPrint('✅ Loaded ${usData.length} US listings');

      _realEstateCache['US'] = usData;

      setState(() {
        _cacheKey = 'US';
        _isLoading = false;
      });

      // Apply filters immediately with US data
      _applyFilters();

      // Try to get user location (non-blocking)
      _detectAndLoadUserLocation();
      
    } catch (e) {
      debugPrint('❌ Error loading initial data: $e');
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  

  // ✅ Step 2: Detect user location and load that city's data
  Future<void> _detectAndLoadUserLocation() async {
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
        debugPrint("📍 Detected city: $detectedCity");
        
        if (detectedCity != 'US' && detectedCity != _selectedCity) {
          // Load the detected city's data
          await _loadCityData(detectedCity);
        }
      }
    } catch (e) {
      debugPrint("❌ Location error: $e");
    }
  }

  // ✅ Step 3: Load data for a specific city
  Future<void> _loadCityData(String city) async {
    debugPrint('🔄 Loading data for: $city');

    setState(() {
      _selectedCity = city;
      _cacheKey = city;
      _isLoading = true;
    });

    try {
      // Check cache first
      if (!_realEstateCache.containsKey(city)) {
        final data = await _realEstateService.fetchRealEstate(city: city);
        debugPrint('✅ Loaded ${data.length} listings for $city');
        _realEstateCache[city] = data;
      } else {
        debugPrint('📦 Using cached data for $city');
      }

      _applyFilters();

    } catch (e) {
      debugPrint('❌ Error loading $city: $e');
      setState(() {
        _errorMessage = 'Failed to load $city data';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ Step 4: Apply all filters (search + status + city)
  void _applyFilters() {
    debugPrint('🔍 Applying filters...');
    debugPrint('   City: $_selectedCity');
    debugPrint('   Cache Key: $_cacheKey');
    debugPrint('   Status: $_selectedStatus');
    debugPrint('   Search: "${_searchController.text}"');

    // Get data for current cache key
    List<RealEstateModel> data = _realEstateCache[_cacheKey] ?? [];
    debugPrint('   Raw data count: ${data.length}');

    if (data.isEmpty) {
      setState(() {
        _displayedRealEstate = [];
      });
      return;
    }

    // Start with all data
    List<RealEstateModel> filtered = List.from(data);

    // Filter 1: City-specific filter (only if not 'US')
    if (_selectedCity != 'US') {
      filtered = filtered.where((r) {
        final cityMatch = r.address.toLowerCase().contains(_selectedCity.toLowerCase()) ||
                         r.name.toLowerCase().contains(_selectedCity.toLowerCase());
        return cityMatch;
      }).toList();
      debugPrint('   After city filter: ${filtered.length}');
    }

    // Filter 2: Search query
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((r) {
        final nameMatch = r.name.toLowerCase().contains(query);
        final addressMatch = r.address.toLowerCase().contains(query);
        return nameMatch || addressMatch;
      }).toList();
      debugPrint('   After search filter: ${filtered.length}');
    }

    // Filter 3: Status (Open/Closed)
    if (_selectedStatus == 'Open') {
      filtered = filtered.where((r) => r.openNow == true).toList();
      debugPrint('   After status filter (Open): ${filtered.length}');
    } else if (_selectedStatus == 'Closed') {
      filtered = filtered.where((r) => r.openNow == false).toList();
      debugPrint('   After status filter (Closed): ${filtered.length}');
    }

    debugPrint('✅ Final filtered count: ${filtered.length}');

    setState(() {
      _displayedRealEstate = filtered;
    });
  }

  // ✅ Called when search text changes
  void _onSearchChanged() {
    debugPrint('🔍 Search changed: "${_searchController.text}"');
    _applyFilters();
  }

  // ✅ Called when user selects a new city
  void _onCitySelected(String city) {
    debugPrint('🏙️ City selected: $city');
    _searchController.clear(); // Clear search when changing cities
    _loadCityData(city);
  }

  // ✅ Called when user changes status filter
  void _onStatusChanged(String status) {
    debugPrint('🔘 Status changed: $status');
    setState(() {
      _selectedStatus = status;
    });
    _applyFilters();
    Navigator.pop(context);
  }

  // ✅ Pull to refresh
  Future<void> _onRefresh() async {
    debugPrint('🔄 Refreshing data for $_cacheKey');
    try {
      final freshData = await _realEstateService.fetchRealEstate(city: _cacheKey);
      _realEstateCache[_cacheKey] = freshData;
      _applyFilters();
      debugPrint('✅ Refresh complete');
    } catch (e) {
      debugPrint('❌ Refresh error: $e');
    }
  }

  // ✅ Show filter modal
  void _showFilterModal() {
    if (_isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for listings to load'),
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
              const Text(
                'Filter Worship',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
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
                    _onCitySelected(city);
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
          
          // Content area
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Show loading on initial load
    if (_isLoading && _displayedRealEstate.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.teal),
      );
    }

    // Show error if exists and no data
    if (_errorMessage != null && _displayedRealEstate.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInitialData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show empty state
    if (_displayedRealEstate.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No results for "${_searchController.text}"'
                  : 'No worship listings found',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Show list
    return RefreshIndicator(
      color: Colors.teal,
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _displayedRealEstate.length,
        itemBuilder: (context, index) {
          final r = _displayedRealEstate[index];
          return GlobalStoreFront(
            imageUrl: r.photoReferences.isNotEmpty 
                ? r.photoReferences.first 
                : '',
            storeName: r.name,
            category: "Worship",
            location: r.address,
            rating: r.rating,
            onTap: () {
              Nav.push(RealestateStoreDetails(realestate: r));
            },
          );
        },
      ),
    );
  }
}

// ✅ Status Filter Widget
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