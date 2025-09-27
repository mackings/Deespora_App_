import 'package:dspora/App/View/Events/widgets/eGalleryHeader.dart';
import 'package:dspora/App/View/Events/widgets/eventSelection.dart';
import 'package:flutter/material.dart';

class EventDetailWidget extends StatelessWidget {
  final String eventName;
  final String rating;
  final String ratingsCount;
  final String location;
  final String status;
  final String description;
  final List<String> imageUrls;

  final VoidCallback? onReviewPressed;
  final VoidCallback? onSavePressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onTicketPressed;
  final VoidCallback? onVenueMapPressed;

  const EventDetailWidget({
    super.key,
    required this.eventName,
    required this.rating,
    required this.ratingsCount,
    required this.location,
    required this.status,
    required this.description,
    required this.imageUrls,
    this.onReviewPressed,
    this.onSavePressed,
    this.onSharePressed,
    this.onTicketPressed,
    this.onVenueMapPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          
          EventGalleryHeader(
            eventName: eventName,
            rating: rating,
            ratingsCount: ratingsCount,
            imageUrls: imageUrls,
            onReviewPressed: onReviewPressed,
            onSavePressed: onSavePressed,
            onSharePressed: onSharePressed,
          ),

          /// 🟩 Event Details Section
          EventDetailsSection(
            eventName: eventName,
            location: location,
            status: status,
            description: description,
            onTicketPressed: onTicketPressed,
            onVenueMapPressed: onVenueMapPressed,
          ),
        ],
      ),
    );
  }
}
