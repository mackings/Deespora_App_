import 'package:dspora/App/View/Restaurants/Model/ReviewModel.dart';

class Restaurant {
  final String id;
  final String name;
  final String vicinity;
  final double rating;
  final bool openNow;
  final String? photoUrl;
  final String? thumbnailUrl;
  final String? iconUrl;
  final bool? hasPhoto;
  final int? userRatingsTotal;
  final List<String> photoReferences;
  final List<Review> reviews;
  final double? distanceKm;
  final int? distanceMinutes;

  Restaurant({
    required this.id,
    required this.name,
    required this.vicinity,
    required this.rating,
    required this.openNow,
    this.photoUrl,
    this.thumbnailUrl,
    this.iconUrl,
    this.hasPhoto,
    this.userRatingsTotal,
    required this.photoReferences,
    required this.reviews,
    this.distanceKm,
    this.distanceMinutes,
  });

  static bool _isValidImageUrl(String? value) {
    if (value == null) {
      return false;
    }
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        (uri.host.isNotEmpty);
  }

  List<String> get imageUrls {
    final seen = <String>{};
    final urls = <String>[];

    for (final candidate in [
      photoUrl,
      thumbnailUrl,
      iconUrl,
      ...photoReferences,
    ]) {
      final value = candidate?.trim();
      if (_isValidImageUrl(value) && seen.add(value!)) {
        urls.add(value);
      }
    }
    return urls;
  }

  List<String> get galleryImageUrls {
    final seen = <String>{};
    final urls = <String>[];

    for (final candidate in [photoUrl, thumbnailUrl, ...photoReferences]) {
      final value = candidate?.trim();
      if (_isValidImageUrl(value) && seen.add(value!)) {
        urls.add(value);
      }
    }
    return urls;
  }

  String? get primaryImageUrl {
    return imageUrls.isNotEmpty ? imageUrls.first : null;
  }

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    final vicinity =
        (json['vicinity'] ?? json['formatted_address'] ?? json['address'] ?? '')
            .toString();
    final photos =
        (json['photos'] as List?)
            ?.map((p) {
              if (p is String) {
                return p;
              }
              if (p is Map<String, dynamic>) {
                return (p['photoUrl'] ?? p['thumbnailUrl'] ?? p['url'])
                    ?.toString();
              }
              return p?.toString();
            })
            .whereType<String>()
            .map((url) => url.trim())
            .where(_isValidImageUrl)
            .toList() ??
        <String>[];
    return Restaurant(
      id: (json['place_id'] ?? json['placeId'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      vicinity: vicinity,
      rating: (json['rating'] ?? 0).toDouble(),
      openNow:
          json['opening_hours']?['open_now'] ??
          json['open_now'] ??
          json['openNow'] ??
          false,
      photoUrl: json['photoUrl']?.toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      iconUrl: json['icon']?.toString(),
      hasPhoto: json['hasPhoto'] as bool?,
      userRatingsTotal:
          (json['user_ratings_total'] ?? json['userRatingsTotal']) as int?,
      photoReferences: photos,
      reviews:
          (json['reviews'] as List?)?.map((r) => Review.fromJson(r)).toList() ??
          [],
      distanceKm: json['distanceKm'] != null
          ? (json['distanceKm'] as num).toDouble()
          : null,
      distanceMinutes: json['distanceMinutes'] as int?,
    );
  }
}
