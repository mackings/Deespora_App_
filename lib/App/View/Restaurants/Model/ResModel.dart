 import 'package:dspora/App/View/Restaurants/Model/ReviewModel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "";


class Restaurant {
  final String id;
  final String name;
  final String vicinity;
  final double rating;
  final bool openNow;
  final List<String> photoReferences;
  final List<Review> reviews;

  Restaurant({
    required this.id,
    required this.name,
    required this.vicinity,
    required this.rating,
    required this.openNow,
    required this.photoReferences,
    required this.reviews,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['place_id'] ?? '',
      name: json['name'] ?? '',
      vicinity: json['vicinity'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      openNow: json['opening_hours']?['open_now'] ?? false,
      photoReferences: (json['photos'] as List?)
              ?.map((p) =>
                  "https://maps.googleapis.com/maps/api/place/photo?maxwidth=600&photoreference=${p['photo_reference']}&key=$apiKey")
              .toList() ??
          [],
      reviews: (json['reviews'] as List?)
              ?.map((r) => Review.fromJson(r))
              .toList() ??
          [],
    );
  }
}
