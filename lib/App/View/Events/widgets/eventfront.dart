import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';



class EventFront extends StatelessWidget {
  final String imageUrl;
  final String eventName;
  final String category;
  final String location;
  final String date;
  final VoidCallback? onTap;

  const EventFront({
    super.key,
    required this.imageUrl,
    required this.eventName,
    required this.category,
    required this.location,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 130,
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
              // Event Image
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

              // Event Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Event Name
                      CustomText(
                        text: eventName,
                        title: true,
                        fontSize: 16,
                        shorten: true,
                      ),

                      // Category
                      CustomText(
                        text: category,
                        content: true,
                        fontSize: 14,
                      ),

                      // Location
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
                              shorten: true,
                            ),
                          ),
                        ],
                      ),

                      // Date
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          CustomText(
                            text: date,
                            content: true,
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Action Button
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
      ),
    );
  }
}
