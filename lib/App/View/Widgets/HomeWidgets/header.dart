import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';


class HomeHeader extends StatelessWidget {
  final String name;
  final String location;

  const HomeHeader({
    super.key,
    required this.name,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width - 35,
          height: 54,
          child: Stack(
            children: [
              // Main Title
              Positioned(
                left: 0,
                top: 20,
                child: SizedBox(
                  width: 355,
                  child: CustomText(
                    text: name,   
                    content: false,
                  ),
                ),
              ),

              // Location Row
              Positioned(
                left: 0,
                top: 0,
                child: SizedBox(
                  width: 249.41,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Row(
                        children: [

                         const Icon(
                            Icons.wb_sunny_outlined,
                            size: 16,
                            color: Colors.orange,
                          ),
                           const SizedBox(width: 10),

                          CustomText(
                            text: location,
                            content: true,
                          ),

                          const SizedBox(width: 10),

                          // Arrow Icon
                          Transform.rotate(
                            angle: 1.57, // rotate 90 degrees
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}



