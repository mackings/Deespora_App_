import 'package:dspora/App/View/Catering/Model/cateringModel.dart';
import 'package:dspora/App/View/Restaurants/Model/ResModel.dart';
import 'package:dspora/App/View/Widgets/GLOBAL/FDetailwidget.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:flutter/material.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';



class GlobalStoreDetails extends StatelessWidget {
  final Catering catering;

  const GlobalStoreDetails({super.key, required this.catering});

  @override
  Widget build(BuildContext context) {
    // ✅ fallback image if no photos available
    final List<String> imageUrls = (catering.photoReferences.isNotEmpty)
        ? catering.photoReferences
        : [
            Images.Store,
          ];

    return Scaffold(
      appBar: AppBar(
        title: CustomText(text: catering.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Restaurant Details with fallback images
            GlobalDetailWidget(
              storeName: catering.name,
              rating: catering.rating.toString(),
              ratingsCount: "${catering.reviews.length}",
              location: catering.address,
              status: catering.openNow ? "Open now" : "Closed",
              description:
                  "Discover ${catering.name} located at ${catering.address}.",
              imageUrls: imageUrls,
              onReviewPressed: () {},
              onSavePressed: () {},
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

            // ✅ Handle empty reviews gracefully
            if (catering.reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "No reviews yet.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...catering.reviews.map(
                (review) => ListTile(
                  leading: CircleAvatar(
                    // ✅ fallback avatar if photo is empty or null
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
                      // ✅ Star rating row
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
