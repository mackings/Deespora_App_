import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Filter cities by search query
    final filteredCities = widget.cities
        .where((city) => city.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 600,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.black,
                    size: 20,
                  ),
                  hintText: 'Location',
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
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredCities.length,
              itemBuilder: (context, index) {
                final city = filteredCities[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => widget.onCitySelected(city),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(right: 16),
                            child: SvgPicture.asset('assets/svg/loc.svg')
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
CustomText(text: "Location"),
                                const SizedBox(height: 2),
CustomText(text: city,)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}