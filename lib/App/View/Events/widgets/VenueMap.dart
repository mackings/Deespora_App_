import 'package:dspora/App/View/Events/widgets/SafeMaps.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';


class VenueMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String eventName;

  const VenueMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.eventName,
  });

  @override
  State<VenueMap> createState() => _VenueMapState();
}

class _VenueMapState extends State<VenueMap> {
  bool _permissionGranted = false;
  bool _loading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    debugPrint("🎯 VenueMap initState called");
    _initPermission();
  }

  Future<void> _initPermission() async {
    try {
      debugPrint("📍 Starting location permission check...");
      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint("📍 Location service enabled: $serviceEnabled");
      
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint("📍 Current permission status: $permission");
      
      setState(() {
        _permissionGranted = permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always;
        _loading = false;
      });
      
      debugPrint("📍 Permission flow completed. Granted: $_permissionGranted");
      
    } catch (e, stackTrace) {
      debugPrint("❌ Permission error: $e");
      setState(() {
        _loading = false;
        _permissionGranted = false;
        _errorMessage = "Error: ${e.toString()}";
      });
    }
  }

  Widget _buildPlaceholder(String message, {bool isError = false}) {
    return Container(
      height: 212,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade200,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.location_on,
                color: Colors.grey,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  color: isError ? Colors.red : Colors.grey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("🔨 Building VenueMap widget - Loading: $_loading, Permission: $_permissionGranted");
    
    if (_loading) {
      return _buildPlaceholder("Loading map...");
    }

    if (!_permissionGranted) {
      return _buildPlaceholder(
        _errorMessage.isNotEmpty ? _errorMessage : "Location permission required",
        isError: true,
      );
    }

    debugPrint("🚀 Attempting to render GoogleMap...");
    
    return Container(
      height: 212,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade200,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SafeGoogleMap(
          latitude: widget.latitude,
          longitude: widget.longitude,
          markerTitle: widget.eventName,
        ),
      ),
    );
  }
}