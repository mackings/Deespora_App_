class Review {
  final String authorName;
  final String profilePhotoUrl;
  final double rating;
  final String text;
  final String relativeTime;

  Review({
    required this.authorName,
    required this.profilePhotoUrl,
    required this.rating,
    required this.text,
    required this.relativeTime,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      authorName: (json['author_name'] ?? json['authorName'] ?? '').toString(),
      profilePhotoUrl:
          (json['profile_photo_url'] ?? json['profilePhotoUrl'] ?? '')
              .toString(),
      rating: (json['rating'] ?? 0).toDouble(),
      text: (json['text'] ?? '').toString(),
      relativeTime:
          (json['relative_time_description'] ??
                  json['relativeTimeDescription'] ??
                  json['relativeTime'] ??
                  '')
              .toString(),
    );
  }
}
