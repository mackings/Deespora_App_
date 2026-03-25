class NotificationsFeed {
  final DateTime? generatedAt;
  final List<NotificationItem> events;
  final List<NotificationItem> restaurants;
  final List<NotificationItem> catering;
  final List<NotificationItem> notifications;

  const NotificationsFeed({
    required this.generatedAt,
    required this.events,
    required this.restaurants,
    required this.catering,
    required this.notifications,
  });

  factory NotificationsFeed.empty() {
    return const NotificationsFeed(
      generatedAt: null,
      events: [],
      restaurants: [],
      catering: [],
      notifications: [],
    );
  }

  bool get isEmpty =>
      events.isEmpty &&
      restaurants.isEmpty &&
      catering.isEmpty &&
      notifications.isEmpty;

  factory NotificationsFeed.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};

    List<NotificationItem> parseItems(String key) {
      final value = data[key];
      if (value is! List) {
        return const [];
      }
      return value
          .whereType<Map<String, dynamic>>()
          .map(NotificationItem.fromJson)
          .toList();
    }

    return NotificationsFeed(
      generatedAt: DateTime.tryParse((data['generatedAt'] ?? '').toString()),
      events: parseItems('events'),
      restaurants: parseItems('restaurants'),
      catering: parseItems('catering'),
      notifications: parseItems('notifications'),
    );
  }
}

class NotificationItem {
  final String id;
  final String type;
  final String title;
  final String message;
  final String? imageUrl;
  final String? url;
  final String? eventDate;
  final String? venue;
  final String? source;
  final double? rating;
  final int? reviewCount;
  final int? latestReviewAt;
  final String? location;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.imageUrl,
    this.url,
    this.eventDate,
    this.venue,
    this.source,
    this.rating,
    this.reviewCount,
    this.latestReviewAt,
    this.location,
  });

  bool get isEvent => source == 'events';
  bool get isRestaurant => source == 'restaurant';
  bool get isCatering => source == 'catering';

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      imageUrl: json['imageUrl']?.toString(),
      url: json['url']?.toString(),
      eventDate: json['eventDate']?.toString(),
      venue: json['venue']?.toString(),
      source: json['source']?.toString(),
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,
      reviewCount: json['reviewCount'] as int?,
      latestReviewAt: json['latestReviewAt'] as int?,
      location: json['location']?.toString(),
    );
  }
}
