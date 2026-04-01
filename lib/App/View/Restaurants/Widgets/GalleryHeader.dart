import 'package:dspora/App/View/Interests/Model/historymodel.dart';
import 'package:dspora/App/View/Interests/Widgets/artistCard.dart';
import 'package:dspora/App/View/Restaurants/Model/saveRes.dart';
import 'package:dspora/App/View/Restaurants/Providers/resPrefPro.dart';
import 'package:dspora/App/View/Widgets/GLOBAL/fallback_network_image.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';

class RestaurantGalleryHeader extends StatefulWidget {
  final String storeName;
  final String rating;
  final String ratingsCount;
  final List<String> imageUrls;
  final VoidCallback? onReviewPressed;
  final VoidCallback? onSavePressed;
  final VoidCallback? onSharePressed;
  final String? saveLabel;
  final IconData? saveIcon;

  const RestaurantGalleryHeader({
    super.key,
    required this.storeName,
    required this.rating,
    required this.ratingsCount,
    required this.imageUrls,
    this.onReviewPressed,
    this.onSavePressed,
    this.onSharePressed,
    this.saveLabel,
    this.saveIcon,
  });

  @override
  State<RestaurantGalleryHeader> createState() =>
      _RestaurantGalleryHeaderState();
}

class _RestaurantGalleryHeaderState extends State<RestaurantGalleryHeader> {
  List<String> _candidatesForSlot(int startIndex) {
    if (widget.imageUrls.isEmpty) {
      return const [];
    }

    final candidates = <String>[];
    for (int index = 0; index < widget.imageUrls.length; index++) {
      candidates.add(
        widget.imageUrls[(startIndex + index) % widget.imageUrls.length],
      );
    }
    return candidates;
  }

  @override
  void initState() {
    super.initState();
    // _trackHistory();
  }

  Future<void> _trackHistory() async {
    // Adjust these fields to match your restaurant object
    //final location = "${yourRestaurant.city}, ${yourRestaurant.country}";

    final historyItem = HistoryItem(
      title: widget.storeName,
      subtitle: "",
      type: 'Restaurant',
      timestamp: DateTime.now(),
    );
    await HistoryService.addHistory(historyItem);
  }

  Future<void> _saveRestaurant(BuildContext context) async {
    final savedRestaurant = SavedRestaurant(
      name: widget.storeName,
      imageUrl: widget.imageUrls.first,
      location: "",
      rating: widget.rating,
      ratingsCount: widget.ratingsCount,
      savedDate: DateTime.now(),
    );

    final success = await RestaurantPreferencesService.saveRestaurant(
      savedRestaurant,
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.storeName} saved to your interests!'),
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

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            height: 306,
            padding: const EdgeInsets.all(10),
            child: _buildSafeImage(
              const [],
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          CustomText(text: widget.storeName, title: true, fontSize: 24),
          CustomText(
            text: '${widget.rating} • ${widget.ratingsCount} ratings',
            fontSize: 14,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  Icons.reviews,
                  'Review',
                  widget.onReviewPressed,
                ),
                _buildActionButton(
                  widget.saveIcon ?? Icons.bookmark_border,
                  widget.saveLabel ?? 'Save',
                  widget.onSavePressed,
                ),
                _buildActionButton(Icons.share, 'Share', widget.onSharePressed),
              ],
            ),
          ),
        ],
      );
    }

    if (widget.imageUrls.length <= 2) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            height: 420,
            padding: const EdgeInsets.only(top: 6),
            child: _buildSafeImage(
              _candidatesForSlot(0),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          const SizedBox(height: 14),
          CustomText(text: widget.storeName, title: true, fontSize: 24),
          CustomText(
            text: '${widget.rating} • ${widget.ratingsCount} ratings',
            fontSize: 14,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  Icons.reviews,
                  'Review',
                  widget.onReviewPressed,
                ),
                _buildActionButton(
                  widget.saveIcon ?? Icons.bookmark_border,
                  widget.saveLabel ?? 'Save',
                  widget.onSavePressed,
                ),
                _buildActionButton(Icons.share, 'Share', widget.onSharePressed),
              ],
            ),
          ),
        ],
      );
    }


    // ✅ Adjust the image list
    final displayImages = widget.imageUrls.length == 1
        ? [widget.imageUrls[0], widget.imageUrls[0], widget.imageUrls[0]]
        : widget.imageUrls;

    return Column(
      children: [
        // 🖼 IMAGE GALLERY
        Container(
          width: double.infinity,
          height: 340,
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildSafeImage(_candidatesForSlot(0))),
                    if (displayImages.length > 1)
                      _buildSafeImage(
                        _candidatesForSlot(1),
                        width: 122.33,
                        height: 151,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    if (displayImages.length > 2)
                      Expanded(child: _buildSafeImage(_candidatesForSlot(2))),
                    if (displayImages.length > 3)
                      Expanded(child: _buildSafeImage(_candidatesForSlot(3))),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 🏷 HEADER
        CustomText(text: widget.storeName, title: true, fontSize: 24),
        CustomText(
          text: '${widget.rating} • ${widget.ratingsCount} ratings',
          fontSize: 14,
        ),

        // ⚙️ ACTION BUTTONS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                Icons.reviews,
                'Review',
                widget.onReviewPressed,
              ),
              _buildActionButton(
                widget.saveIcon ?? Icons.bookmark_border,
                widget.saveLabel ?? 'Save',
                widget.onSavePressed,
              ),
              _buildActionButton(Icons.share, 'Share', widget.onSharePressed),
            ],
          ),
        ),
      ],
    );
  }


  // ✅ Safe Image Loader (handles 404s, broken URLs, etc.)
  Widget _buildSafeImage(
    List<String> imageUrls, {
    double? width,
    double? height,
  }) {
    return FallbackNetworkImage(
      imageUrls: imageUrls,
      assetPath: Images.restaurantPlaceholderAsset,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholderBuilder: (context) => Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }


  // ✅ Reusable Action Button
  Widget _buildActionButton(IconData icon, String text, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.black54),
            const SizedBox(width: 6),
            CustomText(text: text, fontSize: 14),
          ],
        ),
      ),
    );
  }
}
