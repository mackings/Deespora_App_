import 'package:dspora/App/Services/AppLocationService.dart';
import 'package:dspora/App/View/RealEstate/Api/realestateService.dart';
import 'package:dspora/App/View/RealEstate/Model/realestateModel.dart';
import 'package:dspora/App/View/RealEstate/Widget/realEstate.dart';
import 'package:dspora/App/View/Utils/navigator.dart';
import 'package:dspora/App/View/Widgets/GLOBAL/SFront.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureHeader.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureSearch.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/LocPicker.dart';
import 'package:dspora/Constants/USCities.dart';
import 'package:flutter/material.dart';

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
  List<WorshipModel> _lastSuccessfulApiSearchResults = [];
  String _lastSuccessfulApiSearchKeyword = '';

  late Future<List<WorshipModel>> _worshipFuture;

  String _selectedStatus = 'All';
  bool _isDataLoaded = false;
  bool _isApiSearchActive = false; // Track if we're showing API search results
  bool _isLocationSearch = false;
  bool _userSelectedCity = false;
  bool _isRefreshingImageData = false;
  String? _lastImageRefreshSignature;
  double? _userLat;
  double? _userLng;
  int _searchRequestId = 0;

  final List<String> usCities = USCities.list;

  bool get _hasActiveApiSearch =>
      _isApiSearchActive && _searchController.text.trim().length >= 3;

  List<WorshipModel> _filterApiSearchResults(
    List<WorshipModel> items,
    String keyword,
  ) {
    final normalizedQuery = keyword.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return items;
    }

    final queryTokens = normalizedQuery
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();

    bool matches(WorshipModel worship) {
      final haystack = '${worship.name} ${worship.address}'
          .toLowerCase()
          .trim();
      if (haystack.contains(normalizedQuery)) {
        return true;
      }
      return queryTokens.every(haystack.contains);
    }

    return items.where(matches).toList();
  }

  List<WorshipModel> _fallbackSearchResults(String keyword) {
    if (_lastSuccessfulApiSearchResults.isEmpty ||
        _lastSuccessfulApiSearchKeyword.isEmpty) {
      return const [];
    }

    final normalizedKeyword = keyword.trim().toLowerCase();
    final normalizedLastKeyword = _lastSuccessfulApiSearchKeyword
        .trim()
        .toLowerCase();

    if (!normalizedKeyword.startsWith(normalizedLastKeyword) &&
        !normalizedLastKeyword.startsWith(normalizedKeyword)) {
      return const [];
    }

    return _filterApiSearchResults(_lastSuccessfulApiSearchResults, keyword);
  }

  List<WorshipModel> _mergeSearchResults(
    List<WorshipModel> primary,
    List<WorshipModel> secondary,
  ) {
    final seen = <String>{};
    final merged = <WorshipModel>[];

    for (final worship in [...primary, ...secondary]) {
      final key =
          '${worship.id}|${worship.name.toLowerCase()}|${worship.address.toLowerCase()}';
      if (seen.add(key)) {
        merged.add(worship);
      }
    }

    return merged;
  }

  @override
  void initState() {
    super.initState();
    _worshipFuture = Future<List<WorshipModel>>.value(const []);
    _loadUserLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserLocation() async {
    try {
      final location = await AppLocationService.getActiveLocation();
      if (!mounted) {
        return;
      }

      debugPrint("📍 Using app location for worship: ${location.city}");
      _userSelectedCity = location.isUserSelected;
      _userLat = location.isUserSelected ? null : location.lat;
      _userLng = location.isUserSelected ? null : location.lng;
      final future = _fetchAndCacheWorship(location.city);

      setState(() {
        _selectedCity = location.city;
        _isDataLoaded = false;
        _isLocationSearch = !location.isUserSelected && location.hasCoordinates;
        _worshipFuture = future;
      });
    } catch (e) {
      debugPrint("❌ Error getting location: $e");
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedCity = 'US';
        _userSelectedCity = false;
        _worshipFuture = _fetchAndCacheWorship('US');
      });
    }
  }

  String _locationCacheKey(double lat, double lng) {
    return 'nearby_${lat.toStringAsFixed(5)}_${lng.toStringAsFixed(5)}';
  }

  Future<List<WorshipModel>> _fetchAndCacheWorship(String city) async {
    final useLocation =
        !_userSelectedCity && _userLat != null && _userLng != null;
    final cacheKey = useLocation
        ? _locationCacheKey(_userLat!, _userLng!)
        : city;

    if (_worshipCache.containsKey(cacheKey)) {
      setState(() {
        _isDataLoaded = true;
        _cacheKey = cacheKey;
        _isLocationSearch = useLocation;
      });
      _applyAllFilters(cacheKey);
      return _worshipCache[cacheKey]!;
    }

    // Use API method - backend handles caching
    final result = useLocation
        ? await _worshipService.fetchWorship(lat: _userLat, lng: _userLng)
        : await _worshipService.fetchWorship(city: city);
    _worshipCache[cacheKey] = result;
    _originalData = result; // Store original full data

    if (_hasActiveApiSearch) {
      return result;
    }

    setState(() {
      _isDataLoaded = true;
      _cacheKey = cacheKey;
      _isLocationSearch = useLocation;
    });
    _applyAllFilters(cacheKey);
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

    // Step 1: Apply city filter (only for city-based results)
    if (!_isLocationSearch && city != 'US') {
      filtered = filtered
          .where(
            (w) =>
                w.address.toLowerCase().contains(city.toLowerCase()) ||
                w.name.toLowerCase().contains(city.toLowerCase()),
          )
          .toList();

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
          .where(
            (w) =>
                w.name.toLowerCase().contains(query) ||
                w.address.toLowerCase().contains(query),
          )
          .toList();
      debugPrint('   ✅ After search filter: ${filtered.length} worship places');
    }

    // Step 3: Apply status filter (Open/Closed)
    if (_selectedStatus == 'Open') {
      filtered = filtered.where((w) => w.openNow == true).toList();
      debugPrint(
        '   ✅ After status filter (Open): ${filtered.length} worship places',
      );
    } else if (_selectedStatus == 'Closed') {
      filtered = filtered.where((w) => w.openNow == false).toList();
      debugPrint(
        '   ✅ After status filter (Closed): ${filtered.length} worship places',
      );
    }

    debugPrint('   🎯 Final filtered count: ${filtered.length}');

    setState(() {
      _filteredWorship = filtered;
    });
  }

  void _loadWorship(String city) {
    AppLocationService.saveUserSelectedCity(city);
    setState(() {
      _selectedCity = city;
      _cacheKey = city;
      _isDataLoaded = false;
      _filteredWorship = []; // Clear filtered list
      _userSelectedCity = true;
      _isApiSearchActive = false; // Reset API search mode
      _isLocationSearch = false;
      _worshipFuture = _fetchAndCacheWorship(city);
      _searchController.clear();
      _selectedStatus = 'All'; // Reset status filter
    });
  }

  Future<void> _onRefresh() async {
    // Use API method - backend handles caching
    final useLocation =
        !_userSelectedCity && _userLat != null && _userLng != null;
    final freshData = useLocation
        ? await _worshipService.fetchWorship(lat: _userLat, lng: _userLng)
        : await _worshipService.fetchWorship(city: _selectedCity);
    final nextCacheKey = useLocation
        ? _locationCacheKey(_userLat!, _userLng!)
        : _cacheKey;
    setState(() {
      _worshipCache[nextCacheKey] = freshData;
      _isDataLoaded = true;
      _cacheKey = nextCacheKey;
      _isLocationSearch = useLocation;
      _applyAllFilters(nextCacheKey);
      _worshipFuture = Future.value(freshData);
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    // If search is empty, restore original data
    if (query.isEmpty) {
      _searchRequestId++;
      setState(() {
        _isApiSearchActive = false;
        _isLocationSearch = false;
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
      final fallbackResults = _fallbackSearchResults(query);
      if (fallbackResults.isNotEmpty) {
        setState(() {
          _worshipCache[_cacheKey] = fallbackResults;
          _filteredWorship = fallbackResults;
          _isDataLoaded = true;
        });
      }
      _performApiSearch(query, ++_searchRequestId);
    } else {
      _searchRequestId++;
      // For short queries, filter locally on original data
      setState(() {
        _isApiSearchActive = false;
        _isLocationSearch = false;
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
  Future<void> _performApiSearch(String keyword, int requestId) async {
    setState(() {
      _isDataLoaded = false;
      _isApiSearchActive = true; // Mark as API search mode
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
      final results = await _worshipService.searchWorship(
        keyword: keyword,
        city: useLocation ? null : _selectedCity,
        lat: useLocation ? _userLat : null,
        lng: useLocation ? _userLng : null,
      );
      final filteredResults = _filterApiSearchResults(results, keyword);
      final fallbackResults = _fallbackSearchResults(keyword);
      final effectiveResults = _mergeSearchResults(
        filteredResults,
        fallbackResults,
      );

      if (!mounted ||
          requestId != _searchRequestId ||
          _searchController.text.trim() != keyword) {
        return;
      }

      setState(() {
        _worshipCache[_cacheKey] = effectiveResults;
        _isDataLoaded = true;
        _worshipFuture = Future.value(effectiveResults);
      });

      // Don't apply local filters - API already filtered
      // Just apply status filter only
      _applyStatusFilterOnly();

      if (effectiveResults.isNotEmpty) {
        _lastSuccessfulApiSearchResults = effectiveResults;
        _lastSuccessfulApiSearchKeyword = keyword;
      }
    } catch (e) {
      debugPrint('❌ Search error: $e');
      if (!mounted || requestId != _searchRequestId) {
        return;
      }
      setState(() {
        _isDataLoaded = true;
        _isApiSearchActive = false;
      });
    }
  }

  Future<void> _refreshImagesForCurrentView() async {
    final signature =
        '$_cacheKey|$_selectedCity|${_searchController.text.trim()}|$_isApiSearchActive|$_userSelectedCity|$_userLat|$_userLng';

    if (_isRefreshingImageData || _lastImageRefreshSignature == signature) {
      return;
    }

    _isRefreshingImageData = true;
    _lastImageRefreshSignature = signature;

    try {
      final query = _searchController.text.trim();
      final useLocation =
          !_userSelectedCity && _userLat != null && _userLng != null;

      final freshData = _isApiSearchActive && query.length >= 3
          ? await _worshipService.searchWorship(
              keyword: query,
              city: useLocation ? null : _selectedCity,
              lat: useLocation ? _userLat : null,
              lng: useLocation ? _userLng : null,
              forceRefresh: true,
            )
          : await _worshipService.fetchWorship(
              city: useLocation ? null : _selectedCity,
              lat: useLocation ? _userLat : null,
              lng: useLocation ? _userLng : null,
              forceRefresh: true,
            );

      if (!mounted) {
        return;
      }

      setState(() {
        _worshipCache[_cacheKey] = freshData;
        _originalData = freshData;
        _worshipFuture = Future.value(freshData);
        _isDataLoaded = true;
      });

      if (_isApiSearchActive) {
        _applyStatusFilterOnly();
      } else {
        _applyAllFilters(_cacheKey);
      }
    } catch (e) {
      debugPrint('❌ Failed to refresh worship images: $e');
    } finally {
      _isRefreshingImageData = false;
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

    debugPrint(
      '✅ Applied status-only filter: ${filtered.length} worship places',
    );

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
                  return Center(
                    child: CircularProgressIndicator(color: Colors.teal),
                  );
                  //return _buildSkeletonLoader();
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
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
                          const Icon(
                            Icons.search_off,
                            size: 48,
                            color: Colors.grey,
                          ),
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
            imageUrls: w.imageUrls,
            placeholderAsset: Images.worshipPlaceholderAsset,
            storeName: w.name,
            category: "Worship",
            location: w.address,
            rating: w.rating,
            onImageUnavailable: _refreshImagesForCurrentView,
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF37B6AF) : Colors.grey[100],
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
