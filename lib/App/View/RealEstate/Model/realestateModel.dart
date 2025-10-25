import 'package:dspora/App/View/Widgets/GLOBAL/GlobalModel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "";

class RealEstateModel {
  final String id;
  final String name;
  final String address;
  final double rating;
  final bool openNow;
  final List<String> photoReferences;
  final List<GlobalReview> reviews;

  RealEstateModel({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.openNow,
    required this.photoReferences,
    required this.reviews,
  });

  factory RealEstateModel.fromJson(Map<String, dynamic> json) {
    return RealEstateModel(
      id: json['place_id'] ?? '',
      name: json['name'] ?? '',
      address: json['formatted_address'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      openNow: json['opening_hours']?['open_now'] ?? false,
      photoReferences: (json['photos'] as List?)
              ?.map((p) =>
                  "https://maps.googleapis.com/maps/api/place/photo?maxwidth=600&photoreference=${p['photo_reference']}&key=$apiKey")
              .toList() ??
          [],
      reviews: (json['reviews'] as List?)
              ?.map((r) => GlobalReview.fromJson(r))
              .toList() ??
          [],
    );
  }
}
