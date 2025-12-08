import 'package:dspora/App/View/Events/Views/eventDetails.dart';
import 'package:dspora/App/View/Interests/Api/placeService.dart';
import 'package:dspora/App/View/Interests/Model/historymodel.dart';
import 'package:dspora/App/View/Interests/Model/placemodel.dart';
import 'package:dspora/App/View/Interests/Widgets/UScities.dart';
import 'package:dspora/App/View/Interests/Widgets/artistCard.dart';
import 'package:dspora/App/View/RealEstate/Widget/realEstate.dart';
import 'package:dspora/App/View/Restaurants/View/Details.dart';
import 'package:dspora/App/View/Utils/tabBar.dart';
import 'package:dspora/App/View/Widgets/GLOBAL/FrontDetails.dart';
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

  // ✅ Navigate to saved place - Updated to include Event handling
  void _navigateToSavedPlace(Place place) {
    if (place.type == 'Restaurant') {
      final restaurant = place.toRestaurant();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
        ),
      );
    } else if (place.type == 'RealEstate') {
      final realEstate = place.toRealEstate();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RealestateStoreDetails(realestate: realEstate),
        ),
      );
    } else if (place.type == 'Catering') {
      final catering = place.toCatering();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GlobalStoreDetails(catering: catering),
        ),
      );
    } else if (place.type == 'Event') {
      // ✅ NEW: Handle Event navigation
      final event = place.toEvent();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EventDetailScreen(event: event),
        ),
      );
    }
  }

  // ✅ Navigate to history item
  void _navigateToHistoryItem(HistoryItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Save "${item.title}" to view full details'),
        duration: const Duration(seconds: 2),
      ),
    );
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
              // Navigate to event if URL exists
              if (artist.eventUrl!.isNotEmpty) {
                // You would fetch and navigate to the event here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening ${artist.name}...')),
                );
              }
              debugPrint('Tapped on ${artist.name}');
            },
            onRemove: () => _removeArtist(artist.name),
          );
        },
      );
    } else if (_selectedIndex == 1) {
      // Saved Tab - Show Places (including Events)
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
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 10),
        itemCount: savedPlaces.length,
        itemBuilder: (context, index) {
          final place = savedPlaces[index];

          // ✅ UPDATED: Show event date for events
          String category = '';
          if (place.type == 'Event' && place.eventDate != null && place.eventDate!.isNotEmpty) {
            category = '📅 ${place.eventDate}';
          }

          return GlobalStoreFront(
            imageUrl: place.imageUrl ?? Images.Store,
            storeName: place.name,
            category: category,
            location: place.address,
            rating: place.rating ?? 0.0,
            onTap: () {
              _navigateToSavedPlace(place);
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
                color: Colors.grey.shade300,
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
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  CustomText(text: item.title, fontSize: 15),
                  const SizedBox(height: 2),
                  CustomText(
                    text: _formatTimestamp(item.timestamp),
                    fontSize: 12,
                  ),
                ],
              ),
              onTap: () {
                _navigateToHistoryItem(item);
              },
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
      case 'catering':
        return Colors.teal;
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
      case 'catering':
        return Icons.restaurant_menu;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: CustomText(text: "Interests", fontSize: 18, title: true),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
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