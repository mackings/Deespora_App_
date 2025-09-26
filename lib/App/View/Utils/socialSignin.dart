import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialSigninButton extends StatelessWidget {
  final String text;
  final String svgAsset;
  final double width;
  final double height;
  final VoidCallback? onPressed;

  const SocialSigninButton({
    super.key,
    required this.text,
    required this.svgAsset,
    this.width = 328,
    this.height = 70,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFFC7C5CC), // Grey-300
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            // SVG icon
            SizedBox(
              width: 40,
              height: 40,
              child: SvgPicture.asset(svgAsset, fit: BoxFit.contain),
            ),

            const SizedBox(width: 12),

            // CustomText
            Expanded(
              child: CustomText(
                text: text,
                content: true,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
