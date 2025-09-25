import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBtn extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool outlined;
  final double width;
  final double height;
  final Color color;

  const CustomBtn({
    super.key,
    required this.text,
    required this.onPressed,
    this.outlined = false,
    this.width = 390,
    this.height = 60,
    this.color = const Color(0xFF37B6AF),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(12),
          border: outlined ? Border.all(color: color, width: 2) : null,
        ),
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: outlined ? color : Colors.white,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
