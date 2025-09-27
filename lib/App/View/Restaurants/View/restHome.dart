import 'package:dspora/App/View/Restaurants/Widgets/storeDetail.dart';
import 'package:dspora/App/View/Restaurants/Widgets/storefront.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureHeader.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureSearch.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RestaurantHome extends ConsumerStatefulWidget {
  const RestaurantHome({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RestaurantHomeState();
}

class _RestaurantHomeState extends ConsumerState<RestaurantHome> {

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FeatureHeader(
        title: "Restaurants",
        location: "Houston TX",
        onBack: () {
          Navigator.pop(context);
        },
        onLocationTap: () {
          print("Location dropdown tapped");
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 20),
              child: Column(
                children: [
                  FeatureSearch(
                    controller: searchController,
                    hintText: 'Search Deespora',
                    onChanged: (value) {
                      print('Search text: $value');
                    },
                    onFilterTap: () {
                      print('Filter tapped');
                    },
                  ),

                  SizedBox(height: 30,),

//                   StoreFront(
//   imageUrl: Images.Davido,
//   storeName: "Mama K’s Kitchen",
//   category: "Restaurant",
//   location: "Bed-Stuy, Brooklyn, NY",
//   rating: 4.5,
//   onTap: () {
//     print("Store tapped!");
  
//   },
// ),

RestaurantDetailWidget(
      storeName: "Mama K'S Kitchen",
      rating: "4.9",
      ratingsCount: "72 ratings",
      location: "Bed-Stuy, Brooklyn, NY",
      status: "Open now",
      description: "Integer id augue iaculis, iaculis orci ut, blandit quam. Donec in elit auctor, finibus quam in, phar. Proin id ligula dictum, covalis enim ut, facilisis massa.",
      imageUrls: [
        Images.Davido,
        Images.Tiwa,
        Images.BurnaBoy
        // Add more image URLs as needed
      ],
      onReviewPressed: () {
        // Handle review action
      },
      onSavePressed: () {
        // Handle save action
      },
      onSharePressed: () {
        // Handle share action
      },
      onUberEatsPressed: () {
        // Handle Uber Eats action
      },
      onGrubhubPressed: () {
        // Handle Grubhub action
      },
      onDoorDashPressed: () {
        // Handle DoorDash action
      },
      onOpenInMapsPressed: () {
        // Handle open in maps action
      },
    )

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
