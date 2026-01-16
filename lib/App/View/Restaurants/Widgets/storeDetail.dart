import 'package:dspora/App/View/Restaurants/Widgets/Details.dart';
import 'package:dspora/App/View/Restaurants/Widgets/GalleryHeader.dart';
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
  final String? saveLabel;
  final IconData? saveIcon;
  final VoidCallback? onUberEatsPressed;
  final VoidCallback? onGrubhubPressed;
  final VoidCallback? onDoorDashPressed;
  final VoidCallback? onOpenInMapsPressed;

  const RestaurantDetailWidget({
    super.key,
    required this.storeName,
    required this.rating,
    required this.ratingsCount,
    required this.location,
    required this.status,
    required this.description,
    required this.imageUrls,
    this.onReviewPressed,
    this.onSavePressed,
    this.onSharePressed,
    this.saveLabel,
    this.saveIcon,
    this.onUberEatsPressed,
    this.onGrubhubPressed,
    this.onDoorDashPressed,
    this.onOpenInMapsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          RestaurantGalleryHeader(
            storeName: storeName,
            rating: rating,
            ratingsCount: ratingsCount,
            imageUrls: imageUrls,
            onReviewPressed: onReviewPressed,
            onSavePressed: onSavePressed,
            onSharePressed: onSharePressed,
            saveLabel: saveLabel,
            saveIcon: saveIcon,
          ),
          RestaurantDetailsSection(
            storeName: storeName,
            location: location,
            status: status,
            description: description,
            onUberEatsPressed: onUberEatsPressed,
            onGrubhubPressed: onGrubhubPressed,
            onDoorDashPressed: onDoorDashPressed,
            onOpenInMapsPressed: onOpenInMapsPressed,
          ),
        ],
      ),
    );
  }
}



