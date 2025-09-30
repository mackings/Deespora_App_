import 'package:dspora/App/View/Events/widgets/VenueMap.dart';
import 'package:dspora/App/View/Events/widgets/WebView.dart';
import 'package:dspora/App/View/Restaurants/Widgets/expText.dart';
import 'package:dspora/App/View/Widgets/custombtn.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';


class RestaurantDetailsSection extends StatefulWidget {
  final String storeName;
  final String location; // Use this as query in Google Maps
  final String status;
  final String description;
  final VoidCallback? onUberEatsPressed;
  final VoidCallback? onGrubhubPressed;
  final VoidCallback? onDoorDashPressed;
  final VoidCallback? onOpenInMapsPressed;
  final Color primaryColor;

  const RestaurantDetailsSection({
    super.key,
    required this.storeName,
    required this.location,
    required this.status,
    required this.description,
    this.onUberEatsPressed,
    this.onGrubhubPressed,
    this.onDoorDashPressed,
    this.onOpenInMapsPressed,
    this.primaryColor = const Color(0xFF37B6AF),
  });

  @override
  State<RestaurantDetailsSection> createState() =>
      _RestaurantDetailsSectionState();
}

class _RestaurantDetailsSectionState extends State<RestaurantDetailsSection> {
  LatLng? _coordinates;

  @override
  void initState() {
    super.initState();
    _geocodeLocation();
  }

  Future<void> _geocodeLocation() async {
    try {
      // Convert the location string into latitude/longitude
      final locations = await locationFromAddress(widget.location);
      if (locations.isNotEmpty) {
        setState(() {
          _coordinates =
              LatLng(locations.first.latitude, locations.first.longitude);
        });
      } else {
        debugPrint("No coordinates found for ${widget.location}");
      }
    } catch (e) {
      debugPrint("Failed to geocode location: $e");
    }
  }

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
              CustomText(text: widget.storeName, title: true, fontSize: 18),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                      child: CustomText(text: widget.location, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.green),
                  const SizedBox(width: 6),
                  CustomText(text: widget.status, fontSize: 14),
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
                text: widget.description,
                trimLines: 3,
                readMoreColor: widget.primaryColor,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ✅ VENUE MAP using your new VenueMap widget
        if (_coordinates != null)
          VenueMap(
            latitude: _coordinates!.latitude,
            longitude: _coordinates!.longitude,
            eventName: widget.storeName,
          )
        else
          Container(
            width: double.infinity,
            height: 212,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey.shade200,
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            ),
          ),


        const SizedBox(height: 20),

        // OPEN IN MAPS BUTTON
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 12),
        //   child: CustomBtn(
        //     text: "Open in Maps",
        //     onPressed: widget.onOpenInMapsPressed,
        //   ),
        // ),
      ],
    );
  }
}
