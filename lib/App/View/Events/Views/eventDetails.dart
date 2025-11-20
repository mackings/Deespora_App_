import 'package:dspora/App/View/Events/Model/AdsModel.dart';
import 'package:dspora/App/View/Events/Model/eventModel.dart';
import 'package:dspora/App/View/Events/widgets/WebView.dart';
import 'package:dspora/App/View/Events/widgets/eventDetails.dart';
import 'package:dspora/App/View/Interests/Model/historymodel.dart';
import 'package:dspora/App/View/Interests/Widgets/artistCard.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  final bool isFromAdvert;

  const EventDetailScreen({
    super.key,
    required this.event,
    this.isFromAdvert = false,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isLoadingCoordinates = false;
  Event? _updatedEvent;

  Future<void> _launchInAppBrowser(BuildContext context, String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open page')));
      }
    }
  }

  void _openInWebView(
    BuildContext context,
    String url, {
    String title = 'Page',
  }) {
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

    // If it's from advert and has no coordinates, try to geocode
    if (widget.isFromAdvert && _hasNoCoordinates()) {
      _geocodeLocation();
    }
  }

  bool _hasNoCoordinates() {
    final venue = widget.event.venues.isNotEmpty
        ? widget.event.venues[0]
        : null;
    return venue != null && venue.latitude == 0.0 && venue.longitude == 0.0;
  }

  Future<void> _geocodeLocation() async {
    final venue = widget.event.venues.isNotEmpty
        ? widget.event.venues[0]
        : null;
    if (venue == null) return;

    setState(() {
      _isLoadingCoordinates = true;
    });

    try {
      // Determine the best location string to use for geocoding
      String locationToGeocode = venue.address;
      if (locationToGeocode.isEmpty) {
        locationToGeocode =
            "${venue.city}${venue.country.isNotEmpty ? ', ${venue.country}' : ''}";
      }

      if (locationToGeocode.isEmpty) {
        setState(() {
          _isLoadingCoordinates = false;
        });
        return;
      }

      debugPrint('🔍 Geocoding location: $locationToGeocode');

      // Try to geocode the location
      final locations = await locationFromAddress(locationToGeocode);
      if (locations.isNotEmpty && mounted) {
        final lat = locations.first.latitude;
        final lng = locations.first.longitude;

        debugPrint('✅ Geocoding successful: $lat, $lng');

        // Get more detailed location info
        String cityName = venue.city;
        String countryName = venue.country;
        String addressStr = venue.address;

        try {
          final placemarks = await placemarkFromCoordinates(lat, lng);
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            cityName =
                place.locality ??
                place.subAdministrativeArea ??
                place.administrativeArea ??
                venue.city;
            countryName = place.country ?? venue.country;

            // Build a more detailed address
            final addressParts = [
              place.street,
              place.subLocality,
              place.locality,
              place.administrativeArea,
            ].where((e) => e != null && e.isNotEmpty).toList();

            if (addressParts.isNotEmpty) {
              addressStr = addressParts.join(', ');
            }

            debugPrint('📍 Reverse geocoded: $cityName, $countryName');
          }
        } catch (e) {
          debugPrint('⚠️ Reverse geocoding failed: $e');
        }

        // Create updated event with real coordinates
        setState(() {
          _updatedEvent = Event(
            id: widget.event.id,
            name: widget.event.name,
            type: widget.event.type,
            url: widget.event.url,
            images: widget.event.images,
            sales: widget.event.sales,
            dates: widget.event.dates,
            classifications: widget.event.classifications,
            venues: [
              EventVenue(
                name: venue.name,
                address: addressStr,
                city: cityName,
                country: countryName,
                latitude: lat,
                longitude: lng,
              ),
            ],
          );
          _isLoadingCoordinates = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Geocoding failed: $e');
      setState(() {
        _isLoadingCoordinates = false;
      });
    }
  }

  Future<void> _trackHistory() async {
    final venue = widget.event.venues.isNotEmpty
        ? widget.event.venues[0]
        : null;
    final location = venue != null
        ? "${venue.city}, ${venue.country}"
        : "Location not available";

    final historyItem = HistoryItem(
      title: widget.event.name,
      subtitle: location,
      type: 'Event',
      timestamp: DateTime.now(),
    );
    await HistoryService.addHistory(historyItem);
  }

  Future<void> _saveArtistFromEvent(BuildContext context) async {
    final artistName = widget.event.name;
    final imageUrl = widget.event.images.isNotEmpty
        ? widget.event.images[0].url
        : Images.Store;

    final venue = widget.event.venues.isNotEmpty
        ? widget.event.venues[0]
        : null;
    final location = venue != null
        ? "${venue.city}, ${venue.country}"
        : "Location not available";

    final artist = Artist(
      name: artistName,
      imageUrl: imageUrl,
      location: location,
      eventDate: widget.event.dates.start.localDate,
      eventUrl: widget.event.url,
    );

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

  /// Handle map opening for both regular events and adverts
  /// If coordinates are 0,0, it will use the location string to search
  void _openLocationMap(BuildContext context, EventVenue? venue) {
    if (venue == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Location not available')));
      return;
    }

    String mapUrl;

    // Check if we have real coordinates or need to search by location name
    if (venue.latitude != 0.0 && venue.longitude != 0.0) {
      // Use exact coordinates (either regular event or geocoded advert)
      final lat = venue.latitude;
      final lng = venue.longitude;
      mapUrl = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
      debugPrint('🗺️ Opening map with coordinates: $lat, $lng');
    } else {
      // No coordinates: Use location name/address for search
      String locationQuery = venue.address;
      if (locationQuery.isEmpty) {
        locationQuery =
            "${venue.city}${venue.country.isNotEmpty ? ', ${venue.country}' : ''}";
      }
      if (locationQuery.isEmpty) {
        locationQuery = venue.name;
      }

      final searchQuery = Uri.encodeComponent(locationQuery);
      mapUrl = "https://www.google.com/maps/search/?api=1&query=$searchQuery";

      debugPrint('🗺️ Opening map with location search: $locationQuery');
    }

    _launchInAppBrowser(context, mapUrl);
  }

  @override
  Widget build(BuildContext context) {
    // Use updated event if geocoding was successful, otherwise use original
    final displayEvent = _updatedEvent ?? widget.event;

    final List<String> imageUrls = displayEvent.images.isNotEmpty
        ? displayEvent.images.map((img) => img.url).toList()
        : [Images.Store];

    final EventVenue? venue = displayEvent.venues.isNotEmpty
        ? displayEvent.venues[0]
        : null;

    final String location = venue != null
        ? "${venue.address}${venue.city.isNotEmpty ? ', ${venue.city}' : ''}${venue.country.isNotEmpty ? ', ${venue.country}' : ''}"
        : "Location not available";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: CustomText(text: displayEvent.name),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EventDetailWidget(
              eventName: displayEvent.name,
              rating: "N/A",
              ratingsCount: "N/A",
              location: location,
              status: displayEvent.dates.statusCode == "onsale"
                  ? "On Sale"
                  : "Closed",
              description:
                  "Discover ${displayEvent.name} happening at ${venue?.name ?? 'Unknown Venue'}.",
              imageUrls: imageUrls,

              onReviewPressed: () {
                print(location);
              },
              onSavePressed: () {
                _saveArtistFromEvent(context);
              },
              onSharePressed: () {},

              // Ticket button opens ticket/website URL
              onTicketPressed: () {
                if (displayEvent.url.isNotEmpty &&
                    displayEvent.url != 'https://deespora.com') {
                  _openInWebView(
                    context,
                    displayEvent.url,
                    title: "Event Details",
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Website not available')),
                  );
                }
              },

              // Venue Map button opens Google Maps
              // If lat/lng is 0,0, it will use location string instead
              onVenueMapPressed: () {
                _openLocationMap(context, venue);
              
              },

              latitude: venue?.latitude ?? 0.0,
              longitude: venue?.longitude ?? 0.0,
            ),

            // Show loading indicator if geocoding in progress
            if (_isLoadingCoordinates)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Loading precise location...'),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomText(text: "Details", title: true, fontSize: 18),
            ),
            const SizedBox(height: 8),

            if (displayEvent.classifications.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "No additional info.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...displayEvent.classifications.map(
                (cls) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4,
                  ),
                  child: Text(
                    "${cls.segmentName} • ${cls.genreName}${cls.subGenreName.isNotEmpty ? ' • ${cls.subGenreName}' : ''}",
                  ),
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
