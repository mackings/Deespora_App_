import 'package:dspora/App/View/Auth/View/Signin.dart';
import 'package:dspora/App/View/Auth/View/signup.dart';
import 'package:dspora/App/View/Catering/View/cateringHome.dart';
import 'package:dspora/App/View/Events/Api/AdsService.dart';
import 'package:dspora/App/View/Events/Api/eventsApi.dart';
import 'package:dspora/App/View/Events/Model/AdsModel.dart';
import 'package:dspora/App/View/Events/Model/eventModel.dart';
import 'package:dspora/App/View/Events/Views/eventDetails.dart';
import 'package:dspora/App/View/Events/Views/eventHome.dart';
import 'package:dspora/App/View/RealEstate/View/RealestateHome.dart';
import 'package:dspora/App/View/Restaurants/View/restHome.dart';
import 'package:dspora/App/View/Utils/navigator.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/GuestSignupAlert.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/carouselHome.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/categoryGrid.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/eventCarousel.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/header.dart';
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
  final AdvertApiService _advertService = AdvertApiService();

  bool _loading = false;
  bool _advertsLoading = false;
  String? _userName;
  String _selectedCity = "";
  List<Event> _events = [];
  List<Advert> _adverts = [];
  List<Advert> _promotedAdverts = [];
  bool _isGuest = false;

  final TextEditingController searchController = TextEditingController();

  late final List<CategoryItem> categories;

  @override
  void initState() {
    super.initState();
    _initCategories();
    _initDashboard();
  }

