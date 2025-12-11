import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class CitySelector extends StatefulWidget {
  final List<String> cities;
  final void Function(String) onCitySelected;

  const CitySelector({
    Key? key,
    required this.cities,
    required this.onCitySelected,
  }) : super(key: key);

  @override
  _CitySelectorState createState() => _CitySelectorState();
}

class _CitySelectorState extends State<CitySelector> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter cities by search query
    final filteredCities = widget.cities
        .where((city) => city.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Field
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 20,
                      ),
                      hintText: 'Change Location',
                      hintStyle: GoogleFonts.plusJakartaSans(),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    onChanged: (value) {
                      setState(() => searchQuery = value);
                    },
                  ),
                ),
              ),
          
              // Cities List
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: filteredCities.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final city = filteredCities[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.location_on_outlined,
                        color: Colors.teal,
                      ),
                      title: CustomText(text: city),
                      onTap: () {
                       // Navigator.pop(context);
                        widget.onCitySelected(city);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Usage example:
void showCitySelector(BuildContext context, List<String> cities) {
  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return CitySelector(
        cities: cities,
        onCitySelected: (city) {
          // Handle city selection
          print('Selected city: $city');
        },
      );
    },
  );
}