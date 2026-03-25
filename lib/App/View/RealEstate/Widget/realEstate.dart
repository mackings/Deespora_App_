import 'package:dspora/App/View/Interests/Api/placeService.dart';
import 'package:dspora/App/View/Interests/Model/historymodel.dart';
import 'package:dspora/App/View/Interests/Model/placemodel.dart';
import 'package:dspora/App/View/Interests/Widgets/artistCard.dart';
import 'package:dspora/App/View/RealEstate/Model/realestateModel.dart';
import 'package:dspora/App/View/Widgets/GLOBAL/FDetailwidget.dart';
import 'package:dspora/App/View/Widgets/GLOBAL/GlobalModel.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:flutter/material.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class RealestateStoreDetails extends StatefulWidget {
  final WorshipModel realestate;

  const RealestateStoreDetails({super.key, required this.realestate});

  @override
  State<RealestateStoreDetails> createState() => _RealestateStoreDetailsState();
}

class _RealestateStoreDetailsState extends State<RealestateStoreDetails> {
  bool _isSaved = false;
  late WorshipModel _realestate;
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

  WorshipModel _mergeWorship(WorshipModel current, WorshipModel detailed) {
    return WorshipModel(
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
    final gallery = _realestate.galleryImageUrls;
    if (gallery.length <= 2 && gallery.isNotEmpty) {
      return [gallery.first];
    }
    if (gallery.isNotEmpty) {
      return gallery;
    }
    final fallback = _realestate.imageUrls;
    return fallback.length <= 2 && fallback.isNotEmpty
        ? [fallback.first]
        : fallback;
  }

  List<GlobalReview> get _visibleReviews {
    return _mergeReviews(_realestate.reviews, widget.realestate.reviews);
  }

  Future<void> _savePlaceFromRealEstate(BuildContext context) async {
    final imageUrl = _realestate.primaryImageUrl;

    final place = Place(
      name: _realestate.name,
      address: _realestate.address,
      imageUrl: imageUrl ?? '',
      rating: _realestate.rating,
      type: 'Worship', // ✅ Add type
      openNow: _realestate.openNow,
      id: _realestate.id, // ✅ Add id
    );

    final success = await PlacePreferencesService.savePlace(place);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_realestate.name} saved to your interests!'),
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
    _realestate = widget.realestate;
    _trackHistory();
    _loadSavedState();
    _hydrateFromCachedDiscovery();
    _fetchWorshipDiscoverySnapshot();
    _fetchRealEstateDetails();
  }

  Future<void> _hydrateFromCachedDiscovery() async {
    final cached = await PlaceFetchService.findCachedWorship(
      placeId: _realestate.id,
      name: _realestate.name,
      address: _realestate.address,
    );

    if (!mounted || cached == null) {
      return;
    }

    setState(() {
      _realestate = _mergeWorship(_realestate, cached);
    });
  }

  Future<void> _fetchRealEstateDetails() async {
    if (_realestate.id.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingDetails = true;
    });

    try {
      final detailed = await PlaceFetchService.fetchRealEstateById(
        _realestate.id,
      );

      if (!mounted || detailed == null) {
        return;
      }

      setState(() {
        _realestate = _mergeWorship(_realestate, detailed);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDetails = false;
        });
      }
    }
  }

  Future<void> _fetchWorshipDiscoverySnapshot() async {
    final shouldFetch =
        _realestate.reviews.isEmpty || _realestate.galleryImageUrls.length <= 1;

    if (!shouldFetch) {
      return;
    }

    final discovery = await PlaceFetchService.fetchWorshipDiscoverySnapshot(
      placeId: _realestate.id,
      name: _realestate.name,
      address: _realestate.address,
    );

    if (!mounted || discovery == null) {
      return;
    }

    setState(() {
      _realestate = _mergeWorship(_realestate, discovery);
    });
  }

  Future<void> _loadSavedState() async {
    final saved = await PlacePreferencesService.isPlaceSaved(
      _realestate.name,
      _realestate.address,
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
      _realestate.name,
      _realestate.address,
    );
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_realestate.name} removed'),
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
      title: _realestate.name,
      subtitle: _realestate.address,
      type: 'Worship',
      timestamp: DateTime.now(),
    );
    await HistoryService.addHistory(historyItem);
  }

  // ✅ Open Google Maps for review
  Future<void> _openReviewInMaps() async {
    try {
      final encodedName = Uri.encodeComponent(_realestate.name);
      final encodedAddress = Uri.encodeComponent(_realestate.address);

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
      final ratingText = '⭐ Rating: ${_realestate.rating}/5\n';
      final message =
          '''
Check out ${_realestate.name}!

$ratingText📍 Location: ${_realestate.address}

Find it on Google Maps:
https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('${_realestate.name} ${_realestate.address}')}
''';

      await Share.share(message, subject: 'Check out ${_realestate.name}');
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
        (_realestate.userRatingsTotal != null &&
            _realestate.userRatingsTotal! > 0)
        ? _realestate.userRatingsTotal!.toString()
        : visibleReviews.length.toString();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: CustomText(text: _realestate.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Real Estate Details
            GlobalDetailWidget(
              storeName: _realestate.name,
              rating: _realestate.rating.toString(),
              ratingsCount: ratingsCount,
              location: _realestate.address,
              status: _realestate.openNow ? "Open now" : "Closed",
              description:
                  "Discover ${_realestate.name} located at ${_realestate.address}.",
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
              saveIcon: _isSaved
                  ? Icons.bookmark_remove
                  : Icons.bookmark_border,
              onSharePressed: _sharePlace,
              onUberEatsPressed: () {},
              onGrubhubPressed: () {},
              onDoorDashPressed: () {},
              onOpenInMapsPressed: () {},
            ),

            const SizedBox(height: 24),
            if (_isLoadingDetails)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: LinearProgressIndicator(),
              ),

            // Reviews Section
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
                        : const AssetImage(Images.worshipPlaceholderAsset)
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

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
