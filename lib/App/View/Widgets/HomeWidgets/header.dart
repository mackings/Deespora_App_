import 'package:dspora/App/View/Widgets/HomeWidgets/homeSearch.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dspora/App/View/Utils/GooglePlaces.dart';

class HomeHeader extends StatelessWidget {
  final String name;
  final String location;
  final ValueChanged<String> onLocationSelected;

  const HomeHeader({
    super.key,
    required this.name,
    required this.location,
    required this.onLocationSelected,
  });

  String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _showLocationPicker(BuildContext context) {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    final service = GooglePlacesService(apiKey);
    final TextEditingController searchCtrl = TextEditingController();
    List<String> results = [];

    showModalBottomSheet(
      backgroundColor: Colors.white,
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
                  // 🔎 Use your custom HomeSearch widget
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: HomeSearch(
                      hintText: 'Change Location',
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
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: Colors.teal,
                          ),
                          title: CustomText(text: city),
                          onTap: () {
                            Navigator.pop(context);
                            onLocationSelected(city); // ✅ callback
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

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isSmall = w < 360;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 0 : 17.5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 👤 User Name (Left)
              Expanded(
                child: CustomText(
                  text: "Hi ${capitalizeFirst(name)}",
                  content: false,
                  title: true,
                  fontSize: 20,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => _showLocationPicker(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wb_sunny_outlined,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isSmall ? 110 : 150,
                          ),
                          child: CustomText(
                            text: location,
                            content: true,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Transform.rotate(
                          angle: 1.57,
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
