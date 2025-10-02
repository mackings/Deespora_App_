import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';


class EventCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final bool autoPlay;
  final ValueChanged<int>? onTap;
  final bool loading; // 👈 new flag

  const EventCarousel({
    super.key,
    required this.imageUrls,
    this.height = 200,
    this.autoPlay = true,
    this.onTap,
    this.loading = false, // default false
  });

  @override
  State<EventCarousel> createState() => _EventCarouselState();
}

class _EventCarouselState extends State<EventCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      // Show skeleton placeholder
      return SizedBox(
        height: widget.height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: 3, // show 3 placeholders
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) => Container(
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: CarouselSlider.builder(
            itemCount: widget.imageUrls.length,
            options: CarouselOptions(
              height: widget.height,
             // autoPlay: widget.autoPlay,
              enlargeCenterPage: false,
              viewportFraction: 0.7,
              onPageChanged: (index, reason) {
                setState(() => _currentIndex = index);
              },
            ),
            itemBuilder: (context, index, realIndex) {
              final url = widget.imageUrls[index];
              return GestureDetector(
                onTap: () => widget.onTap?.call(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
  imageUrl: url,
  fit: BoxFit.cover,
  width: double.infinity,
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
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