void _initCategories() {
  categories = [
    CategoryItem(
      title: 'Restaurants',
      svgAsset: 'assets/img/restaurant.png',
      backgroundColor: const Color(0xFFFFF4CC), // Soft yellow
      onTap: () => Nav.push(const RestaurantHome()), // Accessible to guests
    ),
    CategoryItem(
      title: 'Catering',
      svgAsset: 'assets/img/catering.png',
      backgroundColor: const Color(0xFF9BC4A0), // Sage green
      onTap: () => _handleCategoryTap('Catering', () => Nav.push(CateringHome())),
    ),
    CategoryItem(
      title: 'Events',
      svgAsset: 'assets/img/event.png',
      backgroundColor: const Color(0xFFE8B4A0), // Peachy beige
      onTap: () => Nav.push(const EventHome()), // Accessible to guests
    ),
    CategoryItem(
      title: 'Worship',
      svgAsset: 'assets/img/realestate.png',
      backgroundColor: const Color(0xFFD4C4F0), // Soft lavender
      onTap: () => _handleCategoryTap('Real Estate', () => Nav.push(RealEstateHome())),
    ),
  ];
}

  Future<void> _initDashboard() async {
    debugPrint('🔵 Init dashboard start');
    setState(() => _loading = true);

    await _loadUserName();
    debugPrint('✅ User loaded: $_userName');

    await _checkGuestStatus();
    debugPrint('✅ Guest status: $_isGuest');

    await _loadUserLocation();
    debugPrint('✅ Location loaded: $_selectedCity');

    // Fetch both events and adverts in parallel
    await Future.wait([
      _fetchEvents(),
      _fetchAdverts(),
    ]);
    
    debugPrint('✅ Events and Adverts fetched');
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Guest';
    });
  }

  Future<void> _checkGuestStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName');
    
    final isGuestUser = userName == null || userName.isEmpty || userName == 'Guest';
    
    if (isGuestUser) {
      await _clearAuthData();
      setState(() {
        _isGuest = true;
      });
    } else {
      setState(() {
        _isGuest = false;
      });
    }
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userEmail');
    await prefs.remove('emailVerified');
    await prefs.remove('phoneVerified');
    debugPrint('🧹 Cleared auth data for guest user');
  }

  void _handleCategoryTap(String categoryName, VoidCallback navigation) {
    if (_isGuest) {
      _showGuestSignupDialog();
    } else {
      navigation();
    }
  }

  void _showGuestSignupDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GuestSignupDialog(
          title: 'Want more personalized results?',
          onCreateAccount: () {
            Navigator.pop(context);
            Nav.push(SignUp());
          },
          onLogin: () {
            Navigator.pop(context);
            Nav.push(SignIn());
          },
          onClose: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _loadUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('⚠️ Location permission denied');
        setState(() => _selectedCity = "London");
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
        setState(() {
          _selectedCity = placemarks.first.locality ?? "New York";
        });
      } else {
        setState(() => _selectedCity = "New York");
      }
    } catch (e) {
      debugPrint("❌ Error getting location: $e");
      setState(() => _selectedCity = "New York");
    }
  }

  Future<void> _fetchEvents() async {
    debugPrint('🔵 Fetching events for city: $_selectedCity');
    try {
      final events = await _eventService.fetchAllEvents();

      debugPrint('✅ Got ${events.length} events');
      setState(() {
        _events = events;
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ Error fetching events: $e');
      setState(() {
        _events = [];
        _loading = false;
      });
    }
  }

  Future<void> _fetchAdverts() async {
    debugPrint('🔵 Fetching adverts');
    setState(() => _advertsLoading = true);
    
    try {
      final adverts = await _advertService.fetchAllAdverts(limit: 50);
      final promoted = adverts.where((ad) => ad.promoted).toList();

      debugPrint('✅ Got ${adverts.length} adverts (${promoted.length} promoted)');
      setState(() {
        _adverts = adverts;
        _promotedAdverts = promoted;
        _advertsLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error fetching adverts: $e');
      setState(() {
        _adverts = [];
        _promotedAdverts = [];
        _advertsLoading = false;
      });
    }
  }

  List<CarouselItem> _buildSkeletonCarouselItems() {
    return List.generate(
      4,
      (index) => CarouselItem(
        imageUrl: '',
        title: 'Loading Event ${index + 1}',
        date: '2024-01-01',
        onTap: () {},
      ),
    );
  }

  // Build carousel items combining events and promoted adverts
  List<CarouselItem> _buildMixedCarouselItems() {
    List<CarouselItem> items = [];
    
    // Add promoted adverts first (convert to Event for detail screen)
    for (var advert in _promotedAdverts.take(2)) {
      items.add(
        CarouselItem(
          imageUrl: advert.images.isNotEmpty
              ? advert.images.first
              : 'https://via.placeholder.com/400x200',
          title: advert.title,
          date: advert.eventDate.toString().split(' ')[0],
          // ✅ UPDATED: Added isFromAdvert parameter for adverts
          onTap: () {
            final event = advert.toEvent();
            Nav.push(
              EventDetailScreen(
                event: event,
                isFromAdvert: true, // Important: Triggers geocoding
              ),
            );
          },
        ),
      );
    }
    
    // Add events
    for (var event in _events.take(4 - items.length)) {
      items.add(
        CarouselItem(
          imageUrl: event.images.isNotEmpty
              ? event.images.first.url
              : 'https://via.placeholder.com/400x200',
          title: event.name,
          date: event.dates.start.localDate,
          // ✅ UPDATED: Added isFromAdvert parameter for events
          onTap: () {
            Nav.push(
              EventDetailScreen(
                event: event,
                isFromAdvert: false, // Regular event, has coordinates
              ),
            );
          },
        ),
      );
    }
    
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Container(
        color: const Color(0xFFFFFFFF),
        child: SafeArea(
          child: Container(
            color: const Color(0xFFFFFFFF),
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                  child: Column(
                    children: [
                      
                      HomeHeader(
                        name: _userName ?? '',
                        location: _selectedCity,
                        onLocationSelected: (city) {
                          setState(() {
                            _selectedCity = city;
                            _loading = true;
                          });
                          _fetchEvents();
                          _fetchAdverts();
                        },
                      ),

                      const SizedBox(height: 10),

                      const SizedBox(height: 20),

                      /// ---------- Top Carousel (Mixed Events & Promoted Adverts) ------------
                      Skeletonizer(
                        enabled: _loading || _advertsLoading,
                        child: HomeCarousel(
                          items: (_loading || _advertsLoading)
                              ? _buildSkeletonCarouselItems()
                              : _buildMixedCarouselItems().isNotEmpty
                                  ? _buildMixedCarouselItems()
                                  : [
                                      CarouselItem(
                                        imageUrl: 'https://via.placeholder.com/400x200',
                                        title: 'No events available',
                                        date: '',
                                        onTap: () {},
                                      ),
                                    ],
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

                       const SizedBox(height: 15),

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

                      // ✅ UPDATED: Events Near You carousel now properly identifies events
Skeletonizer(
  enabled: _loading,
  child: EventCarousel(
    imageUrls: _loading
        ? List.generate(8, (index) => '')
        : _events.length > 1
            ? _events
                .skip(1)
                .take(8)
                .map(
                  (e) => e.images.isNotEmpty
                      ? e.images.first.url
                      : 'https://via.placeholder.com/400x200',
                )
                .toList()
            : ['https://via.placeholder.com/400x200'],
    events: _loading ? null : _events.skip(1).take(8).toList(), // Pass events
    height: 100,
    autoPlay: !_loading,
    onTap: _loading
        ? (index) {}
        : (index) {
            if (_events.length > index + 1) {
              final event = _events.skip(1).toList()[index];
              Nav.push(
                EventDetailScreen(
                  event: event,
                  isFromAdvert: false,
                ),
              );
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
        ),
      ),
    );
  }
}