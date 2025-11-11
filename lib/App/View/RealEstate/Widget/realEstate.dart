
import 'package:dspora/App/View/Interests/Model/historymodel.dart';
import 'package:dspora/App/View/Interests/Model/placemodel.dart';
import 'package:dspora/App/View/Interests/Widgets/artistCard.dart';
import 'package:dspora/App/View/RealEstate/Model/realestateModel.dart';

import 'package:dspora/App/View/Widgets/GLOBAL/FDetailwidget.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:flutter/material.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';



class RealestateStoreDetails extends StatefulWidget {
  final RealEstateModel realestate;

  const RealestateStoreDetails({super.key, required this.realestate});

  @override
  State<RealestateStoreDetails> createState() => _RealestateStoreDetailsState();
}


class _RealestateStoreDetailsState extends State<RealestateStoreDetails> {

  Future<void> _savePlaceFromRealEstate(BuildContext context) async {
    final imageUrl = widget.realestate.photoReferences.isNotEmpty 
        ? widget.realestate.photoReferences[0] 
        : Images.Store;
    
    // Create Place object
    final place = Place(
      name: widget.realestate.name,
      address: widget.realestate.address,
      imageUrl: imageUrl,
      rating: widget.realestate.rating,
    );
    
    // Save to SharedPreferences
    final success = await PlacePreferencesService.savePlace(place);
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.realestate.name} saved to your interests!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Place already saved or error occurred'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }


  @override
void initState() {
  super.initState();
  _trackHistory();
}

Future<void> _trackHistory() async {
  final historyItem = HistoryItem(
    title: widget.realestate.name,
    subtitle: widget.realestate.address,
    type: 'RealEstate',
    timestamp: DateTime.now(),
  );
  await HistoryService.addHistory(historyItem);
}


  @override
  Widget build(BuildContext context) {
    // ✅ fallback image if no photos available
    final List<String> imageUrls = (widget.realestate.photoReferences.isNotEmpty)
        ? widget.realestate.photoReferences
        : [
            Images.Store,
          ];

    return Scaffold(
      appBar: AppBar(
        title: CustomText(text: widget.realestate.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Restaurant Details with fallback images
            GlobalDetailWidget(
              storeName: widget.realestate.name,
              rating: widget.realestate.rating.toString(),
              ratingsCount: "${widget.realestate.reviews.length}",
              location: widget.realestate.address,
              status: widget.realestate.openNow ? "Open now" : "Closed",
              description:
                  "Discover ${widget.realestate.name} located at ${widget.realestate.address}.",
              imageUrls: imageUrls,
              onReviewPressed: () {},
              onSavePressed: () {
                _savePlaceFromRealEstate(context);
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

            // ✅ Handle empty reviews gracefully
            if (widget.realestate.reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "No reviews yet.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...widget.realestate.reviews.map(
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