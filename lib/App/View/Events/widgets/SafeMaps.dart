import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';


class SafeGoogleMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String markerTitle;

  const SafeGoogleMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.markerTitle,
  });

  @override
  State<SafeGoogleMap> createState() => _SafeGoogleMapState();
}

class _SafeGoogleMapState extends State<SafeGoogleMap> {

  String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  String get _staticMapUrl {
    return 'https://maps.googleapis.com/maps/api/staticmap'
        '?center=${widget.latitude},${widget.longitude}'
        '&zoom=15'
        '&size=600x300'
        '&markers=color:red%7Clabel:A%7C${widget.latitude},${widget.longitude}'
        '&key=$_apiKey';
  }

  /// ✅ Open external maps app or browser
Future<void> _launchMapsApp() async {
  final lat = widget.latitude;
  final lng = widget.longitude;
  final title = Uri.encodeComponent(widget.markerTitle);

  final candidates = [
    // ✅ Native Google Maps URI – Android & iOS if Google Maps app is installed
    'geo:$lat,$lng?q=$lat,$lng($title)',

    // ✅ Google Maps dedicated scheme – iOS & Android
    'comgooglemaps://?q=$lat,$lng&zoom=15',

    // ✅ Apple Maps – only resolves on iOS
    'https://maps.apple.com/?ll=$lat,$lng&q=$title',

    // ✅ Always works in browser (Android/iOS/WebView)
    'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
  ];

  for (final url in candidates) {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
  }
}


  Widget _buildMapContent() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ✅ Static map image instead of WebView
        Image.network(
          _staticMapUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.map_outlined, size: 48, color: Colors.grey),
          ),
        ),

        // ✅ Open button
        Positioned(
          bottom: 12,
          right: 12,
          child: GestureDetector(
            onTap: _launchMapsApp,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.open_in_new, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                 CustomText(text: "Open",color:Colors.white,)
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 212,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _buildMapContent(),
      ),
    );
  }
}
