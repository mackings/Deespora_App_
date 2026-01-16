
import 'package:dspora/App/View/Interests/Model/historymodel.dart';
import 'package:dspora/App/View/Interests/Model/placemodel.dart';
import 'package:dspora/App/View/Interests/Widgets/artistCard.dart';
import 'package:dspora/App/View/RealEstate/Model/realestateModel.dart';
import 'package:dspora/App/View/Widgets/GLOBAL/FDetailwidget.dart';
import 'package:dspora/App/View/Widgets/GLOBAL/ReviewShare.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:flutter/material.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';



class RealestateStoreDetails extends StatefulWidget {
  final RealEstateModel realestate;

  const RealestateStoreDetails({super.key, required this.realestate});

  @override
  State<RealestateStoreDetails> createState() => _RealestateStoreDetailsState();
}

class _RealestateStoreDetailsState extends State<RealestateStoreDetails> {
  bool _isSaved = false;

  Future<void> _savePlaceFromRealEstate(BuildContext context) async {
  final imageUrl = widget.realestate.photoReferences.isNotEmpty 
      ? widget.realestate.photoReferences[0] 
      : Images.Store;
  
  final place = Place(
    name: widget.realestate.name,
    address: widget.realestate.address,
    imageUrl: imageUrl,
    rating: widget.realestate.rating,
    type: 'Worship', // ✅ Add type
    openNow: widget.realestate.openNow,
    id: widget.realestate.id, // ✅ Add id
  );
  
  final success = await PlacePreferencesService.savePlace(place);
  
  if (success && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.realestate.name} saved to your interests!'),
        backgroundColor: Colors.green,
      ),
    );
    setState(() {
      _isSaved = true;
    });
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
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final saved = await PlacePreferencesService.isPlaceSaved(
      widget.realestate.name,
      widget.realestate.address,
    );
    if (mounted) {
      setState(() {
        _isSaved = saved;
      });
    }
  }

  Future<bool> _confirmUnsave() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Remove from saved?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                'This worship place will be removed from your interests.',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF37B6AF),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Unsave'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    return result ?? false;
  }

  Future<void> _removePlaceFromRealEstate(BuildContext context) async {
    final confirmed = await _confirmUnsave();
    if (!confirmed) {
      return;
    }
    final success = await PlacePreferencesService.removePlace(
      widget.realestate.name,
      widget.realestate.address,
    );
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.realestate.name} removed'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      setState(() {
        _isSaved = false;
      });
    }
  }

  Future<void> _trackHistory() async {
    final historyItem = HistoryItem(
      title: widget.realestate.name,
      subtitle: widget.realestate.address,
      type: 'Worship',
      timestamp: DateTime.now(),
    );
    await HistoryService.addHistory(historyItem);
  }

  // ✅ Open Google Maps for review
  Future<void> _openReviewInMaps() async {
    try {
      final encodedName = Uri.encodeComponent(widget.realestate.name);
      final encodedAddress = Uri.encodeComponent(widget.realestate.address);
      
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
      final ratingText = '⭐ Rating: ${widget.realestate.rating}/5\n';
      final message = '''
Check out ${widget.realestate.name}!

$ratingText📍 Location: ${widget.realestate.address}

Find it on Google Maps:
https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('${widget.realestate.name} ${widget.realestate.address}')}
''';

      await Share.share(message, subject: 'Check out ${widget.realestate.name}');
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
    final List<String> imageUrls = (widget.realestate.photoReferences.isNotEmpty)
        ? widget.realestate.photoReferences
        : [Images.Store];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: CustomText(text: widget.realestate.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Real Estate Details
            GlobalDetailWidget(
              storeName: widget.realestate.name,
              rating: widget.realestate.rating.toString(),
              ratingsCount: "${widget.realestate.reviews.length}",
              location: widget.realestate.address,
              status: widget.realestate.openNow ? "Open now" : "Closed",
              description:
                  "Discover ${widget.realestate.name} located at ${widget.realestate.address}.",
              imageUrls: imageUrls,
              onReviewPressed: _openReviewInMaps,
              onSavePressed: () {
                if (_isSaved) {
                  _removePlaceFromRealEstate(context);
                } else {
                  _savePlaceFromRealEstate(context);
                }
              },
              saveLabel: _isSaved ? 'Unsave' : 'Save',
              saveIcon: _isSaved ? Icons.bookmark_remove : Icons.bookmark_border,
              onSharePressed: _sharePlace,
              onUberEatsPressed: () {},
              onGrubhubPressed: () {},
              onDoorDashPressed: () {},
              onOpenInMapsPressed: () {},
            ),

            const SizedBox(height: 24),

            // Reviews Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomText(
                text: "Reviews",
                title: true,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),

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
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
