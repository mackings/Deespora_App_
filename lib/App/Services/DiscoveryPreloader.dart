import 'package:dspora/App/Services/AppLocationService.dart';
import 'package:dspora/App/View/Catering/Api/cateringService.dart';
import 'package:dspora/App/View/Events/Api/AdsService.dart';
import 'package:dspora/App/View/Events/Api/eventsApi.dart';
import 'package:dspora/App/View/Events/Model/AdsModel.dart';
import 'package:dspora/App/View/Events/Model/eventModel.dart';
import 'package:dspora/App/View/RealEstate/Api/realestateService.dart';
import 'package:dspora/App/View/Restaurants/Api/ResService.dart';
import 'package:flutter/material.dart';

class DiscoveryPreloader {
  DiscoveryPreloader._();

  static final ApiService _restaurantService = ApiService();
  static final CateringService _cateringService = CateringService();
  static final WorshipService _worshipService = WorshipService();
  static final EventApiService _eventService = EventApiService();
  static final AdvertApiService _advertService = AdvertApiService();

  static Future<void>? _warmUpFuture;
  static Future<List<Event>>? _eventsFuture;
  static Future<List<Advert>>? _advertsFuture;

  static Future<void> warmUp() {
    return _warmUpFuture ??= _runWarmUp();
  }

  static Future<List<Event>> getEvents({bool forceRefresh = false}) {
    if (forceRefresh || _eventsFuture == null) {
      _eventsFuture = _eventService.fetchAllEvents();
    }
    return _eventsFuture!;
  }

  static Future<List<Advert>> getAdverts({
    int limit = 50,
    bool forceRefresh = false,
  }) {
    if (forceRefresh || _advertsFuture == null) {
      _advertsFuture = _advertService.fetchAllAdverts(limit: limit);
    }
    return _advertsFuture!;
  }

  static Future<void> _runWarmUp() async {
    final location = await AppLocationService.getActiveLocation();
    final futures = <Future<dynamic>>[
      _restaurantService.fetchRestaurants(city: location.city),
      _cateringService.fetchCaterings(city: location.city),
      _worshipService.fetchWorship(city: location.city),
      getEvents(),
      getAdverts(),
    ];

    if (!location.isUserSelected && location.hasCoordinates) {
      futures.add(_warmLocationBasedDiscovery(location));
    }

    await Future.wait(futures.map(_ignoreErrors));
  }

  static Future<void> _warmLocationBasedDiscovery(
    AppLocationData location,
  ) async {
    final restaurants = await _restaurantService.fetchRestaurants(
      lat: location.lat!,
      lng: location.lng!,
    );

    final futures = <Future<dynamic>>[
      _cateringService.fetchCaterings(lat: location.lat!, lng: location.lng!),
      _worshipService.fetchWorship(lat: location.lat!, lng: location.lng!),
    ];

    if (restaurants.isEmpty) {
      futures.add(
        _restaurantService.fetchNearbyRestaurants(
          lat: location.lat!,
          lng: location.lng!,
        ),
      );
    }

    await Future.wait(futures.map(_ignoreErrors));
  }

  static Future<void> _ignoreErrors(Future<dynamic> future) async {
    try {
      await future;
    } catch (e) {
      debugPrint('⚠️ Discovery preload request failed: $e');
    }
  }
}
