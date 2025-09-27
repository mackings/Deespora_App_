import 'package:dspora/App/View/Restaurants/Providers/resProvider.dart';
import 'package:dspora/App/View/Restaurants/View/Details.dart';
import 'package:dspora/App/View/Restaurants/Widgets/storeDetail.dart';
import 'package:dspora/App/View/Restaurants/Widgets/storefront.dart';
import 'package:dspora/App/View/Utils/navigator.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureHeader.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureSearch.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/LocPicker.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



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

        // 👇 Show the CitySelector in a modal bottom sheet
        onLocationTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Makes sheet taller
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            builder: (context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: CitySelector(
                    cities: [
                      'London',
                      'Lagos',
                      'New York',
                      'Paris',
                      'Tokyo',
                      'Dubai',
                      'Johannesburg',
                      'Cairo',
                      'Nairobi',
                      'Toronto',
                      'Sydney',
                      'Berlin',
                      'Moscow',
                      'Rio de Janeiro',
                    ],
                    onCitySelected: (city) {
                      // Close modal after selection
                      Navigator.pop(context);

                      // TODO: trigger a new fetch for restaurants in selected city
                      // e.g. ref.read(restaurantsProvider(city).notifier).fetchRestaurants(city);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Selected: $city')),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),

      // 📦 Restaurants List
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
