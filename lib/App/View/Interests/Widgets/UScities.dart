import 'package:flutter/material.dart';

class UScities {


static const Cities = [
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

}


class CitySelector extends StatelessWidget {
  final List<String> cities;
  final ValueChanged<String> onCitySelected;

  const CitySelector({
    super.key,
    required this.cities,
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        return ListTile(
          title: Text(city),
          onTap: () => onCitySelected(city),
        );
      },
    );
  }
}