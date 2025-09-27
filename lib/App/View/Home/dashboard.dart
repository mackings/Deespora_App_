import 'package:dspora/App/View/Widgets/HomeWidgets/carouselHome.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/categoryGrid.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/header.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/homeSearch.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {


  final List<CategoryItem> categories = [

    CategoryItem(
      title: 'Restaurants',
      svgAsset: 'assets/icons/restaurant.svg',
      backgroundColor: const Color(0xFFF1CD59),
      onTap: () {
        print('Restaurants tapped');
      },
    ),
    CategoryItem(
      title: 'Catering',
      svgAsset: 'assets/icons/catering.svg',
      backgroundColor: const Color(0xFF32871F),
      onTap: () {
        print('Catering tapped');
      },
    ),
    CategoryItem(
      title: 'Events',
      svgAsset: 'assets/icons/events.svg',
      backgroundColor: const Color(0xFFDA763F),
      onTap: () {
        print('Events tapped');
      },
    ),
    CategoryItem(
      title: 'Real Estate',
      svgAsset: 'assets/icons/real_estate.svg',
      backgroundColor: const Color(0xFFB287EE),
      onTap: () {
        print('Real Estate tapped');
      },
    ),
  ];

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 30),
            child: Column(
              children: [
                HomeHeader(name: "Mac Kingsley", location: "Lagos Nigeria"),
                SizedBox(height: 10,),
                HomeSearch(
  controller: searchController,
  hintText: 'Search Deespora',
  onChanged: (value) {
    print('User typing: $value');
  },
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter something to search';
    }
    return null;
  },
),

SizedBox(height: 10,),

HomeCarousel(
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

SizedBox(height: 20,),

Align(
  alignment: AlignmentGeometry.centerLeft,
  child: CustomText(text: "Categories",title: true,fontSize: 18,)),

  CategoryGrid(items: categories),



              ],
            ),
          ),
        ),
      )),
    );
  }
}