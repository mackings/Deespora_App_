import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';


class LocationPicker extends StatefulWidget {
  final LatLng initialPosition;
  final void Function(LatLng position, String address) onLocationSelected;

  const LocationPicker({
    super.key,
    required this.initialPosition,
    required this.onLocationSelected,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late GoogleMapController _mapController;
  LatLng _selectedPosition = const LatLng(40.7128, -74.0060);
  String _address = 'Select a location';
  final TextEditingController _searchController = TextEditingController();
  List<Location> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
    _getAddressFromLatLng(_selectedPosition);
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _address = '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
        });
      }
    } catch (e) {
      setState(() {
        _address = 'Unable to fetch address';
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final locations = await locationFromAddress(query);
      setState(() {
        _searchResults = locations.take(5).toList(); // Limit to 5 results
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  Future<String> _getAddressFromLocation(Location location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude, 
        location.longitude
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}';
      }
    } catch (e) {
      // Handle error
    }
    return 'Unknown location';
  }

  void _onLocationSelected(Location location) async {
    final latLng = LatLng(location.latitude, location.longitude);
    final address = await _getAddressFromLocation(location);
    
    setState(() {
      _selectedPosition = latLng;
      _address = address;
      _searchResults = [];
      _searchController.clear();
    });

    // Move camera to selected location
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(latLng, 15),
    );

    widget.onLocationSelected(latLng, address);
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _searchResults = [];
      _searchController.clear();
    });
    _getAddressFromLatLng(position);
    widget.onLocationSelected(position, _address);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search location...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  _searchLocation(value);
                },
              ),
            ),
          ),

          // Search results or map
          Expanded(
            child: _searchResults.isNotEmpty || _isSearching
                ? _buildSearchResults()
                : _buildMap(),
          ),

          // Selected location info
          if (_searchResults.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Location',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _address,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onLocationSelected(_selectedPosition, _address);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Confirm Location'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final location = _searchResults[index];
        return FutureBuilder<String>(
          future: _getAddressFromLocation(location),
          builder: (context, snapshot) {
            final address = snapshot.data ?? 'Loading...';
            return ListTile(
              leading: const Icon(
                Icons.location_on,
                color: Colors.grey,
              ),
              title: const Text(
                'Location',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                address,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              onTap: () => _onLocationSelected(location),
            );
          },
        );
      },
    );
  }

Widget _buildMap() {
  return GoogleMap(
    initialCameraPosition: CameraPosition(
      target: _selectedPosition,
      zoom: 5,
    ),
    onMapCreated: (controller) => _mapController = controller,

    // 👇 this lets you pick a spot on the map
    onTap: (pos) {
      setState(() {
        _selectedPosition = pos;
        // Optionally, you can perform reverse-geocoding here if needed
      });

      // Move camera and update marker
      _mapController.animateCamera(CameraUpdate.newLatLngZoom(pos, 8));
    },

    markers: {
      Marker(
        markerId: const MarkerId('selected'),
        position: _selectedPosition,
      ),
    },
  );
}


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
