import 'package:dspora/App/View/Interests/Model/historymodel.dart';
import 'package:dspora/App/View/Interests/Model/placemodel.dart';
import 'package:dspora/App/View/Interests/Widgets/UScities.dart';
import 'package:dspora/App/View/Interests/Widgets/artistCard.dart';
import 'package:dspora/App/View/Utils/tabBar.dart';
import 'package:dspora/App/View/Widgets/GLOBAL/SFront.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureHeader.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
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
  
  // Add these for saved functionality
  List<Artist> savedArtists = [];
  List<Place> savedPlaces = [];
  List<HistoryItem> historyItems = [];
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
    _loadSavedData();
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

  Future<void> _loadSavedData() async {
    setState(() => isLoading = true);
    final artists = await ArtistPreferencesService.getSavedArtists();
    final places = await PlacePreferencesService.getSavedPlaces();
    final history = await HistoryService.getHistory();
    setState(() {
      savedArtists = artists;
      savedPlaces = places;
      historyItems = history;
      isLoading = false;
    });
  }

  Future<void> _removeArtist(String artistName) async {
    final success = await ArtistPreferencesService.removeArtist(artistName);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$artistName removed')),
      );
      _loadSavedData();
    }
  }

  Future<void> _removePlace(String placeName, String placeAddress) async {
    final success = await PlacePreferencesService.removePlace(placeName, placeAddress);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$placeName removed')),
      );
      _loadSavedData();
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildTabContent() {
    if (_selectedIndex == 0) {
      // Artists Tab - Show Artists
      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (savedArtists.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline, size: 64, color: Colors.grey.shade400),
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
              debugPrint('Tapped on ${artist.name}');
            },
            onRemove: () => _removeArtist(artist.name),
          );
        },
      );
    } else if (_selectedIndex == 1) {
      // Saved Tab - Show Places (Real Estate)
      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (savedPlaces.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bookmark_border, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No saved places yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
CustomText(text: "Save places on the app to preview here")
            ],
          ),
        );
      }

      return ListView.builder(
  padding: const EdgeInsets.only(top: 10),
  itemCount: savedPlaces.length,
  itemBuilder: (context, index) {
    final place = savedPlaces[index];

    return GlobalStoreFront(
      imageUrl: place.imageUrl ?? Images.Store,
      storeName: place.name,
      category:  '',
      location: place.address,
      rating: place.rating ?? 0.0,
      onTap: () {

      },
    );
  },
);

    } else if (_selectedIndex == 2) {
      // History Tab
      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (historyItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
 CustomText(text: "No saved history"),
              const SizedBox(height: 8),
CustomText(text: "Your history will appear here")
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 10),
        itemCount: historyItems.length,
        itemBuilder: (context, index) {
          final item = historyItems[index];
          return Container(
            padding: const EdgeInsets.all(10),
  margin: const EdgeInsets.symmetric(vertical: 6),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Colors.grey.shade300, // border color
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        blurRadius: 3,
        offset: const Offset(0, 2),
      ),
    ],
  ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getTypeColor(item.type),
                child: Icon(
                  _getTypeIcon(item.type),
                  color: Colors.white,
                  size: 20,
                ),
              ),
             // title: CustomText(text: item.type),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
            CustomText(text: item.title,fontSize: 15,),
                  const SizedBox(height: 2),
                 CustomText(text:  _formatTimestamp(item.timestamp),fontSize: 12,)
                  
                ],
              ),
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'realestate':
        return Colors.blue;
      case 'artist':
        return Colors.purple;
      case 'event':
        return Colors.orange;
      case 'restaurant':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'realestate':
        return Icons.home;
      case 'artist':
        return Icons.person;
      case 'event':
        return Icons.event;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FeatureHeader(
        title: "Interests",
        showBackButton: false,
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
              tabs: ["Artists", "Saved", "History"],
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