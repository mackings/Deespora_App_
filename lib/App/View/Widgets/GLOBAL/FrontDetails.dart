import 'package:dspora/App/View/Interests/Api/placeService.dart';
import 'package:dspora/App/View/Catering/Model/cateringModel.dart';
import 'package:dspora/App/View/Interests/Model/historymodel.dart';
import 'package:dspora/App/View/Interests/Model/placemodel.dart';
import 'package:dspora/App/View/Interests/Widgets/artistCard.dart';
import 'package:dspora/App/View/Widgets/GLOBAL/FDetailwidget.dart';
import 'package:dspora/App/View/Widgets/GLOBAL/GlobalModel.dart';
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
  bool _isSaved = false;
  late Catering _catering;
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

  List<GlobalReview> _mergeReviews(
    List<GlobalReview> primary,
    List<GlobalReview> secondary,
  ) {
    final seen = <String>{};
    final merged = <GlobalReview>[];

    for (final review in [...primary, ...secondary]) {
      final signature =
          '${review.authorName}|${review.relativeTime}|${review.text}';
      if (seen.add(signature)) {
        merged.add(review);
      }
    }

    return merged;
  }

  Catering _mergeCatering(Catering current, Catering detailed) {
    return Catering(
      id: detailed.id.isNotEmpty ? detailed.id : current.id,
      name: detailed.name.isNotEmpty ? detailed.name : current.name,
      address: detailed.address.isNotEmpty ? detailed.address : current.address,
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
    );
  }

  List<String> get _detailImageUrls {
    final gallery = _catering.galleryImageUrls;
    if (gallery.length <= 2 && gallery.isNotEmpty) {
      return [gallery.first];
    }
    if (gallery.isNotEmpty) {
      return gallery;
    }
    final fallback = _catering.imageUrls;
    return fallback.length <= 2 && fallback.isNotEmpty
        ? [fallback.first]
        : fallback;
  }

  List<GlobalReview> get _visibleReviews {
    return _mergeReviews(_catering.reviews, widget.catering.reviews);
  }

  @override
  void initState() {
    super.initState();
    _catering = widget.catering;
    _trackHistory();
    _loadSavedState();
    _hydrateFromCachedDiscovery();
    _fetchCateringDiscoverySnapshot();
    _fetchCateringDetails();
  }

  Future<void> _hydrateFromCachedDiscovery() async {
    final cached = await PlaceFetchService.findCachedCatering(
      placeId: _catering.id,
      name: _catering.name,
      address: _catering.address,
    );

    if (!mounted || cached == null) {
      return;
    }

    setState(() {
      _catering = _mergeCatering(_catering, cached);
    });
  }

  Future<void> _fetchCateringDetails() async {
    if (_catering.id.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingDetails = true;
    });

    try {
      final detailed = await PlaceFetchService.fetchCateringById(_catering.id);

      if (!mounted || detailed == null) {
        return;
      }

      setState(() {
        _catering = _mergeCatering(_catering, detailed);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDetails = false;
        });
      }
    }
  }

  Future<void> _fetchCateringDiscoverySnapshot() async {
    final shouldFetch =
        _catering.reviews.isEmpty || _catering.galleryImageUrls.length <= 1;

    if (!shouldFetch) {
      return;
    }

    final discovery = await PlaceFetchService.fetchCateringDiscoverySnapshot(
      placeId: _catering.id,
      name: _catering.name,
      address: _catering.address,
    );

    if (!mounted || discovery == null) {
      return;
    }

    setState(() {
      _catering = _mergeCatering(_catering, discovery);
    });
  }

  // ✅ Save Catering place to SharedPreferences
  Future<void> _loadSavedState() async {
    final saved = await PlacePreferencesService.isPlaceSaved(
      _catering.name,
      _catering.address,
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
                'This catering place will be removed from your interests.',
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

  Future<void> _savePlaceFromCatering(BuildContext context) async {
    final imageUrl = _catering.primaryImageUrl;

    final place = Place(
      name: _catering.name,
      address: _catering.address,
      imageUrl: imageUrl ?? '',
      rating: _catering.rating,
      type: 'Catering', // ✅ Add type
      openNow: _catering.openNow,
      id: _catering.id, // ✅ Add id
    );

    final success = await PlacePreferencesService.savePlace(place);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_catering.name} saved to your interests!'),
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

  Future<void> _removePlaceFromCatering(BuildContext context) async {
    final confirmed = await _confirmUnsave();
    if (!confirmed) {
      return;
    }
    final success = await PlacePreferencesService.removePlace(
      _catering.name,
      _catering.address,
    );
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_catering.name} removed'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      setState(() {
        _isSaved = false;
      });
    }
  }

  // ✅ Track when the user opens this store
  Future<void> _trackHistory() async {
    final historyItem = HistoryItem(
      title: _catering.name,
      subtitle: _catering.address,
      type: 'Catering',
      timestamp: DateTime.now(),
    );
    await HistoryService.addHistory(historyItem);
  }

  // ✅ Open Google Maps for review
  Future<void> _openReviewInMaps() async {
    try {
      final encodedName = Uri.encodeComponent(widget.catering.name);
      final encodedAddress = Uri.encodeComponent(_catering.address);

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

  // ✅ Share place
  Future<void> _sharePlace() async {
    try {
      final ratingText = '⭐ Rating: ${_catering.rating}/5\n';
      final message =
          '''
Check out ${_catering.name}!

$ratingText📍 Location: ${_catering.address}

Find it on Google Maps:
https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('${_catering.name} ${_catering.address}')}
''';

      await Share.share(message, subject: 'Check out ${_catering.name}');
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
        (_catering.userRatingsTotal != null && _catering.userRatingsTotal! > 0)
        ? _catering.userRatingsTotal!.toString()
        : visibleReviews.length.toString();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: CustomText(text: _catering.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏪 Store Details
            GlobalDetailWidget(
              storeName: _catering.name,
              rating: _catering.rating.toString(),
              ratingsCount: ratingsCount,
              location: _catering.address,
              status: _catering.openNow ? "Open now" : "Closed",
              description:
                  "Discover ${_catering.name} located at ${_catering.address}.",
              imageUrls: imageUrls,
              onReviewPressed: _openReviewInMaps,
              onSavePressed: () {
                if (_isSaved) {
                  _removePlaceFromCatering(context);
                } else {
                  _savePlaceFromCatering(context);
                }
              },
              saveLabel: _isSaved ? 'Unsave' : 'Save',
              saveIcon: _isSaved
                  ? Icons.bookmark_remove
                  : Icons.bookmark_border,
              onSharePressed: _sharePlace,
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
                        : const AssetImage(Images.cateringPlaceholderAsset)
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
