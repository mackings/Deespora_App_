import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';


class StoreFront extends StatelessWidget {
  final String imageUrl;
  final String storeName;
  final String category;
  final String location;
  final double rating;
  final VoidCallback? onTap;

  const StoreFront({
    super.key,
    required this.imageUrl,
    required this.storeName,
    required this.category,
    required this.location,
    required this.rating,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFAFAFA)),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0C0C0C0D),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // 🟩 Store Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            // 🟩 Store Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🟨 Store Name
                    CustomText(
                      text: storeName,
                      title: true,
                      fontSize: 16,
                      
                    ),

                    // 🟨 Category
                    CustomText(
                      text: category,
                      content: true,
                      fontSize: 14,
                     
                    ),

                    // 🟨 Location
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: CustomText(
                            text: location,
                            content: true,
                            fontSize: 12,
                            
                          ),
                        ),
                      ],
                    ),

                    // 🟨 Rating
                    Row(
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              index < rating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 14,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        CustomText(
                          text: rating.toString(),
                          content: true,
                          fontSize: 12,
                          
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 🟩 Action Button
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF37B6AF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}