import 'package:dspora/App/View/Widgets/GLOBAL/fallback_network_image.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:flutter/material.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';

class GlobalGalleryHeader extends StatelessWidget {
  final String storeName;
  final String rating;
  final String ratingsCount;
  final List<String> imageUrls;
  final VoidCallback? onReviewPressed;
  final VoidCallback? onSavePressed;
  final VoidCallback? onSharePressed;
  final String? saveLabel;
  final IconData? saveIcon;

  const GlobalGalleryHeader({
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

  List<String> _candidatesForSlot(int startIndex) {
    if (imageUrls.isEmpty) {
      return const [];
    }

    final candidates = <String>[];
    for (int index = 0; index < imageUrls.length; index++) {
      candidates.add(imageUrls[(startIndex + index) % imageUrls.length]);
    }
    return candidates;
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
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
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: CustomText(text: storeName, title: true, fontSize: 24),
          ),
          CustomText(text: '$rating • $ratingsCount ratings', fontSize: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(Icons.reviews, 'Review', onReviewPressed),
                _buildActionButton(
                  saveIcon ?? Icons.bookmark_border,
                  saveLabel ?? 'Save',
                  onSavePressed,
                ),
                _buildActionButton(Icons.share, 'Share', onSharePressed),
              ],
            ),
          ),
        ],
      );
    }

    if (imageUrls.length <= 2) {
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
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: CustomText(text: storeName, title: true, fontSize: 24),
          ),
          CustomText(text: '$rating • $ratingsCount ratings', fontSize: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(Icons.reviews, 'Review', onReviewPressed),
                _buildActionButton(
                  saveIcon ?? Icons.bookmark_border,
                  saveLabel ?? 'Save',
                  onSavePressed,
                ),
                _buildActionButton(Icons.share, 'Share', onSharePressed),
              ],
            ),
          ),
        ],
      );
    }

    // ✅ Adjust the image list
    final displayImages = imageUrls.length == 1
        ? [imageUrls[0], imageUrls[0], imageUrls[0]]
        : imageUrls;

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
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: CustomText(text: storeName, title: true, fontSize: 24),
        ),
        CustomText(text: '$rating • $ratingsCount ratings', fontSize: 14),

        // ⚙️ ACTION BUTTONS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(Icons.reviews, 'Review', onReviewPressed),
              _buildActionButton(
                saveIcon ?? Icons.bookmark_border,
                saveLabel ?? 'Save',
                onSavePressed,
              ),
              _buildActionButton(Icons.share, 'Share', onSharePressed),
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
      assetPath: Images.cateringPlaceholderAsset,
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
