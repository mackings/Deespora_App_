class SavedRestaurant {
  final String name;
  final String imageUrl;
  final String location;
  final String rating;
  final String ratingsCount;
  final DateTime savedDate;

  SavedRestaurant({
    required this.name,
    required this.imageUrl,
    required this.location,
    required this.rating,
    required this.ratingsCount,
    required this.savedDate,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'imageUrl': imageUrl,
        'location': location,
        'rating': rating,
        'ratingsCount': ratingsCount,
        'savedDate': savedDate.toIso8601String(),
      };

  factory SavedRestaurant.fromJson(Map<String, dynamic> json) =>
      SavedRestaurant(
        name: json['name'],
        imageUrl: json['imageUrl'],
        location: json['location'],
        rating: json['rating'],
        ratingsCount: json['ratingsCount'],
        savedDate: DateTime.parse(json['savedDate']),
      );
}