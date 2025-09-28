import 'package:dspora/App/View/Utils/GooglePlaces.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/homeSearch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

 final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "";

void _showLocationPicker(
  BuildContext context, {
  required ValueChanged<String> onLocationSelected,
}) {
  final service = GooglePlacesService(apiKey);
  final TextEditingController searchCtrl = TextEditingController();
  List<String> results = [];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔎 Use your custom search field here
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: HomeSearch(
                    hintText: 'Search city...',
                    controller: searchCtrl,
                    onChanged: (value) async {
                      if (value.isNotEmpty) {
                        final cities = await service.fetchCities(value);
                        setState(() => results = cities);
                      } else {
                        setState(() => results = []);
                      }
                    },
                  ),
                ),

                // 📍 Results list
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final city = results[index];
                      return ListTile(
                        leading: const Icon(Icons.location_on_outlined, color: Colors.teal),
                        title: Text(city),
                        onTap: () {
                          Navigator.pop(context);
                          onLocationSelected(city); // ✅ callback to parent
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}


