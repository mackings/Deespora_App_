import 'package:dspora/App/View/Catering/Model/cateringModel.dart';
import 'package:dspora/App/View/Interests/Model/historymodel.dart';
import 'package:dspora/App/View/Interests/Model/placemodel.dart';
import 'package:dspora/App/View/Interests/Widgets/artistCard.dart';
import 'package:dspora/App/View/Restaurants/Model/ResModel.dart';
import 'package:dspora/App/View/Widgets/GLOBAL/FDetailwidget.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:flutter/material.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';



class GlobalStoreDetails extends StatefulWidget {
  final Catering catering;

  const GlobalStoreDetails({super.key, required this.catering});

  @override
  State<GlobalStoreDetails> createState() => _GlobalStoreDetailsState();
}

class _GlobalStoreDetailsState extends State<GlobalStoreDetails> {

  @override
  void initState() {
    super.initState();
    _trackHistory();
  }

  // ✅ Save Catering place to SharedPreferences
  Future<void> _savePlaceFromCatering(BuildContext context) async {
    final imageUrl = widget.catering.photoReferences.isNotEmpty
        ? widget.catering.photoReferences[0]
        : Images.Store;

    final place = Place(
      name: widget.catering.name,
      address: widget.catering.address,
      imageUrl: imageUrl,
      rating: widget.catering.rating,
    );

    final success = await PlacePreferencesService.savePlace(place);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.catering.name} saved to your interests!'),
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

  // ✅ Track when the user opens this store
  Future<void> _trackHistory() async {
    final historyItem = HistoryItem(
      title: widget.catering.name,
      subtitle: widget.catering.address,
      type: 'Catering',
      timestamp: DateTime.now(),
    );
    await HistoryService.addHistory(historyItem);
  }

  // ✅ Open Google Maps for review
  Future<void> _openReviewInMaps() async {
    try {
      final encodedName = Uri.encodeComponent(widget.catering.name);
      final encodedAddress = Uri.encodeComponent(widget.catering.address);
      
      final mapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedName+$encodedAddress'
      );

      if (await canLaunchUrl(mapsUrl)) {
        await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open Google Maps'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening Maps: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ Share place
  Future<void> _sharePlace() async {
    try {
      final ratingText = '⭐ Rating: ${widget.catering.rating}/5\n';
      final message = '''
Check out ${widget.catering.name}!

$ratingText📍 Location: ${widget.catering.address}

Find it on Google Maps:
https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('${widget.catering.name} ${widget.catering.address}')}
''';

      await Share.share(message, subject: 'Check out ${widget.catering.name}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> imageUrls = (widget.catering.photoReferences.isNotEmpty)
        ? widget.catering.photoReferences
        : [Images.Store];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: CustomText(text: widget.catering.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏪 Store Details
            GlobalDetailWidget(
              storeName: widget.catering.name,
              rating: widget.catering.rating.toString(),
              ratingsCount: "${widget.catering.reviews.length}",
              location: widget.catering.address,
              status: widget.catering.openNow ? "Open now" : "Closed",
              description:
                  "Discover ${widget.catering.name} located at ${widget.catering.address}.",
              imageUrls: imageUrls,
              onReviewPressed: _openReviewInMaps,
              onSavePressed: () {
                _savePlaceFromCatering(context);
              },
              onSharePressed: _sharePlace,
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

            if (widget.catering.reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "No reviews yet.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...widget.catering.reviews.map(
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