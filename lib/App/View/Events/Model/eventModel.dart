import 'dart:convert';



class Event {
  final String id;
  final String name;
  final String type;
  final String url;
  final List<EventImage> images;
  final EventSales sales;
  final EventDates dates;
  final List<EventClassification> classifications;
  final List<EventVenue> venues;

  Event({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.images,
    required this.sales,
    required this.dates,
    required this.classifications,
    required this.venues,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        type: json['type'] ?? '',
        url: json['url'] ?? '',
        images: json['images'] != null
            ? List<EventImage>.from(
                json['images'].map((x) => EventImage.fromJson(x)))
            : [],
        sales: EventSales.fromJson(json['sales'] ?? {}),
        dates: EventDates.fromJson(json['dates'] ?? {}),
        classifications: json['classifications'] != null
            ? List<EventClassification>.from(
                json['classifications']
                    .map((x) => EventClassification.fromJson(x)))
            : [],
        venues: json['_embedded'] != null &&
                json['_embedded']['venues'] != null
            ? List<EventVenue>.from(
                json['_embedded']['venues']
                    .map((x) => EventVenue.fromJson(x)))
            : [],
      );
}

class EventImage {
  final String url;
  final String ratio;
  final int width;
  final int height;
  final bool fallback;

  EventImage({
    required this.url,
    required this.ratio,
    required this.width,
    required this.height,
    required this.fallback,
  });

  factory EventImage.fromJson(Map<String, dynamic> json) => EventImage(
        url: json['url'] ?? '',
        ratio: json['ratio'] ?? '',
        width: json['width'] ?? 0,
        height: json['height'] ?? 0,
        fallback: json['fallback'] ?? false,
      );
}

class EventSales {
  final EventSaleDetail publicSale;

  EventSales({required this.publicSale});

  factory EventSales.fromJson(Map<String, dynamic> json) => EventSales(
        publicSale:
            EventSaleDetail.fromJson(json['public'] ?? {}),
      );
}

class EventSaleDetail {
  final String startDateTime;
  final String endDateTime;

  EventSaleDetail({required this.startDateTime, required this.endDateTime});

  factory EventSaleDetail.fromJson(Map<String, dynamic> json) => EventSaleDetail(
        startDateTime: json['startDateTime'] ?? '',
        endDateTime: json['endDateTime'] ?? '',
      );
}

class EventDates {
  final EventDateStart start;
  final String timezone;
  final String statusCode;

  EventDates({
    required this.start,
    required this.timezone,
    required this.statusCode,
  });

  factory EventDates.fromJson(Map<String, dynamic> json) => EventDates(
        start: EventDateStart.fromJson(json['start'] ?? {}),
        timezone: json['timezone'] ?? '',
        statusCode: json['status']?['code'] ?? '',
      );
}

class EventDateStart {
  final String localDate;
  final String localTime;

  EventDateStart({required this.localDate, required this.localTime});

  factory EventDateStart.fromJson(Map<String, dynamic> json) => EventDateStart(
        localDate: json['localDate'] ?? '',
        localTime: json['localTime'] ?? '',
      );
}

class EventClassification {
  final String segmentName;
  final String genreName;
  final String subGenreName;

  EventClassification({
    required this.segmentName,
    required this.genreName,
    required this.subGenreName,
  });

  factory EventClassification.fromJson(Map<String, dynamic> json) =>
      EventClassification(
        segmentName: json['segment']?['name'] ?? '',
        genreName: json['genre']?['name'] ?? '',
        subGenreName: json['subGenre']?['name'] ?? '',
      );
}

class EventVenue {
  final String name;
  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;

  EventVenue({
    required this.name,
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory EventVenue.fromJson(Map<String, dynamic> json) => EventVenue(
        name: json['name'] ?? '',
        address: json['address']?['line1'] ?? '',
        city: json['city']?['name'] ?? '',
        country: json['country']?['name'] ?? '',
        latitude: double.tryParse(json['location']?['latitude'] ?? '0') ?? 0,
        longitude: double.tryParse(json['location']?['longitude'] ?? '0') ?? 0,
      );
}

// Helper to parse list of events from API
List<Event> parseEvents(String responseBody) {
  final data = json.decode(responseBody);
  if (data['success'] == true && data['data'] != null) {
    return List<Event>.from(
        data['data'].map((eventJson) => Event.fromJson(eventJson)));
  }
  return [];
}

