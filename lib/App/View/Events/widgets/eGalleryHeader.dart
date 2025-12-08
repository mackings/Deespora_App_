import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';

class EventGalleryHeader extends StatelessWidget {
  final String eventName;
  final String rating;
  final String ratingsCount;
  final List<String> imageUrls;
  final VoidCallback? onReviewPressed;
  final VoidCallback? onSavePressed;
  final VoidCallback? onSharePressed;

  const EventGalleryHeader({
    super.key,
    required this.eventName,
    required this.rating,
    required this.ratingsCount,
    required this.imageUrls,
    this.onReviewPressed,
    this.onSavePressed,
    this.onSharePressed,
  });

  @override
  Widget build(BuildContext context) {
    final displayImages = imageUrls.isNotEmpty
        ? imageUrls
        : [
            "https://placehold.co/233x93",
            "https://placehold.co/122x151",
            "https://placehold.co/175x93",
            "https://placehold.co/175x93",
          ];

    return Column(
      children: [
        // IMAGE GALLERY
        Container(
          width: double.infinity,
          height: 306,
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: Image.network(displayImages[0], fit: BoxFit.cover)),
                    if (displayImages.length > 1)
                      Image.network(displayImages[1], width: 122.33, height: 151, fit: BoxFit.cover),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    if (displayImages.length > 2)
                      Expanded(child: Image.network(displayImages[2], fit: BoxFit.cover)),
                    if (displayImages.length > 3)
                      Expanded(child: Image.network(displayImages[3], fit: BoxFit.cover)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // HEADER
        CustomText(text: eventName, title: true, fontSize: 24),
        CustomText(text: '$rating • $ratingsCount ratings', fontSize: 14),

        // ACTION BUTTONS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            //  _buildActionButton(Icons.reviews, 'Review', onReviewPressed),
              _buildActionButton(Icons.bookmark_border, 'Save', onSavePressed),
              _buildActionButton(Icons.share, 'Share', onSharePressed),
            ],
          ),
        ),
      ],
    );
  }

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
