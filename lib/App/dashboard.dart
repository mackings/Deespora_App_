import 'package:dspora/App/View/Events/Api/eventsApi.dart';
import 'package:dspora/App/View/Events/Model/eventModel.dart';
import 'package:dspora/App/View/Events/Views/eventDetails.dart';
import 'package:dspora/App/View/Events/Views/eventHome.dart';
import 'package:dspora/App/View/Restaurants/View/restHome.dart';
import 'package:dspora/App/View/Utils/navigator.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/carouselHome.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/categoryGrid.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/eventCarousel.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/header.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/homeSearch.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';



class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  final EventApiService _eventService = EventApiService();

  bool _loading = true;
  String? _userName;
  String _selectedCity = "";
  List<Event> _events = [];

  final TextEditingController searchController = TextEditingController();

  final List<CategoryItem> categories = [
    CategoryItem(
      title: 'Restaurants',
      svgAsset: 'assets/img/restaurant.png',
      backgroundColor: const Color(0xFFF1CD59),
      onTap: () => Nav.push(const RestaurantHome()),
    ),
    CategoryItem(
      title: 'Catering',
      svgAsset: 'assets/img/catering.png',
      backgroundColor: const Color(0xFF32871F),
      onTap: () {},
    ),
    CategoryItem(
      title: 'Events',
      svgAsset: 'assets/img/event.png',
      backgroundColor: const Color(0xFFDA763F),
      onTap: () => Nav.push(const EventHome()),
    ),
    CategoryItem(
      title: 'Real Estate',
      svgAsset: 'assets/img/realestate.png',
      backgroundColor: const Color(0xFFB287EE),
      onTap: () {},
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initDashboard();
  }

  Future<void> _initDashboard() async {
    setState(() => _loading = true);
    
    await _loadUserName();
    await _loadUserLocation();
    await _fetchEvents();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Guest';
    });
  }

  Future<void> _loadUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _selectedCity = "Unknown City");
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);

      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        setState(() {
          _selectedCity = placemarks.first.locality ?? "Your City";
        });
      } else {
        setState(() => _selectedCity = "Your City");
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      setState(() => _selectedCity = "Your City");
    }
  }

  Future<void> _fetchEvents() async {
    try {
      final events = await _eventService.fetchAllEvents(
        city: _selectedCity.isNotEmpty ? _selectedCity : null,
      );

      setState(() {
        _events = events;
        _loading = false; // Only set loading to false after all data is loaded
      });
    } catch (e) {
      debugPrint('Error fetching events: $e');
      setState(() {
        _events = []; // Set empty list on error
        _loading = false;
      });
    }
  }

  // Helper method to create skeleton placeholders
  List<CarouselItem> _buildSkeletonCarouselItems() {
    return List.generate(4, (index) => CarouselItem(
      imageUrl: '', // Empty URL for skeleton
      title: 'Loading Event ${index + 1}',
      date: '2024-01-01',
      onTap: () {},
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
              child: Column(
                children: [
                  /// ---------- Header ------------
                  HomeHeader(
                    name: _userName ?? '',
                    location: _selectedCity,
                    onLocationSelected: (city) {
                      setState(() {
                        _selectedCity = city;
                        _loading = true; // Show loading when changing location
                      });
                      _fetchEvents();
                    },
                  ),

                  const SizedBox(height: 10),

                  /// ---------- Search ------------
                  HomeSearch(
                    controller: searchController,
                    hintText: 'Search Deespora',
                    onChanged: (value) {},
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter search text' : null,
                  ),

                  const SizedBox(height: 20),

                  /// ---------- Top Carousel ------------
                  Skeletonizer(
                    enabled: _loading,
                    child: HomeCarousel(
                      items: _loading 
                          ? _buildSkeletonCarouselItems() // Show skeleton items while loading
                          : _events.isNotEmpty
                              ? _events.take(4).map((event) {
                                  return CarouselItem(
                                    imageUrl: event.images.isNotEmpty
                                        ? event.images.first.url
                                        : 'https://via.placeholder.com/400x200',
                                    title: event.name,
                                    date: event.dates.start.localDate,
                                    onTap: () => Nav.push(EventDetailScreen(event: event)),
                                  );
                                }).toList()
                              : [CarouselItem(
                                  imageUrl: 'https://via.placeholder.com/400x200',
                                  title: 'No events available',
                                  date: '',
                                  onTap: () {},
                                )],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ---------- Categories ------------
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CustomText(
                      text: "Categories",
                      title: true,
                      fontSize: 18,
                    ),
                  ),

                  CategoryGrid(items: categories),

                  const SizedBox(height: 20),

                  /// ---------- Events Near You ------------
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CustomText(
                      text: "Events Near You",
                      title: true,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Skeletonizer(
                    enabled: _loading,
                    child: EventCarousel(
                      imageUrls: _loading
                          ? List.generate(8, (index) => '') // Empty URLs for skeleton
                          : _events.length > 1
                              ? _events
                                  .skip(1)
                                  .take(8)
                                  .map((e) => e.images.isNotEmpty
                                      ? e.images.first.url
                                      : 'https://via.placeholder.com/400x200')
                                  .toList()
                              : ['https://via.placeholder.com/400x200'], // Default when no events
                      height: 100,
                      autoPlay: !_loading, // Don't autoplay while loading
                      onTap: _loading 
                          ? (index) {} // Empty callback while loading
                          : (index) {
                              if (_events.length > index + 1) {
                                final event = _events.skip(1).toList()[index];
                                Nav.push(EventDetailScreen(event: event));
                              }
                            },
                      loading: _loading,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}