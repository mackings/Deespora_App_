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

  const GlobalGalleryHeader({
    super.key,
    required this.storeName,
    required this.rating,
    required this.ratingsCount,
    required this.imageUrls,
    this.onReviewPressed,
    this.onSavePressed,
    this.onSharePressed,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Adjust the image list
    final displayImages = imageUrls.isEmpty
        ? [
            "https://placehold.co/233x93",
            "https://placehold.co/122x151",
            "https://placehold.co/175x93",
            "https://placehold.co/175x93",
          ]
        : (imageUrls.length == 1
            ? [
                imageUrls[0],
                imageUrls[0],
                imageUrls[0],
              ]
            : imageUrls);

    return Column(
      children: [
        // 🖼 IMAGE GALLERY
        Container(
          width: double.infinity,
          height: 306,
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildSafeImage(displayImages[0])),
                    if (displayImages.length > 1)
                      _buildSafeImage(
                        displayImages[1],
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
                      Expanded(child: _buildSafeImage(displayImages[2])),
                    if (displayImages.length > 3)
                      Expanded(child: _buildSafeImage(displayImages[3])),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 🏷 HEADER
        Padding(
          padding: const EdgeInsets.only(left: 15,right: 15),
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
              _buildActionButton(Icons.bookmark_border, 'Save', onSavePressed),
              _buildActionButton(Icons.share, 'Share', onSharePressed),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ Safe Image Loader (handles 404s, broken URLs, etc.)
  Widget _buildSafeImage(String url, {double? width, double? height}) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(
          Icons.broken_image,
          color: Colors.grey,
          size: 40,
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
            )
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
