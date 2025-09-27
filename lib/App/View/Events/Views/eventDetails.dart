import 'package:dspora/App/View/Events/Model/eventModel.dart';
import 'package:dspora/App/View/Events/widgets/eventDetails.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';



class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    // ✅ fallback image if no images available
    final List<String> imageUrls = event.images.isNotEmpty
        ? event.images.map((img) => img.url).toList()
        : [
            Images.Store,
          ];

    // Use first venue if available
    final EventVenue? venue = event.venues.isNotEmpty ? event.venues[0] : null;

    // Construct location string
    final String location = venue != null
        ? "${venue.address}, ${venue.city}, ${venue.country}"
        : "Location not available";

    return Scaffold(
      appBar: AppBar(
        title: CustomText(text: event.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Event Details with fallback images
            EventDetailWidget(
              eventName: event.name,
              rating: "N/A", // Ticketmaster events don't have ratings
              ratingsCount: "N/A",
              location: location,
              status: event.dates.statusCode == "onsale" ? "On Sale" : "Closed",
              description:
                  "Discover ${event.name} happening at ${venue?.name ?? 'Unknown Venue'}.",
              imageUrls: imageUrls,
              onReviewPressed: () {}, // optional
              onSavePressed: () {},
              onSharePressed: () {},
              onTicketPressed: () {
                if (event.url.isNotEmpty) {
                  // open ticket link
                 // launchUrl(Uri.parse(event.url));
                }
              },
              onVenueMapPressed: () {
                if (venue != null) {
                  // open maps link
                  final lat = venue.latitude;
                  final lng = venue.longitude;
                  final mapUrl =
                      "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
                //  launchUrl(Uri.parse(mapUrl));
                }
              },
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomText(
                text: "Details",
                title: true,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),

            // ✅ Event classifications
            if (event.classifications.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "No additional info.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...event.classifications.map(
                (cls) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4),
                  child: Text(
                      "${cls.segmentName} • ${cls.genreName} • ${cls.subGenreName}"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
