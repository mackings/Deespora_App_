import 'package:dspora/App/View/Events/Api/eventsApi.dart';
import 'package:dspora/App/View/Events/Model/eventModel.dart';
import 'package:dspora/App/View/Events/Views/eventDetails.dart';
import 'package:dspora/App/View/Events/widgets/eventfront.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureHeader.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureSearch.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/LocPicker.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';




class EventHome extends StatefulWidget {
  const EventHome({super.key});

  @override
  State<EventHome> createState() => _EventHomeState();
}

class _EventHomeState extends State<EventHome> {
  final EventApiService _apiService = EventApiService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCity = 'US';

  /// Store all events from the initial API call
  List<Event> _allEvents = [];

  /// Displayed events after filtering
  List<Event> _filteredEvents = [];

  late Future<void> _initialLoadFuture;

  final List<String> usCities = [
  "New York",
  "Los Angeles",
  "Chicago",
  "Houston",
  "Miami",
  "San Francisco",
  "Boston",
  "Washington",
  "Seattle",
  "Atlanta",
  "Las Vegas",
  "Orlando",
  "Dallas",
  "Denver",
  "Philadelphia",
  "Phoenix",
  "San Diego",
  "Austin",
  "Nashville",
  "Portland",
  "Detroit",
  "Minneapolis",
  "Charlotte",
  "Indianapolis",
  "Columbus",
  "San Antonio",
  "Tampa",
  "Baltimore",
  "Cleveland",
  "Kansas City",
];

  @override
  void initState() {
    super.initState();
    _initialLoadFuture = _fetchInitialEvents(); // fetch once
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// ✅ Fetch all events only once
  Future<void> _fetchInitialEvents() async {
    try {
      final events = await _apiService.fetchAllEvents(); // Single API call
      setState(() {
        _allEvents = events;
      });
      _applyCityFilter(_selectedCity);
    } catch (e) {
      debugPrint("❌ Error loading events: $e");
    }
  }

  /// ✅ Filter events by selected city
  void _applyCityFilter(String city) {
    final lowerCity = city.toLowerCase();

    setState(() {
      _filteredEvents = _allEvents.where((e) {
        final venueMatch = e.venues.any((v) => v.name.toLowerCase().contains(lowerCity));
        final nameMatch = e.name.toLowerCase().contains(lowerCity);
        return venueMatch || nameMatch || city == 'US';
      }).toList();
    });
  }

  /// ✅ Change city without API call
  void _loadEvents(String city) {
    setState(() {
      _selectedCity = city;
    });
    _applyCityFilter(city);
    _onSearchChanged(); // reapply any search query
  }

  /// ✅ Refresh just re-applies filters (no API call)
  Future<void> _onRefresh() async {
    _applyCityFilter(_selectedCity);
    _onSearchChanged();
  }

  /// ✅ Apply search on top of current city filter
  void _onSearchChanged() {
    final query = _searchController.text.trim();

    // If search is empty, just apply city filter
    if (query.isEmpty) {
      _applyCityFilter(_selectedCity);
      return;
    }

    // If search has 3+ characters, use API search
    if (query.length >= 3) {
      _performApiSearch(query);
    } else {
      // For short queries, filter locally
      final queryLower = query.toLowerCase();
      setState(() {
        final cityFiltered = _allEvents.where((e) {
          final venueMatch = e.venues.any((v) => v.name.toLowerCase().contains(_selectedCity.toLowerCase()));
          final nameMatch = e.name.toLowerCase().contains(_selectedCity.toLowerCase());
          return venueMatch || nameMatch || _selectedCity == 'US';
        }).toList();

        _filteredEvents = cityFiltered.where((e) {
          return e.name.toLowerCase().contains(queryLower) ||
              e.venues.any((v) => v.name.toLowerCase().contains(queryLower));
        }).toList();
      });
    }
  }

  /// New method to search events via API
  Future<void> _performApiSearch(String keyword) async {
    try {
      debugPrint('🔍 Searching events via API: $keyword in $_selectedCity');
      final results = await _apiService.searchEvents(
        keyword: keyword,
        city: _selectedCity != 'US' ? _selectedCity : null,
        size: 50,
      );

      setState(() {
        _allEvents = results;
        _filteredEvents = results;
      });

      debugPrint('✅ Found ${results.length} events');
    } catch (e) {
      debugPrint('❌ Event search error: $e');
      // Keep existing data on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FeatureHeader(
        title: "Events",
        location: _selectedCity,
        onBack: () => Navigator.pop(context),
        onLocationTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            builder: (context) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: CitySelector(
                  cities: usCities,
                  onCitySelected: (city) {
                    Navigator.pop(context);
                    _loadEvents(city);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected $city')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      body: Column(
        children: [
          // ✅ Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FeatureSearch(
              controller: _searchController,
              hintText: 'Search Events',
              onChanged: (value) => _onSearchChanged(),
            ),
          ),
          Expanded(
            child: FutureBuilder<void>(
              future: _initialLoadFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.teal),
                  );
                }

                if (snapshot.hasError) {
                   return Center(child: CustomText(text: "Network Error, Please retry"));
                 // return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (_filteredEvents.isNotEmpty) {
                  return _buildListView(_filteredEvents);
                }

                return const Center(child: CustomText(text: "No events found"));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Event> events) {
    return RefreshIndicator(
      color: Colors.teal,
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final e = events[index];
          return EventFront(
            imageUrl: e.images.isNotEmpty ? e.images.first.url : Images.Store,
            eventName: e.name,
            category: e.classifications.isNotEmpty
                ? e.classifications.first.genreName
                : "Event",
            location: e.venues.isNotEmpty ? e.venues.first.name : "Unknown",
            date: e.dates.start.localDate,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailScreen(event: e),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
