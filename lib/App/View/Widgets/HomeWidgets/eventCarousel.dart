import 'package:cached_network_image/cached_network_image.dart';
import 'package:dspora/App/View/Events/Model/eventModel.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';


class EventCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final List<Event>? events; // Added for event data
  final double height;
  final bool autoPlay;
  final ValueChanged<int>? onTap;
  final bool loading;

  const EventCarousel({
    super.key,
    required this.imageUrls,
    this.events, // Optional event data
    this.height = 200,
    this.autoPlay = true,
    this.onTap,
    this.loading = false,
  });

  @override
  State<EventCarousel> createState() => _EventCarouselState();
}

class _EventCarouselState extends State<EventCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      // Skeleton loader when loading
      return SizedBox(
        height: widget.height + 80, // Extra height for details
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: 2,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.45,
                height: widget.height,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: MediaQuery.of(context).size.width * 0.45,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Group images into chunks of 2
    final List<List<String>> groupedImages = [];
    for (int i = 0; i < widget.imageUrls.length; i += 2) {
      groupedImages.add(
        widget.imageUrls.sublist(
          i,
          i + 2 > widget.imageUrls.length ? widget.imageUrls.length : i + 2,
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height + 80, // Increased height for details
          child: CarouselSlider.builder(
            itemCount: groupedImages.length,
            options: CarouselOptions(
              height: widget.height + 80,
              enlargeCenterPage: false,
              viewportFraction: 1,
              enableInfiniteScroll: true,
              autoPlay: widget.autoPlay,
              onPageChanged: (index, reason) {
                setState(() => _currentIndex = index);
              },
            ),
            itemBuilder: (context, index, realIndex) {
              final pair = groupedImages[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: pair.asMap().entries.map((entry) {
                  final itemIndex = entry.key;
                  final url = entry.value;
                  final originalIndex = widget.imageUrls.indexOf(url);
                  final event = widget.events != null && originalIndex < widget.events!.length
                      ? widget.events![originalIndex]
                      : null;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onTap?.call(originalIndex),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: url,
                                height: widget.height,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: widget.height,
                                  color: Colors.grey.shade300,
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: widget.height,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.error, color: Colors.red),
                                ),
                              ),
                            ),

                            // Event Details
                            if (event != null) ...[
                              const SizedBox(height: 8),
                              
                              // Event Name
                              CustomText(
                                text: event.name,
                                fontSize: 13,
                                title: false,
                                shorten: true,
                                maxLength: 20,

                              ),
                              

                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(String localDate) {
    try {
      final date = DateTime.parse(localDate);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return localDate;
    }
  }
}