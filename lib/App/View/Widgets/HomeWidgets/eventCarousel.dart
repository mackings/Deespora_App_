import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';


class EventCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final bool autoPlay;

  /// 👇 Added callback
  final ValueChanged<int>? onTap;

  const EventCarousel({
    super.key,
    required this.imageUrls,
    this.height = 200,
    this.autoPlay = true,
    this.onTap, // 👈 accept the callback
  });

  @override
  State<EventCarousel> createState() => _EventCarouselState();
}

class _EventCarouselState extends State<EventCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Carousel Slider
        SizedBox(
          height: widget.height,
          child: CarouselSlider.builder(
            itemCount: widget.imageUrls.length,
            options: CarouselOptions(
              height: widget.height,
              autoPlay: widget.autoPlay,
              enlargeCenterPage: false,
              viewportFraction: 0.70,
              onPageChanged: (index, reason) {
                setState(() => _currentIndex = index);
              },
            ),
            itemBuilder: (context, index, realIndex) {
              final url = widget.imageUrls[index];
              return GestureDetector(
                onTap: () {
                  if (widget.onTap != null) {
                    widget.onTap!(index); // 👈 call the callback
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: double.infinity,
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
