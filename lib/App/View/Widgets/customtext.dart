import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class CustomText extends StatelessWidget {
  final String text;
  final bool title;
  final bool content;
  final TextAlign textAlign;
  final Color? color;
  final double? fontSize;
  final bool underline;

  // ✅ New props for shortening
  final bool shorten;
  final int maxLength;

  const CustomText({
    super.key,
    required this.text,
    this.title = false,
    this.content = false,
    this.textAlign = TextAlign.start,
    this.color,
    this.fontSize,
    this.underline = false,

    // ✅ Defaults
    this.shorten = false,
    this.maxLength = 50,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Apply shortening
    final displayText = (shorten && text.length > maxLength)
        ? '${text.substring(0, maxLength)}…'
        : text;

    TextStyle style;

    if (title) {
      style = GoogleFonts.plusJakartaSans(
        fontSize: fontSize ?? 30,
        fontWeight: FontWeight.w700,
        color: color ?? const Color(0xFF151515),
        height: 1.14,
        decoration: underline ? TextDecoration.underline : TextDecoration.none,
      );
    } else if (content) {
      style = GoogleFonts.plusJakartaSans(
        fontSize: fontSize ?? 14,
        fontWeight: FontWeight.w400,
        color: color ?? const Color(0xFF404040),
        height: 1.5,
        decoration: underline ? TextDecoration.underline : TextDecoration.none,
      );
    } else {
      style = GoogleFonts.plusJakartaSans(
        fontSize: fontSize ?? 16,
        fontWeight: FontWeight.w500,
        color: color ?? Colors.black,
        height: 1.4,
        decoration: underline ? TextDecoration.underline : TextDecoration.none,
      );
    }

    return Text(displayText, textAlign: textAlign, style: style);
  }
}
