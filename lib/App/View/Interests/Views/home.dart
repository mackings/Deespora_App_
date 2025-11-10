import 'package:dspora/App/View/Interests/Widgets/UScities.dart';
import 'package:dspora/App/View/Restaurants/Api/ResService.dart';
import 'package:dspora/App/View/Restaurants/Model/ResModel.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureHeader.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';



class InterestHome extends StatefulWidget {
  const InterestHome({super.key});

  @override
  State<InterestHome> createState() => _InterestHomeState();
}

class _InterestHomeState extends State<InterestHome> {
 
  final TextEditingController _searchController = TextEditingController();

  String _selectedCity = 'US';
  

  
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
      }
    } catch (e) {
      debugPrint("❌ Error getting location: $e");
    }
  }




  void _loadRestaurants(String city) {
    setState(() {
      _selectedCity = city;
      _searchController.clear();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FeatureHeader(
        title: "Interests",
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

         ],
      ),
    );
  }
}