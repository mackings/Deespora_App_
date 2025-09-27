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
        childAspectRatio: 1.3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
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
        decoration: BoxDecoration(
          color: item.backgroundColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SVG Icon
            SizedBox(
              height: 30,
              width: 30,
              child: SvgPicture.asset(
                item.svgAsset,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 10),

            // Label
CustomText(text: item.title,content: true,),
          ],
        ),
      ),
    );
  }
}

