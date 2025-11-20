import 'package:dspora/App/View/Events/Model/eventModel.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';


class Advert {
  final String id;
  final String title;
  final String description;
  final AdvertCategory category;
  final String location;
  final String contactPhone;
  final String websiteUrl;
  final DateTime eventDate;
  final List<String> images;
  final bool promoted;
  final PromotionDetails? promotionDetails;
  final bool status;
  final CreatedBy createdBy;
  final DateTime createdAt;

  Advert({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.contactPhone,
    required this.websiteUrl,
    required this.eventDate,
    required this.images,
    required this.promoted,
    this.promotionDetails,
    required this.status,
    required this.createdBy,
    required this.createdAt,
  });

  factory Advert.fromJson(Map<String, dynamic> json) {
    return Advert(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: AdvertCategory.fromJson(json['category'] ?? {}),
      location: json['location'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      websiteUrl: json['websiteUrl'] ?? '',
      eventDate: DateTime.parse(json['eventDate'] ?? DateTime.now().toIso8601String()),
      images: List<String>.from(json['images'] ?? []),
      promoted: json['promoted'] ?? false,
      promotionDetails: json['promotionDetails'] != null
          ? PromotionDetails.fromJson(json['promotionDetails'])
          : null,
      status: json['status'] ?? false,
      createdBy: CreatedBy.fromJson(json['createdBy'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Convert Advert to Event with geocoded coordinates
  /// This method fetches real coordinates for the location
  Future<Event> toEventWithCoordinates() async {
    double lat = 0.0;
    double lng = 0.0;
    String cityName = '';
    String countryName = '';
    String addressStr = location;

    // Try to geocode the location to get real coordinates
    if (location.isNotEmpty) {
      try {
        debugPrint('🔍 Geocoding location: $location');
        final locations = await locationFromAddress(location);
        if (locations.isNotEmpty) {
          lat = locations.first.latitude;
          lng = locations.first.longitude;
          debugPrint('✅ Geocoding successful: $lat, $lng');
          
          // Get more detailed location info
          try {
            final placemarks = await placemarkFromCoordinates(lat, lng);
            if (placemarks.isNotEmpty) {
              final place = placemarks.first;
              cityName = place.locality ?? 
                        place.subAdministrativeArea ?? 
                        place.administrativeArea ?? 
                        '';
              countryName = place.country ?? '';
              
              // Build a more detailed address
              addressStr = [
                place.street,
                place.subLocality,
                place.locality,
                place.administrativeArea,
                place.country,
              ].where((e) => e != null && e.isNotEmpty).join(', ');
              
              debugPrint('📍 Reverse geocoded: $cityName, $countryName');
            }
          } catch (e) {
            debugPrint('⚠️ Reverse geocoding failed: $e');
            // Parse location string as fallback
            _parseLocationString(location, (city, country) {
              cityName = city;
              countryName = country;
            });
          }
        }
      } catch (e) {
        debugPrint('❌ Geocoding failed for "$location": $e');
        // Fallback: parse location string
        _parseLocationString(location, (city, country) {
          cityName = city;
          countryName = country;
          addressStr = location;
        });
      }
    }

    // Prepare image list - ensure we have multiple images
    List<EventImage> eventImages = _prepareImages();

    return Event(
      id: id,
      name: title,
      type: category.name,
      url: websiteUrl.isNotEmpty ? websiteUrl : 'https://deespora.com',
      images: eventImages,
      sales: EventSales(
        publicSale: EventSaleDetail(
          startDateTime: eventDate.toIso8601String(),
          endDateTime: eventDate.add(Duration(days: 1)).toIso8601String(),
        ),
      ),
      dates: EventDates(
        start: EventDateStart(
          localDate: eventDate.toString().split(' ')[0],
          localTime: eventDate.toString().split(' ')[1].substring(0, 5),
        ),
        timezone: 'UTC',
        statusCode: 'onsale',
      ),
      classifications: [
        EventClassification(
          segmentName: category.name,
          genreName: category.name,
          subGenreName: description.length > 50 
              ? description.substring(0, 50) + '...'
              : description,
        ),
      ],
      venues: [
        EventVenue(
          name: title,
          address: addressStr,
          city: cityName.isNotEmpty ? cityName : location,
          country: countryName,
          latitude: lat,
          longitude: lng,
        ),
      ],
    );
  }

  /// Quick synchronous conversion (coordinates will be 0,0 until geocoded)
  /// Use this for immediate UI display, then update with toEventWithCoordinates
  Event toEvent() {
    String cityName = '';
    String countryName = '';
    
    // Simple location parsing
    _parseLocationString(location, (city, country) {
      cityName = city;
      countryName = country;
    });

    // Prepare multiple images
    List<EventImage> eventImages = _prepareImages();

    return Event(
      id: id,
      name: title,
      type: category.name,
      url: websiteUrl.isNotEmpty ? websiteUrl : 'https://deespora.com',
      images: eventImages,
      sales: EventSales(
        publicSale: EventSaleDetail(
          startDateTime: eventDate.toIso8601String(),
          endDateTime: eventDate.add(Duration(days: 1)).toIso8601String(),
        ),
      ),
      dates: EventDates(
        start: EventDateStart(
          localDate: eventDate.toString().split(' ')[0],
          localTime: eventDate.toString().split(' ')[1].substring(0, 5),
        ),
        timezone: 'UTC',
        statusCode: 'onsale',
      ),
      classifications: [
        EventClassification(
          segmentName: category.name,
          genreName: category.name,
          subGenreName: description.length > 50 
              ? description.substring(0, 50) + '...'
              : description,
        ),
      ],
      venues: [
        EventVenue(
          name: title,
          address: location,
          city: cityName.isNotEmpty ? cityName : location,
          country: countryName,
          latitude: 0.0,  // Will be geocoded in EventDetailScreen
          longitude: 0.0,
        ),
      ],
    );
  }

  /// Helper to parse location string into city and country
  void _parseLocationString(String loc, Function(String city, String country) callback) {
    if (loc.contains(',')) {
      final parts = loc.split(',').map((e) => e.trim()).toList();
      if (parts.length >= 2) {
        callback(parts[0], parts.last);
      } else {
        callback(parts[0], '');
      }
    } else {
      callback(loc, '');
    }
  }

  /// Helper to prepare image list
  List<EventImage> _prepareImages() {
    List<EventImage> eventImages = [];
    if (images.isNotEmpty) {
      for (String imageUrl in images) {
        eventImages.add(EventImage(
          url: imageUrl,
          ratio: '16_9',
          width: 1000,
          height: 600,
          fallback: false,
        ));
      }
    } else {
      // Fallback placeholder
      eventImages.add(EventImage(
        url: 'https://via.placeholder.com/1000x600',
        ratio: '16_9',
        width: 1000,
        height: 600,
        fallback: true,
      ));
    }
    return eventImages;
  }
}

class AdvertCategory {
  final String id;
  final String name;
  final String slug;

  AdvertCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory AdvertCategory.fromJson(Map<String, dynamic> json) {
    return AdvertCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}

class PromotionDetails {
  final bool onHomepage;
  final bool inNewsletter;
  final bool trendingBadge;
  final String duration;
  final DateTime startDate;
  final DateTime endDate;

  PromotionDetails({
    required this.onHomepage,
    required this.inNewsletter,
    required this.trendingBadge,
    required this.duration,
    required this.startDate,
    required this.endDate,
  });

  factory PromotionDetails.fromJson(Map<String, dynamic> json) {
    return PromotionDetails(
      onHomepage: json['onHomepage'] ?? false,
      inNewsletter: json['inNewsletter'] ?? false,
      trendingBadge: json['trendingBadge'] ?? false,
      duration: json['duration'] ?? '',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class CreatedBy {
  final String id;
  final String firstName;
  final String email;

  CreatedBy({
    required this.id,
    required this.firstName,
    required this.email,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    return CreatedBy(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      email: json['email'] ?? '',
    );
  }
}