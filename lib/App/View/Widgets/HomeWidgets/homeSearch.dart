
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class HomeSearch extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const HomeSearch({
    super.key,
    this.hintText = 'Search Deespora',
    this.controller,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: MediaQuery.of(context).size.width - 35,
      height: 55,
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF8F8F8),
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: Colors.black
          ),
          hintText: hintText,
          hintStyle: GoogleFonts.plusJakartaSans(),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(
          color: Color(0xFF151515),
          fontSize: 14,
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
    );
  }
}