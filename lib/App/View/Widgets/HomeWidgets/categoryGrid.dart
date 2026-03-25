import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';

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
    final w = MediaQuery.sizeOf(context).width;
    final isSmall = w < 360;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(isSmall ? 8 : 12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        // Give a little more usable width on small screens (less padding/spacing)
        childAspectRatio: isSmall ? 2.8 : 2.5,
        crossAxisSpacing: isSmall ? 10 : 16,
        mainAxisSpacing: isSmall ? 10 : 16,
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
    final w = MediaQuery.sizeOf(context).width;
    final isSmall = w < 360;

    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 16,
          vertical: isSmall ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: item.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon
            SizedBox(
              height: isSmall ? 32 : 40,
              width: isSmall ? 32 : 40,
              child: Image.asset(item.svgAsset, fit: BoxFit.contain),
            ),

            const SizedBox(width: 12),

            // Label
            Expanded(
              child: CustomText(
                text: item.title,
                title: true,
                fontSize: isSmall ? 11 : 12,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
