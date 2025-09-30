// countries_data.dart
class Country {
  final String name;
  final String code;
  final String flag;

  Country({required this.name, required this.code, required this.flag});
}

class CountriesData {
  static List<Country> getAllCountries() {
    return [


      Country(
        name: 'United States',
        code: '+1',
        flag: 'https://flagcdn.com/w320/us.png',
      ),

      Country(
        name: 'Nigeria',
        code: '+234',
        flag: 'https://flagcdn.com/w320/ng.png',
      ),

    ];
  }
}
