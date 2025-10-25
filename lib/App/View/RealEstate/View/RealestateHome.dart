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
        setState(() {
          _selectedCity = detectedCity;
        });
      }
    } catch (e) {
      debugPrint("❌ Error getting location: $e");
    }
  }

  Future<List<RealEstateModel>> _fetchAndCacheRealEstate(String city) async {
    if (_realEstateCache.containsKey(city)) {
      _applyCityFilter(city);
      return _realEstateCache[city]!;
    }

    final result = await _realEstateService.fetchRealEstate(city: city);
    _realEstateCache[city] = result;
    _applyCityFilter(city);
    return result;
  }

  void _applyCityFilter(String city) {
    final allRealEstates = _realEstateCache[city] ?? [];
    _filteredRealEstate = allRealEstates
        .where(
          (r) =>
              r.address.toLowerCase().contains(city.toLowerCase()) ||
              r.name.toLowerCase().contains(city.toLowerCase()),
        )
        .toList();

    if (_filteredRealEstate.isEmpty) {
      _filteredRealEstate = allRealEstates;
    }
  }

  void _loadRealEstate(String city) {
    setState(() {
      _selectedCity = city;
      _realEstateFuture = _fetchAndCacheRealEstate(city);
      _searchController.clear();
    });
  }

  Future<void> _onRefresh() async {
    final freshData = await _realEstateService.fetchRealEstate(city: _selectedCity);
    setState(() {
      _realEstateCache[_selectedCity] = freshData;
      _applyCityFilter(_selectedCity);
      _realEstateFuture = Future.value(freshData);
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (_realEstateCache.containsKey(_selectedCity)) {
      setState(() {
        _filteredRealEstate = _realEstateCache[_selectedCity]!
            .where(
              (r) =>
                  r.name.toLowerCase().contains(query) ||
                  r.address.toLowerCase().contains(query),
            )
            .toList();
      });
    }
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FeatureSearch(
              controller: _searchController,
              hintText: 'Search Real Estate Listings',
            ),
          ),
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


// class Realestatehome extends StatefulWidget {
//   const Realestatehome({super.key});

//   @override
//   State<Realestatehome> createState() => _RealestatehomeState();
// }

// class _CRealestatehomeState extends State<Realestatehome> {
//   final CateringService _cateringService = CateringService();
//   final TextEditingController _searchController = TextEditingController();

//   String _selectedCity = 'US';
//   final Map<String, List<Catering>> _cateringCache = {};
//   List<Catering> _filteredCatering = [];

//   late Future<List<Catering>> _cateringFuture;

//   final List<String> usCities = [
//     "New York",
//     "Los Angeles",
//     "Chicago",
//     "Houston",
//     "Miami",
//     "San Francisco",
//     "Boston",
//     "Washington",
//     "Seattle",
//     "Atlanta",
//     "Las Vegas",
//     "Orlando",
//     "Dallas",
//     "Denver",
//     "Philadelphia",
//     "Phoenix",
//     "San Diego",
//     "Austin",
//     "Nashville",
//     "Portland",
//     "Detroit",
//     "Minneapolis",
//     "Charlotte",
//     "Indianapolis",
//     "Columbus",
//     "San Antonio",
//     "Tampa",
//     "Baltimore",
//     "Cleveland",
//     "Kansas City",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _cateringFuture = _fetchAndCacheCatering('US');
//     _loadUserLocation();
//     _searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadUserLocation() async {
//     try {
//       LocationPermission permission = await Geolocator.requestPermission();

//       if (permission == LocationPermission.denied ||
//           permission == LocationPermission.deniedForever) {
//         debugPrint('⚠️ Location permission denied');
//         return;
//       }

//       final pos = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.medium,
//       ).timeout(const Duration(seconds: 10));

//       final placemarks = await placemarkFromCoordinates(
//         pos.latitude,
//         pos.longitude,
//       );

//       if (placemarks.isNotEmpty) {
//         final detectedCity = placemarks.first.locality ?? 'US';
//         debugPrint("📍 User city detected: $detectedCity");
//         setState(() {
//           _selectedCity = detectedCity;
//         });
//       }
//     } catch (e) {
//       debugPrint("❌ Error getting location: $e");
//     }
//   }

//   Future<List<Catering>> _fetchAndCacheCatering(String city) async {
//     if (_cateringCache.containsKey(city)) {
//       _applyCityFilter(city);
//       return _cateringCache[city]!;
//     }

//     final result = await _cateringService.fetchCaterings(city: city);
//     _cateringCache[city] = result;
//     _applyCityFilter(city);
//     return result;
//   }

//   void _applyCityFilter(String city) {
//     final allCatering = _cateringCache[city] ?? [];
//     _filteredCatering = allCatering
//         .where(
//           (r) =>
//               r.address.toLowerCase().contains(city.toLowerCase()) ||
//               r.name.toLowerCase().contains(city.toLowerCase()),
//         )
//         .toList();

//     if (_filteredCatering.isEmpty) {
//       _filteredCatering = allCatering;
//     }
//   }

//   void _loadCatering(String city) {
//     setState(() {
//       _selectedCity = city;
//       _cateringFuture = _fetchAndCacheCatering(city);
//       _searchController.clear();
//     });
//   }

//   Future<void> _onRefresh() async {
//     final freshData = await _cateringService.fetchCaterings(
//       city: _selectedCity,
//     );
//     setState(() {
//       _cateringCache[_selectedCity] = freshData;
//       _applyCityFilter(_selectedCity);
//       _cateringFuture = Future.value(freshData);
//     });
//   }

//   void _onSearchChanged() {
//     final query = _searchController.text.toLowerCase();
//     if (_cateringCache.containsKey(_selectedCity)) {
//       setState(() {
//         _filteredCatering = _cateringCache[_selectedCity]!
//             .where(
//               (r) =>
//                   r.name.toLowerCase().contains(query) ||
//                   r.address.toLowerCase().contains(query),
//             )
//             .toList();
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: FeatureHeader(
//         title: "Catering",
//         location: _selectedCity,
//         onBack: () => Navigator.pop(context),
//         onLocationTap: () {
//           showModalBottomSheet(
//             context: context,
//             isScrollControlled: true,
//             shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
//             ),
//             builder: (context) {
//               return SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.7,
//                 child: CitySelector(
//                   cities: usCities,
//                   onCitySelected: (city) {
//                     Navigator.pop(context);
//                     _loadCatering(city);
//                     ScaffoldMessenger.of(
//                       context,
//                     ).showSnackBar(SnackBar(content: Text('Selected $city')));
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: FeatureSearch(
//               controller: _searchController,
//               hintText: 'Search Catering Companies',
//             ),
//           ),
//           Expanded(
//             child: FutureBuilder<List<Catering>>(
//               future: _cateringFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   if (_cateringCache.containsKey(_selectedCity)) {
//                     return _buildListView(_filteredCatering);
//                   }
//                   return const Center(
//                     child: CircularProgressIndicator(color: Colors.teal),
//                   );
//                 }

//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }

//                 if (snapshot.hasData && snapshot.data!.isNotEmpty) {
//                   return _buildListView(_filteredCatering);
//                 }

//                 return const Center(
//                   child: Text('No catering companies found.'),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildListView(List<Catering> cateringList) {
//     return RefreshIndicator(
//       color: Colors.teal,
//       onRefresh: _onRefresh,
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: cateringList.length,
//         itemBuilder: (context, index) {
//           final c = cateringList[index];
//           return GlobalStoreFront(
//             imageUrl: c.photoReferences.isNotEmpty
//                 ? c.photoReferences.first
//                 : '',
//             storeName: c.name,
//             category: "Catering",
//             location: c.address,
//             rating: c.rating,
//             onTap: () {
//               Nav.push(GlobalStoreDetails(catering: c));
//             },
//           );
//         },
//       ),
//     );
//   }
// }
