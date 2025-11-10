import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';


class FeatureHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String location;
  final VoidCallback? onBack;
  final VoidCallback? onLocationTap;
  final bool showBackButton;

  const FeatureHeader({
    super.key,
    required this.title,
    required this.location,
    this.onBack,
    this.onLocationTap,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: showBackButton, // 👈 this is the key fix
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: onBack ?? () => Navigator.pop(context),
            )
          : null,
      title: CustomText(
        text: title,
        title: true,
        fontSize: 18,
      ),
      actions: [
        GestureDetector(
          onTap: onLocationTap,
          child: Row(
            children: [
              CustomText(text: location, fontSize: 14),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, color: Colors.black),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
