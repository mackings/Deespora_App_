import 'package:dspora/App/View/Home/onboarding2.dart';
import 'package:dspora/App/View/Widgets/custombtn.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dspora/App/View/Utils/navigator.dart';

class Onboarding extends ConsumerStatefulWidget {
  const Onboarding({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OnboardingState();
}

class _OnboardingState extends ConsumerState<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 40,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 430,
                child: SvgPicture.asset(
                  'assets/svg/eclipse.svg',
                  fit: BoxFit.fill,
                ),
              ),
            ),

            Positioned(
              top: 50,
              child: Image.asset(
                'assets/img/flag.png',
                width: 350,
                fit: BoxFit.contain,
              ),
            ),

            SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 450),
                      CustomText(
                        text:
                            "Welcome To Your Best Guide in Diaspora, Deespora",
                        title: true,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      CustomText(
                        text:
                            "Discover and connect with African-owned businesses, vibrant events, and cultural spaces wherever you are in the U.S.",
                        content: true,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      CustomBtn(
                        text: "Get Started >>>",
                        onPressed: () {
                          Nav.push(Second_Onboarding());
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
