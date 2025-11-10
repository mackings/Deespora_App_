import 'package:dspora/App/View/Interests/Widgets/UScities.dart';
import 'package:dspora/App/View/Interests/Widgets/artistCard.dart';
import 'package:dspora/App/View/Utils/tabBar.dart';
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
  int _selectedIndex = 0;
  
  // Add these for saved artists functionality
  List<Artist> savedArtists = [];
  bool isLoading = true;

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
    _loadSavedArtists();
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

  Future<void> _loadSavedArtists() async {
    setState(() => isLoading = true);
    final artists = await ArtistPreferencesService.getSavedArtists();
    setState(() {
      savedArtists = artists;
      isLoading = false;
    });
  }

  Future<void> _removeArtist(String artistName) async {
    final success = await ArtistPreferencesService.removeArtist(artistName);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$artistName removed')),
      );
      _loadSavedArtists();
    }
  }

  Widget _buildTabContent() {
    if (_selectedIndex == 1) {
      // Saved Artists Tab
      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (savedArtists.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bookmark_border, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No saved artists yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Save artists from events to see them here',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.only(top: 10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: savedArtists.length,
        itemBuilder: (context, index) {
          final artist = savedArtists[index];
          return ArtistCardWidget(
            artist: artist,
            onTap: () {
              // Navigate to artist detail or event
              debugPrint('Tapped on ${artist.name}');
              if (artist.eventUrl != null && artist.eventUrl!.isNotEmpty) {
                // You can navigate to event detail or open URL here
              }
            },
            onRemove: () => _removeArtist(artist.name),
          );
        },
      );
    }

    // Placeholder for other tabs
    return Center(
      child: Text(
        _selectedIndex == 0 ? 'Saved' : 'History',
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
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
      body: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Bar(
              tabs: ["Saved", "History"],
              selectedIndex: _selectedIndex,
              onTabSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }
}