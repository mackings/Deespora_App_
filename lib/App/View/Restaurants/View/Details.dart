import 'package:dspora/App/View/Interests/Api/placeService.dart';
import 'package:dspora/App/View/Interests/Model/historymodel.dart';
import 'package:dspora/App/View/Interests/Model/placemodel.dart';
import 'package:dspora/App/View/Interests/Widgets/artistCard.dart';
import 'package:dspora/App/View/Restaurants/Model/ResModel.dart';
import 'package:dspora/App/View/Restaurants/Model/ReviewModel.dart';
import 'package:dspora/App/View/Restaurants/Widgets/storeDetail.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  bool _isSaved = false;
  late Restaurant _restaurant;
  bool _isLoadingDetails = false;

  List<String> _mergeUrls(List<String> primary, List<String> secondary) {
    final seen = <String>{};
    final merged = <String>[];

    for (final url in [...primary, ...secondary]) {
      if (seen.add(url)) {
        merged.add(url);
      }
    }

    return merged;
  }

  List<Review> _mergeReviews(List<Review> primary, List<Review> secondary) {
    final seen = <String>{};
    final merged = <Review>[];

    for (final review in [...primary, ...secondary]) {
      final signature =
          '${review.authorName}|${review.relativeTime}|${review.text}';
      if (seen.add(signature)) {
        merged.add(review);
      }
    }

    return merged;
  }

  Restaurant _mergeRestaurant(Restaurant current, Restaurant detailed) {
    return Restaurant(
      id: detailed.id.isNotEmpty ? detailed.id : current.id,
      name: detailed.name.isNotEmpty ? detailed.name : current.name,
      vicinity: detailed.vicinity.isNotEmpty
          ? detailed.vicinity
          : current.vicinity,
      rating: detailed.rating > 0 ? detailed.rating : current.rating,
      openNow: detailed.openNow,
      photoUrl: detailed.photoUrl ?? current.photoUrl,
      thumbnailUrl: detailed.thumbnailUrl ?? current.thumbnailUrl,
      iconUrl: detailed.iconUrl ?? current.iconUrl,
      hasPhoto: detailed.hasPhoto ?? current.hasPhoto,
      userRatingsTotal: detailed.userRatingsTotal ?? current.userRatingsTotal,
      photoReferences: _mergeUrls(
        detailed.photoReferences,
        current.photoReferences,
      ),
      reviews: _mergeReviews(detailed.reviews, current.reviews),
      distanceKm: detailed.distanceKm ?? current.distanceKm,
      distanceMinutes: detailed.distanceMinutes ?? current.distanceMinutes,
    );
  }

  List<String> get _detailImageUrls {
    final gallery = _restaurant.galleryImageUrls;
    if (gallery.length <= 2 && gallery.isNotEmpty) {
      return [gallery.first];
    }
    if (gallery.isNotEmpty) {
      return gallery;
    }
    final fallback = _restaurant.imageUrls;
    return fallback.length <= 2 && fallback.isNotEmpty
        ? [fallback.first]
        : fallback;
  }

  List<Review> get _visibleReviews {
    return _mergeReviews(_restaurant.reviews, widget.restaurant.reviews);
  }

  @override
  void initState() {
    super.initState();
    _restaurant = widget.restaurant;
    _trackHistory();
    _loadSavedState();
    _hydrateFromCachedDiscovery();
    _fetchRestaurantDiscoverySnapshot();
    _fetchRestaurantDetails();
  }

  Future<void> _hydrateFromCachedDiscovery() async {
    final cached = await PlaceFetchService.findCachedRestaurant(
      placeId: _restaurant.id,
      name: _restaurant.name,
      address: _restaurant.vicinity,
    );

    if (!mounted || cached == null) {
      return;
    }

    setState(() {
      _restaurant = _mergeRestaurant(_restaurant, cached);
    });
  }

  Future<void> _fetchRestaurantDetails() async {
    if (_restaurant.id.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingDetails = true;
    });

    try {
      final detailed = await PlaceFetchService.fetchRestaurantById(
        _restaurant.id,
      );

      if (!mounted || detailed == null) {
        return;
      }

      setState(() {
        _restaurant = _mergeRestaurant(_restaurant, detailed);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDetails = false;
        });
      }
    }
  }

  Future<void> _fetchRestaurantDiscoverySnapshot() async {
    final shouldFetch =
        _restaurant.reviews.isEmpty || _restaurant.galleryImageUrls.length <= 1;

    if (!shouldFetch) {
      return;
    }

    final discovery = await PlaceFetchService.fetchRestaurantDiscoverySnapshot(
      placeId: _restaurant.id,
      name: _restaurant.name,
      address: _restaurant.vicinity,
    );

    if (!mounted || discovery == null) {
      return;
    }

    setState(() {
      _restaurant = _mergeRestaurant(_restaurant, discovery);
    });
  }

  Future<void> _loadSavedState() async {
    final saved = await PlacePreferencesService.isPlaceSaved(
      _restaurant.name,
      _restaurant.vicinity,
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
                'This restaurant will be removed from your interests.',
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

  Future<void> _saveRestaurantPlace(BuildContext context) async {
    final imageUrl = _restaurant.primaryImageUrl;

    final place = Place(
      name: _restaurant.name,
      address: _restaurant.vicinity,
      imageUrl: imageUrl ?? '',
      rating: _restaurant.rating,
      type: 'Restaurant', // ✅ Add type
      openNow: _restaurant.openNow,
      id: _restaurant.id, // ✅ Add id
    );

    final success = await PlacePreferencesService.savePlace(place);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_restaurant.name} saved to your interests!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _isSaved = true;
      });
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restaurant already saved or error occurred'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _removeRestaurantPlace(BuildContext context) async {
    final confirmed = await _confirmUnsave();
    if (!confirmed) {
      return;
    }
    final success = await PlacePreferencesService.removePlace(
      _restaurant.name,
      _restaurant.vicinity,
    );
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_restaurant.name} removed'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      setState(() {
        _isSaved = false;
      });
    }
  }

  // ✅ Track history when user opens this restaurant
  Future<void> _trackHistory() async {
    final historyItem = HistoryItem(
      title: _restaurant.name,
      subtitle: _restaurant.vicinity,
      type: 'Restaurant',
      timestamp: DateTime.now(),
    );
    await HistoryService.addHistory(historyItem);
  }

  // ✅ Open Google Maps for review
  Future<void> _openReviewInMaps() async {
    try {
      final encodedName = Uri.encodeComponent(widget.restaurant.name);
      final encodedAddress = Uri.encodeComponent(_restaurant.vicinity);

      final mapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedName+$encodedAddress',
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

  // ✅ Share restaurant
  Future<void> _shareRestaurant() async {
    try {
      final ratingText = '⭐ Rating: ${_restaurant.rating}/5\n';
      final message =
          '''
Check out ${_restaurant.name}!

$ratingText📍 Location: ${_restaurant.vicinity}

Find it on Google Maps:
https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('${_restaurant.name} ${_restaurant.vicinity}')}
''';

      await Share.share(message, subject: 'Check out ${_restaurant.name}');
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
    final imageUrls = _detailImageUrls;
    final visibleReviews = _visibleReviews;
    final ratingsCount =
        (_restaurant.userRatingsTotal != null &&
            _restaurant.userRatingsTotal! > 0)
        ? _restaurant.userRatingsTotal!.toString()
        : visibleReviews.length.toString();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: CustomText(text: _restaurant.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🍽 Restaurant Details
            RestaurantDetailWidget(
              storeName: _restaurant.name,
              rating: _restaurant.rating.toString(),
              ratingsCount: ratingsCount,
              location: _restaurant.vicinity,
              status: _restaurant.openNow ? "Open now" : "Closed",
              description:
                  "Discover ${_restaurant.name} located at ${_restaurant.vicinity}.",
              imageUrls: imageUrls,
              onReviewPressed: _openReviewInMaps,
              onSavePressed: () {
                if (_isSaved) {
                  _removeRestaurantPlace(context);
                } else {
                  _saveRestaurantPlace(context);
                }
              },
              saveLabel: _isSaved ? 'Unsave' : 'Save',
              saveIcon: _isSaved
                  ? Icons.bookmark_remove
                  : Icons.bookmark_border,
              onSharePressed: _shareRestaurant,
              onUberEatsPressed: () {},
              onGrubhubPressed: () {},
              onDoorDashPressed: () {},
              onOpenInMapsPressed: () {},
            ),

            const SizedBox(height: 16),

            if (_isLoadingDetails)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: LinearProgressIndicator(),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomText(text: "Reviews", title: true, fontSize: 18),
            ),
            const SizedBox(height: 8),

            if (_isLoadingDetails && visibleReviews.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Loading reviews...",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else if (visibleReviews.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "No reviews yet.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...visibleReviews.map(
                (review) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage: review.profilePhotoUrl.isNotEmpty
                        ? NetworkImage(review.profilePhotoUrl)
                        : const AssetImage(Images.restaurantPlaceholderAsset)
                              as ImageProvider,
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
