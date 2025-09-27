import 'package:dspora/App/View/Restaurants/Providers/resProvider.dart';
import 'package:dspora/App/View/Restaurants/View/Details.dart';
import 'package:dspora/App/View/Restaurants/Widgets/storeDetail.dart';
import 'package:dspora/App/View/Restaurants/Widgets/storefront.dart';
import 'package:dspora/App/View/Utils/navigator.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureHeader.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureSearch.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class RestaurantHome extends ConsumerWidget {
  const RestaurantHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantsAsync = ref.watch(restaurantsProvider);

    return Scaffold(
      appBar: FeatureHeader(
        title: "Restaurants",
        location: "London, UK",
        onBack: () => Navigator.pop(context),
        onLocationTap: () {},
      ),
      body: restaurantsAsync.when(
        data: (restaurants) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            final r = restaurants[index];
            return StoreFront(
              imageUrl: r.photoReferences.isNotEmpty
                  ? r.photoReferences.first
                  : 'https://placehold.co/600x400',
              storeName: r.name,
              category: "Restaurant",
              location: r.vicinity,
              rating: r.rating,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RestaurantDetailScreen(restaurant: r),
                  ),
                );
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}

