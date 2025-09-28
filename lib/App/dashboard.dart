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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';




class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {

  bool _loading = true;
  String? _userName;


  final List<CategoryItem> categories = [
    CategoryItem(
      title: 'Restaurants',
      svgAsset: 'assets/img/restaurant.png',
      backgroundColor: const Color(0xFFF1CD59),
      onTap: () {
        Nav.push(RestaurantHome());
      },
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
      onTap: () {
        Nav.push(EventHome());
      },
    ),

    CategoryItem(
      title: 'Real Estate',
      svgAsset: 'assets/img/realestate.png',
      backgroundColor: const Color(0xFFB287EE),
      onTap: () {},
    ),


  ];

  final List<String> eventImages = [
    'https://images.pexels.com/photos/196634/pexels-photo-196634.jpeg',
    'https://images.pexels.com/photos/167964/pexels-photo-167964.jpeg',
    'https://images.pexels.com/photos/196634/pexels-photo-196634.jpeg',
    'https://images.pexels.com/photos/3183197/pexels-photo-3183197.jpeg',
  ];

  final TextEditingController searchController = TextEditingController();

@override
void initState() {
  super.initState();

  // Load user name
  _loadUserName();

  // Simulate loading skeleton
  Future.delayed(const Duration(seconds: 2), () {
    setState(() {
      _loading = false;
    });
  });
}

Future<void> _loadUserName() async {
  final prefs = await SharedPreferences.getInstance();
  final savedName = prefs.getString('userName');
  setState(() {
    _userName = savedName ?? 'Guest';
  });
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
                  HomeHeader(
  name: _userName ?? '',
  location: "Lagos Nigeria",
),

                  const SizedBox(height: 10),

                  HomeSearch(
                    controller: searchController,
                    hintText: 'Search Deespora',
                    onChanged: (value) {},
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter search text' : null,
                  ),

                  const SizedBox(height: 10),

                  // ✅ Skeleton for Carousel
                  Skeletonizer(
                    enabled: _loading,
                    child: HomeCarousel(
                      items: [
                        CarouselItem(
                          imageUrl: Images.Davido,
                          title: 'Davido in TEXAS!',
                          date: '12/07/2025',
                        ),
                        CarouselItem(
                          imageUrl: Images.BurnaBoy,
                          title: 'Burna Boy World Tour',
                          date: '15/09/2025',
                        ),
                        CarouselItem(
                          imageUrl: Images.Tiwa,
                          title: 'Tiwa Savage Live',
                          date: '20/10/2025',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

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
                      imageUrls: eventImages,
                      height: 200,
                      autoPlay: true,
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