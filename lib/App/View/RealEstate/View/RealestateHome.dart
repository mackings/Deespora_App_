import 'package:dspora/App/View/RealEstate/Api/realestateService.dart';
import 'package:dspora/App/View/RealEstate/Model/realestateModel.dart';
import 'package:dspora/App/View/RealEstate/Widget/realEstate.dart';
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
  final Map<String, List<RealEstateModel>> _realEstateCache = {};
  List<RealEstateModel> _filteredRealEstate = [];

  late Future<List<RealEstateModel>> _realEstateFuture;
  
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
    _realEstateFuture = _fetchAndCacheRealEstate('US');
    _loadUserLocation();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
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
        
        // ✅ FIX: Wait for initial data to load before applying filters
        if (_realEstateCache.containsKey('US') && _isDataLoaded) {
          setState(() {
            _selectedCity = detectedCity;
          });
          _applyAllFilters(detectedCity);
        } else {
          // Data not loaded yet, just set the city
          setState(() {
            _selectedCity = detectedCity;
          });
        }
      }
    } catch (e) {
      debugPrint("❌ Error getting location: $e");
    }
  }

  Future<List<RealEstateModel>> _fetchAndCacheRealEstate(String city) async {
    if (_realEstateCache.containsKey(city)) {
      setState(() {
        _isDataLoaded = true;
      });
      _applyAllFilters(city);
      return _realEstateCache[city]!;
    }

    final result = await _realEstateService.fetchRealEstate(city: city);
    
    setState(() {
      _realEstateCache[city] = result;
      _isDataLoaded = true;
    });
    
    // ✅ Apply filters after state is fully updated
    _applyAllFilters(city);
    
    return result;
  }

  // ✅ Apply all filters (city, search, status)
  void _applyAllFilters(String city) {
    if (!_isDataLoaded) return;

    final allRealEstates = _realEstateCache[city] ?? [];
    
    // Start with a copy of all data
    List<RealEstateModel> filtered = List.from(allRealEstates);

    // Step 1: Apply city filter - only if city is not 'US'
    if (city != 'US') {
      var cityFiltered = filtered
          .where((r) =>
              r.address.toLowerCase().contains(city.toLowerCase()) ||
              r.name.toLowerCase().contains(city.toLowerCase()))
          .toList();
      
      if (cityFiltered.isNotEmpty) {
        filtered = cityFiltered;
      }
    }

    // Step 2: Apply search query
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((r) =>
              r.name.toLowerCase().contains(query) ||
              r.address.toLowerCase().contains(query))
          .toList();
    }

    // Step 3: Apply status filter (Open/Closed)
    if (_selectedStatus == 'Open') {
      filtered = filtered.where((r) => r.openNow == true).toList();
    } else if (_selectedStatus == 'Closed') {
      filtered = filtered.where((r) => r.openNow == false).toList();
    }
    // If 'All', don't filter by status

    setState(() {
      _filteredRealEstate = filtered;
    });
    
    debugPrint('✅ Filtered ${filtered.length} real estate listings (City: $city, Status: $_selectedStatus)');
  }

  void _loadRealEstate(String city) {
    setState(() {
      _selectedCity = city;
      _isDataLoaded = false;
      _realEstateFuture = _fetchAndCacheRealEstate(city);
      _searchController.clear();
    });
  }

  Future<void> _onRefresh() async {
    final freshData = await _realEstateService.fetchRealEstate(city: _selectedCity);
    setState(() {
      _realEstateCache[_selectedCity] = freshData;
      _isDataLoaded = true;
    });
    _applyAllFilters(_selectedCity);
    setState(() {
      _realEstateFuture = Future.value(freshData);
    });
  }

  void _onSearchChanged() {
    if (_isDataLoaded && _realEstateCache.containsKey(_selectedCity)) {
      _applyAllFilters(_selectedCity);
    }
  }

  void _onStatusChanged(String status) {
    setState(() {
      _selectedStatus = status;
    });
    _applyAllFilters(_selectedCity);
    Navigator.pop(context);
  }

  // ✅ Show filter modal
  void _showFilterModal() {
    if (!_isDataLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for real estate listings to load'),
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
                'Filter Real Estate',
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
        title: "Real Estate",
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
                    _loadRealEstate(city);
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
                    hintText: 'Search Real Estate Listings',
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
          
          // Real Estate list
          Expanded(
            child: FutureBuilder<List<RealEstateModel>>(
              future: _realEstateFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  if (_realEstateCache.containsKey(_selectedCity)) {
                    return _buildListView(_filteredRealEstate);
                  }
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.teal),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return _buildListView(_filteredRealEstate);
                }

                return const Center(
                  child: Text('No real estate listings found.'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<RealEstateModel> realEstateList) {
    return RefreshIndicator(
      color: Colors.teal,
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: realEstateList.length,
        itemBuilder: (context, index) {
          final r = realEstateList[index];
          return GlobalStoreFront(
            imageUrl: r.photoReferences.isNotEmpty ? r.photoReferences.first : '',
            storeName: r.name,
            category: "Real Estate",
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



// ✅ Real Estate Status Filter Component
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