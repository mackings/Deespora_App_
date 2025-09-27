import 'package:dspora/App/View/Restaurants/Widgets/expText.dart';
import 'package:dspora/App/View/Widgets/custombtn.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';

class EventDetailsSection extends StatelessWidget {
  final String eventName;
  final String location;
  final String status;
  final String description;
  final VoidCallback? onVenueMapPressed;
  final Color primaryColor;

  const EventDetailsSection({
    super.key,
    required this.eventName,
    required this.location,
    required this.status,
    required this.description,
    this.onVenueMapPressed,
    this.primaryColor = const Color(0xFF37B6AF), VoidCallback? onTicketPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // DETAILS CONTAINER
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(12),
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
              CustomText(text: eventName, title: true, fontSize: 18),
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

        // DESCRIPTION
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(text: 'Description', title: true, fontSize: 16),
              const SizedBox(height: 4),
              ExpandableText(
                text: description,
                trimLines: 3,
                readMoreColor: primaryColor,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // VENUE MAP
        Container(
          width: double.infinity,
          height: 212,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Icon(Icons.map, size: 48, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 20),

        // OPEN IN MAPS BUTTON
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: CustomBtn(
            text: "Open in Maps",
            onPressed: onVenueMapPressed,
          ),
        ),
      ],
    );
  }
}
