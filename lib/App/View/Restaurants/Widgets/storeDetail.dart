import 'package:dspora/App/View/Widgets/custombtn.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';

class RestaurantDetailWidget extends StatelessWidget {
  final String storeName;
  final String rating;
  final String ratingsCount;
  final String location;
  final String status;
  final String description;
  final List<String> imageUrls;
  final VoidCallback? onReviewPressed;
  final VoidCallback? onSavePressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onUberEatsPressed;
  final VoidCallback? onGrubhubPressed;
  final VoidCallback? onDoorDashPressed;
  final VoidCallback? onOpenInMapsPressed;
  final Color primaryColor;
  final double? containerWidth;
  final double? containerHeight;

  const RestaurantDetailWidget({
    super.key,
    required this.storeName,
    this.rating = '4.9',
    this.ratingsCount = '72',
    required this.location,
    this.status = 'Open now',
    required this.description,
    this.imageUrls = const [],
    this.onReviewPressed,
    this.onSavePressed,
    this.onSharePressed,
    this.onUberEatsPressed,
    this.onGrubhubPressed,
    this.onDoorDashPressed,
    this.onOpenInMapsPressed,
    this.primaryColor = const Color(0xFF37B6AF),
    this.containerWidth = 375,
    this.containerHeight = 1144,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: containerWidth,
          height: containerHeight,
          color: Colors.transparent,
          child: Stack(
            children: [
              _buildMainContent(),
              _buildDetailsContainer(),
              _buildDescription(),     // outside the main box
              _buildVenueLocation(),
              _buildBottomActions(),
              _buildOpenInMapsButton(),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------
  // IMAGE GALLERY + HEADER + ACTIONS
  // -------------------------
  Widget _buildMainContent() {
    return Positioned(
      left: 0,
      top: 47,
      child: SizedBox(
        width: containerWidth!,
        child: Column(
          children: [
            _buildImageGallery(),
            _buildRestaurantHeader(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    final displayImages = imageUrls.isNotEmpty
        ? imageUrls
        : [
            "https://placehold.co/233x93",
            "https://placehold.co/122x151",
            "https://placehold.co/175x93",
            "https://placehold.co/175x93",
          ];

    return Container(
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
    );
  }

  Widget _buildRestaurantHeader() {
    return Column(
      children: [
        CustomText(text: storeName, title: true, fontSize: 24),
        CustomText(text: '$rating • $ratingsCount ratings', fontSize: 14),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionButton(Icons.reviews, 'Review', onReviewPressed),
          _buildActionButton(Icons.bookmark_border, 'Save', onSavePressed),
          _buildActionButton(Icons.share, 'Share', onSharePressed),
        ],
      ),
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

  // -------------------------
  // DETAILS CONTAINER
  // -------------------------
  Widget _buildDetailsContainer() {
    return Positioned(
      left: 12,
      top: 547,
      child: Container(
        width: containerWidth! - 24,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: storeName, title: true, fontSize: 18),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(child: CustomText(text: location, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                CustomText(text: status, fontSize: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // DESCRIPTION OUTSIDE MAIN BOX
  // -------------------------
  Widget _buildDescription() {
    return Positioned(
      left: 12,
      top: 690,
      child: SizedBox(
        width: containerWidth! - 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: 'Description', title: true, fontSize: 16),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: description,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  TextSpan(
                    text: '  Read More..',
                    style: TextStyle(fontSize: 14, color: primaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // VENUE & MAP
  // -------------------------
  Widget _buildVenueLocation() {
    return Positioned(
      left: 12,
      top: 850,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: 'Venue & Location', title: true, fontSize: 16),
          const SizedBox(height: 8),
          Container(
            width: containerWidth! - 24,
            height: 212,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.map, size: 48, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // DELIVERY BUTTONS
  // -------------------------
  Widget _buildBottomActions() {
    return Positioned(
      left: 0,
      top: 1100,
      child: Container(
        width: containerWidth!,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            _buildDeliveryButton(
              'Uber Eats',
              'https://upload.wikimedia.org/wikipedia/commons/c/cc/Uber_Eats_Logo.svg',
              onUberEatsPressed,
            ),
            _buildDeliveryButton('Grubhub', null, onGrubhubPressed),
            _buildDeliveryButton(
              'DoorDash',
              'https://upload.wikimedia.org/wikipedia/commons/e/e8/DoorDash_Logo.png',
              onDoorDashPressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryButton(
      String text, String? imageUrl, VoidCallback? onPressed) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              imageUrl != null
                  ? Image.network(imageUrl, width: 24, height: 24)
                  : const Icon(Icons.delivery_dining, size: 24, color: Colors.grey),
              const SizedBox(width: 6),
              CustomText(text: text, fontSize: 14),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------
  // OPEN IN MAPS BUTTON
  // -------------------------
  Widget _buildOpenInMapsButton() {
    return Positioned(
      bottom: 12,
      left: 12,
      right: 12,
      child: SizedBox(
        width: double.infinity,
        child: CustomBtn(
          text: "Open in Maps",
          onPressed: onOpenInMapsPressed,
        ),
      ),
    );
  }
}



