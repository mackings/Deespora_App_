// city_picker.dart
import 'package:dspora/App/View/Restaurants/Widgets/cityies.dart';
import 'package:flutter/material.dart';


class CityPicker extends StatelessWidget {
  final String selectedCity;
  final ValueChanged<String> onCitySelected;

  const CityPicker({
    super.key,
    required this.selectedCity,
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Select a City',
        border: OutlineInputBorder(),
      ),
      value: selectedCity.isEmpty ? null : selectedCity,
      items: cities
          .map((c) => DropdownMenuItem(
                value: c,
                child: Text(c),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) onCitySelected(value);
      },
    );
  }
}
