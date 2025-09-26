import 'dart:convert';
import 'package:dspora/App/View/Auth/Model/country.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class CustomTextField extends StatefulWidget {
  final String title;
  final String hintText;
  final bool isPassword;
  final bool isPhone;
  final TextEditingController controller;
  final ValueChanged<String>? onCountrySelected;

  const CustomTextField({
    super.key,
    required this.title,
    required this.hintText,
    this.isPassword = false,
    this.isPhone = false,
    required this.controller,
    this.onCountrySelected,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  Country? _selectedCountry;
  List<Country> _countries = [];
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    print("🚀 initState called, isPhone: ${widget.isPhone}");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // still lazy-load on first tap
  }

  /// 👉 Modified to use CountriesData instead of API
  Future<void> _fetchCountriesDirectly() async {
    try {
      print("🌍 Loading countries from local model...");

      final list = CountriesData.getAllCountries();

      // Sort alphabetically
      list.sort((a, b) => a.name.compareTo(b.name));

      if (list.isNotEmpty) {
        setState(() {
          _countries = list;

          // Default to Nigeria if available
          _selectedCountry = _countries.firstWhere(
            (country) => country.name.toLowerCase().contains('nigeria'),
            orElse: () => _countries.first,
          );
        });

        print(
          "✅ Loaded ${list.length} countries from local model. "
          "Selected: ${_selectedCountry!.name} ${_selectedCountry!.code}",
        );
      } else {
        print("⚠️ Countries list is empty in local model");
      }
    } catch (e, stack) {
      print("❌ Exception loading countries: $e");
      print("📍 Stack trace: $stack");

      // fallback countries (same as your flow)
      setState(() {
        _countries = [
          Country(
            name: 'Nigeria',
            code: '+234',
            flag: 'https://flagcdn.com/w320/ng.png',
          ),
          Country(
            name: 'United States',
            code: '+1',
            flag: 'https://flagcdn.com/w320/us.png',
          ),
          Country(
            name: 'United Kingdom',
            code: '+44',
            flag: 'https://flagcdn.com/w320/gb.png',
          ),
          Country(
            name: 'Ghana',
            code: '+233',
            flag: 'https://flagcdn.com/w320/gh.png',
          ),
        ];
        _selectedCountry = _countries.first;
      });

      print("🔄 Using fallback countries");
    }
  }

  void _pickCountry() async {
    if (_countries.isEmpty && widget.isPhone) {
      print("🌍 Fetching countries on first tap...");
      await _fetchCountriesDirectly();
    }

    if (_countries.isEmpty) {
      print("⚠️ No countries available to pick from");
      return;
    }

    final result = await showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Country',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _countries.length,
                itemBuilder: (context, index) {
                  final country = _countries[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        country.flag,
                        width: 30,
                        height: 20,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 30,
                            height: 20,
                            color: Colors.grey[300],
                            child: const Icon(Icons.flag, size: 16),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      country.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      country.code,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    onTap: () => Navigator.pop(context, country),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() => _selectedCountry = result);
      widget.onCountrySelected?.call(result.code);
      print("🏁 Country selected: ${result.name} ${result.code}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: widget.title,
          title: true,
          content: false,
          color: Colors.black87,
          fontSize: 18,
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.isPhone
              ? TextInputType.phone
              : TextInputType.text,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.teal, width: 2),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                  )
                : null,
            prefixIcon: widget.isPhone
                ? InkWell(
                    onTap: _pickCountry,
                    child: Container(
                      width: 100,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: _selectedCountry != null
                                ? Image.network(
                                    _selectedCountry!.flag,
                                    width: 24,
                                    height: 16,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 24,
                                        height: 16,
                                        color: Colors.grey.shade300,
                                        child: const Icon(Icons.flag, size: 12),
                                      );
                                    },
                                  )
                                : Container(
                                    width: 24,
                                    height: 16,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.flag, size: 12),
                                  ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _selectedCountry?.code ?? "+--",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 20),
                        ],
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
