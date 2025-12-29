import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class CategoryItem {
  final String title;
  final String svgAsset;       
  final Color backgroundColor;
  final VoidCallback onTap;    

  CategoryItem({
    required this.title,
    required this.svgAsset,
    required this.backgroundColor,
    required this.onTap,
  });
}

class CategoryGrid extends StatelessWidget {
  final List<CategoryItem> items;

  const CategoryGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,       
        childAspectRatio: 2.5,  // Adjusted for horizontal card
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _CategoryCard(item: item);
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryItem item;

  const _CategoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: item.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon
            SizedBox(
              height: 40,
              width: 40,
              child: Image.asset(
                item.svgAsset,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(width: 12),

            // Label
            Expanded(
              child: CustomText(
                text: item.title,
                title: true,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}