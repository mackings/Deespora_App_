import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class BottomNavItem {
  final String label;
  final String iconAsset; // path to SVG icon
  final VoidCallback onTap;

  BottomNavItem({
    required this.label,
    required this.iconAsset,
    required this.onTap,
  });
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<BottomNavItem> items;
  final Color activeColor;
  final Color inactiveColor;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.items,
    this.activeColor = const Color(0xFF37B6AF),
    this.inactiveColor = const Color(0xFF404040),
  });

  @override
  Widget build(BuildContext context) {
    // Get the bottom padding (safe area inset for home indicator)
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      color: Colors.white, // White background extending to the very bottom
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 84,
            margin: const EdgeInsets.symmetric(horizontal: 16), // Add side margins if needed
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 32,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isActive = index == selectedIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: item.onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 3.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isActive ? activeColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              item.iconAsset,
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                isActive ? Colors.white : inactiveColor,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(height: 4),
                            CustomText(
                              text: item.label,
                              content: true,
                              color: isActive ? Colors.white : inactiveColor,
                              fontSize: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          // White space that extends to the bottom of the screen (including safe area)
          SizedBox(height: bottomPadding > 0 ? bottomPadding : 16),
        ],
      ),
    );
  }
}