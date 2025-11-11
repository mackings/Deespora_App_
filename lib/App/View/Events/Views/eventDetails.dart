import 'package:dspora/App/View/Events/Model/eventModel.dart';
import 'package:dspora/App/View/Events/widgets/WebView.dart';
import 'package:dspora/App/View/Events/widgets/eventDetails.dart';
import 'package:dspora/App/View/Interests/Model/historymodel.dart';
import 'package:dspora/App/View/Interests/Widgets/artistCard.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';




class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {


Future<void> _launchInAppBrowser(BuildContext context, String url) async {
  final uri = Uri.parse(url);      

  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,                          
      mode: LaunchMode.inAppBrowserView, 
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open ticket page')),
    );
  }
}

void _openInWebView(BuildContext context, String url, {String title = 'Page'}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => WebViewScreen(url: url, title: title),
    ),
  );
}

@override
void initState() {
  super.initState();
  _trackHistory();
}

Future<void> _trackHistory() async {
  final venue = widget.event.venues.isNotEmpty ? widget.event.venues[0] : null;
  final location = venue != null ? "${venue.city}, ${venue.country}" : "Location not available";
  
  final historyItem = HistoryItem(
    title:widget.event.name,
    subtitle: location,
    type: 'Event',
    timestamp: DateTime.now(),
  );
  await HistoryService.addHistory(historyItem);
}

// Add this method to your EventDetailScreen class
Future<void> _saveArtistFromEvent(BuildContext context) async {

  final artistName = widget.event.name;
  final imageUrl = widget.event.images.isNotEmpty 
      ? widget.event.images[0].url 
      : Images.Store;
  
  // Get venue info
  final venue = widget.event.venues.isNotEmpty ? widget.event.venues[0] : null;
  final location = venue != null
      ? "${venue.city}, ${venue.country}"
      : "Location not available";
  
  // Create Artist object
  final artist = Artist(
    name: artistName,
    imageUrl: imageUrl,
    location: location,
    eventDate: widget.event.dates.start.localDate,
    eventUrl: widget.event.url,
  );
  
  // Save to SharedPreferences
  final success = await ArtistPreferencesService.saveArtist(artist);
  
  if (success && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$artistName saved to your interests!'),
        backgroundColor: Colors.green,
      ),
    );
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Artist already saved or error occurred'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    // ✅ fallback image if no images available
    final List<String> imageUrls = widget.event.images.isNotEmpty
        ? widget.event.images.map((img) => img.url).toList()
        : [Images.Store];

    // Use first venue if available
    final EventVenue? venue = widget.event.venues.isNotEmpty ? widget.event.venues[0] : null;

    // Construct location string
    final String location = venue != null
        ? "${venue.address}, ${venue.city}, ${venue.country}"
        : "Location not available";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: CustomText(text: widget.event.name,),backgroundColor: Colors.white,),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            
            EventDetailWidget(
              eventName: widget.event.name,
              rating: "N/A", // Ticketmaster events don't have ratings
              ratingsCount: "N/A",
              location: location,
              status: widget.event.dates.statusCode == "onsale" ? "On Sale" : "Closed",
              description:
                  "Discover ${widget.event.name} happening at ${venue?.name ?? 'Unknown Venue'}.",
              imageUrls: imageUrls,

              // 👇 Button actions
              onReviewPressed: () {},
              onSavePressed: () {
                 _saveArtistFromEvent(context);
              },
              onSharePressed: () {},
              onTicketPressed: () {
               if (venue != null) {
                  final lat = venue.latitude;
                  final lng = venue.longitude;
                  final mapUrl =
                      "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
                  _launchInAppBrowser(context, mapUrl);
                }
              },
onVenueMapPressed: () {
  if (widget.event.url.isNotEmpty) {
    _openInWebView(context, widget.event.url, title: "Event Tickets");
  }
},

              // ✅ Pass lat/lng to widget if required
              latitude: venue?.latitude ?? 0.0,
              longitude: venue?.longitude ?? 0.0,
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomText(text: "Details", title: true, fontSize: 18),
            ),
            const SizedBox(height: 8),

            // ✅ Event classifications
            if (widget.event.classifications.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "No additional info.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...widget.event.classifications.map(
                (cls) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4,
                  ),
                  child: Text(
                    "${cls.segmentName} • ${cls.genreName} • ${cls.subGenreName}",
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}