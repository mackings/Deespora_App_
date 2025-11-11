class Place {
  final String name;
  final String address;
  final String? imageUrl;
  final double? rating;

  Place({
    required this.name,
    required this.address,
    this.imageUrl,
    this.rating,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'imageUrl': imageUrl,
      'rating': rating,
    };
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'],
      address: json['address'],
      imageUrl: json['imageUrl'],
      rating: json['rating']?.toDouble(),
    );
  }
}