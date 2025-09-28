import 'package:dspora/App/View/Events/Api/eventsApi.dart';
import 'package:dspora/App/View/Events/Model/eventModel.dart';
import 'package:dspora/App/View/Events/Views/eventDetails.dart';
import 'package:dspora/App/View/Events/widgets/eventfront.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/FeatureHeader.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/LocPicker.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/images.dart';
import 'package:flutter/material.dart';

class EventHome extends StatefulWidget {
  const EventHome({super.key});

  @override
  State<EventHome> createState() => _EventHomeState();
}

class _EventHomeState extends State<EventHome> {
  final EventApiService _apiService = EventApiService();

  String _selectedCity = 'Madrid';

  // ✅ Cache for all cities
  final Map<String, List<Event>> _eventsCache = {};

  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _fetchAndCacheEvents(_selectedCity);
  }

  /// ✅ Fetch from cache first, otherwise call API
  Future<List<Event>> _fetchAndCacheEvents(String city) async {
    if (_eventsCache.containsKey(city)) {
      return _eventsCache[city]!;
    }

    final result = await _apiService.fetchAllEvents(); // You can filter by city if API supports
    _eventsCache[city] = result;
    return result;
  }

  void _loadEvents(String city) {
    setState(() {
      _selectedCity = city;
      _eventsFuture = _fetchAndCacheEvents(city);
    });
  }

  /// ✅ Force refresh (ignore cache)
  Future<void> _onRefresh() async {
    final freshData = await _apiService.fetchAllEvents();
    setState(() {
      _eventsCache[_selectedCity] = freshData;
      _eventsFuture = Future.value(freshData);
    });
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
                  cities: [
                    'Madrid','London','New York','Paris','Tokyo',
                    'Dubai','Johannesburg','Cairo','Nairobi','Toronto',
                    'Sydney','Berlin','Moscow','Rio de Janeiro',
                  ],
                  onCitySelected: (city) {
                    Navigator.pop(context);
                    _loadEvents(city);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected: $city')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),

      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            if (_eventsCache.containsKey(_selectedCity)) {
              return _buildListView(_eventsCache[_selectedCity]!);
            }
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return _buildListView(snapshot.data!);
          }

          return const Center(child: Text('No events found.'));
        },
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
          imageUrl: e.images.isNotEmpty
              ? e.images.first.url
              : Images.Store,
          eventName: e.name,
          category: e.classifications.isNotEmpty
              ? e.classifications.first.genreName
              : "Event",
          location: e.venues.isNotEmpty
              ? e.venues.first.name
              : "Unknown",
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
