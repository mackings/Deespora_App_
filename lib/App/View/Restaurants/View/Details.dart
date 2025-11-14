import 'package:dspora/App/View/Interests/Model/historymodel.dart';
import 'package:dspora/App/View/Interests/Model/placemodel.dart';
import 'package:dspora/App/View/Interests/Widgets/artistCard.dart';
import 'package:dspora/App/View/Restaurants/Model/ResModel.dart';
import 'package:dspora/App/View/Restaurants/Widgets/storeDetail.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';




class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  @override
  void initState() {
    super.initState();
    _trackHistory(); // ✅ Log visit to restaurant
  }

  // ✅ Save restaurant to SharedPreferences
  Future<void> _saveRestaurantPlace(BuildContext context) async {
    final imageUrl = widget.restaurant.photoReferences.isNotEmpty
        ? widget.restaurant.photoReferences[0]
        : Images.Store;

    final place = Place(
      name: widget.restaurant.name,
      address: widget.restaurant.vicinity,
      imageUrl: imageUrl,
      rating: widget.restaurant.rating,
    );

    final success = await PlacePreferencesService.savePlace(place);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.restaurant.name} saved to your interests!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restaurant already saved or error occurred'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // ✅ Track history when user opens this restaurant
  Future<void> _trackHistory() async {
    final historyItem = HistoryItem(
      title: widget.restaurant.name,
      subtitle: widget.restaurant.vicinity,
      type: 'Restaurant',
      timestamp: DateTime.now(),
    );
    await HistoryService.addHistory(historyItem);
  }

  // ✅ Open Google Maps to leave a review
  Future<void> _openReviewInMaps(BuildContext context) async {
    try {
      // Encode the place name for URL
      final encodedName = Uri.encodeComponent(widget.restaurant.name);
      final encodedAddress = Uri.encodeComponent(widget.restaurant.vicinity);
      
      // Google Maps URL for searching and reviewing a place
      // This works for both iOS and Android
      final mapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedName+$encodedAddress'
      );

      if (await canLaunchUrl(mapsUrl)) {
        await launchUrl(
          mapsUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open Google Maps'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening Maps: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> imageUrls = (widget.restaurant.photoReferences.isNotEmpty)
        ? widget.restaurant.photoReferences
        : [Images.Store];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: CustomText(text: widget.restaurant.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🍽 Restaurant Details
            RestaurantDetailWidget(
              storeName: widget.restaurant.name,
              rating: widget.restaurant.rating.toString(),
              ratingsCount: "${widget.restaurant.reviews.length}",
              location: widget.restaurant.vicinity,
              status: widget.restaurant.openNow ? "Open now" : "Closed",
              description:
                  "Discover ${widget.restaurant.name} located at ${widget.restaurant.vicinity}.",
              imageUrls: imageUrls,
              onReviewPressed: () {
                _openReviewInMaps(context);
              },
              onSavePressed: () {
               _saveRestaurantPlace(context);
              },
              onSharePressed: () {},
              onUberEatsPressed: () {},
              onGrubhubPressed: () {},
              onDoorDashPressed: () {},
              onOpenInMapsPressed: () {},
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomText(
                text: "Reviews",
                title: true,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),

            if (widget.restaurant.reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "No reviews yet.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...widget.restaurant.reviews.map(
                (review) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage: review.profilePhotoUrl.isNotEmpty
                        ? NetworkImage(review.profilePhotoUrl)
                        : const NetworkImage(Images.Store),
                  ),
                  title: Text(
                    review.authorName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < review.rating.round()
                                ? Icons.star
                                : Icons.star_border,
                            size: 14,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(review.text),
                      const SizedBox(height: 4),
                      Text(
                        review.relativeTime,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}