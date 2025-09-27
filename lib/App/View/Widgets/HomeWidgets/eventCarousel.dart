import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class EventCarousel extends StatefulWidget {
  
  final List<String> imageUrls;
  final double height;
  final bool autoPlay;

  const EventCarousel({
    super.key,
    required this.imageUrls,
    this.height = 30,        
    this.autoPlay = true,
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
        Container(
          height: 120,
          child: CarouselSlider(
            options: CarouselOptions(
              height: widget.height,
              autoPlay: widget.autoPlay,
              enlargeCenterPage: false,   
              viewportFraction: 0.70,    
              onPageChanged: (index, reason) {
                setState(() => _currentIndex = index);
              },
            ),
            items: widget.imageUrls.map((url) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

      ],
    );
  }
}
