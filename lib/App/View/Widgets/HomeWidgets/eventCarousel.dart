import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';


class EventCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final bool autoPlay;
  final ValueChanged<int>? onTap;
  final bool loading;

  const EventCarousel({
    super.key,
    required this.imageUrls,
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
        height: widget.height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: 2, // Show 2 placeholders per screen
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) => Container(
            width: MediaQuery.of(context).size.width * 0.45,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
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
          height: widget.height,
          child: CarouselSlider.builder(
            itemCount: groupedImages.length,
            options: CarouselOptions(
              height: widget.height,
              enlargeCenterPage: false,
              viewportFraction: 1, // full width
              enableInfiniteScroll: true,
              autoPlay: widget.autoPlay,
              onPageChanged: (index, reason) {
                setState(() => _currentIndex = index);
              },
            ),
            itemBuilder: (context, index, realIndex) {
              final pair = groupedImages[index];
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: pair.map((url) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onTap?.call(widget.imageUrls.indexOf(url)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade300,
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.error, color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
       // const SizedBox(height: 8),

      ],
    );
  }
}