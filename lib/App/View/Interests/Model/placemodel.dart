import 'package:dspora/App/View/Catering/Model/cateringModel.dart';
import 'package:dspora/App/View/Events/Model/eventModel.dart';
import 'package:dspora/App/View/RealEstate/Model/realestateModel.dart';
import 'package:dspora/App/View/Restaurants/Model/ResModel.dart';

class Place {
  final String id;
  final String name;
  final String address;
  final String? imageUrl;
  final double? rating;
  final String type; // 'Restaurant', 'RealEstate', 'Catering', 'Event'
  final bool openNow;
  final List<String> photoReferences;
  
  // Add these for Event-specific data
  final String? eventDate;
  final String? eventUrl;
  final String? venueName;

  Place({
    required this.id,
    required this.name,
    required this.address,
    this.imageUrl,
    this.rating,
    required this.type,
    this.openNow = false,
    this.photoReferences = const [],
    this.eventDate,
    this.eventUrl,
    this.venueName,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'imageUrl': imageUrl,
      'rating': rating,
      'type': type,
      'openNow': openNow,
      'photoReferences': photoReferences,
      'eventDate': eventDate,
      'eventUrl': eventUrl,
      'venueName': venueName,
    };
  }

  // Create from JSON
  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      imageUrl: json['imageUrl'],
      rating: json['rating']?.toDouble(),
      type: json['type'] ?? 'Unknown',
      openNow: json['openNow'] ?? false,
      photoReferences: List<String>.from(json['photoReferences'] ?? []),
      eventDate: json['eventDate'],
      eventUrl: json['eventUrl'],
      venueName: json['venueName'],
    );
  }

  // ✅ Convert Place to Restaurant
  Restaurant toRestaurant() {
    return Restaurant(
      id: id,
      name: name,
      vicinity: address,
      rating: rating ?? 0.0,
      openNow: openNow,
      photoReferences: photoReferences,
      reviews: [],
    );
  }

  // ✅ Convert Place to RealEstateModel
  RealEstateModel toRealEstate() {
    return RealEstateModel(
      id: id,
      name: name,
      address: address,
      rating: rating ?? 0.0,
      openNow: openNow,
      photoReferences: photoReferences,
      reviews: [],
    );
  }

  // ✅ Convert Place to Catering
  Catering toCatering() {
    return Catering(
      id: id,
      name: name,
      address: address,
      rating: rating ?? 0.0,
      openNow: openNow,
      photoReferences: photoReferences,
      reviews: [],
    );
  }

  // ✅ Convert Place to Event
  Event toEvent() {
    final venue = EventVenue(
      name: venueName ?? 'Unknown Venue',
      address: address,
      city: '', // You might want to parse this from address
      country: '',
      latitude: 0.0,
      longitude: 0.0,
    );

    return Event(
      id: id,
      name: name,
      type: 'event',
      url: eventUrl ?? 'https://deespora.com',
      images: photoReferences.isNotEmpty
          ? photoReferences.map((url) => EventImage(
                url: url,
                ratio: '16_9',
                width: 1024,
                height: 576,
                fallback: false,
              )).toList()
          : [],
      sales: EventSales(
        publicSale: EventSaleDetail(
          startDateTime: '',
          endDateTime: '',
        ),
      ),
      dates: EventDates(
        start: EventDateStart(
          localDate: eventDate ?? '',
          localTime: '',
        ),
        timezone: '',
        statusCode: openNow ? 'onsale' : 'closed',
      ),
      classifications: [],
      venues: [venue],
    );
  }
}