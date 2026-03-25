import 'package:dspora/App/View/Auth/View/onboarding2.dart';
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = MediaQuery.sizeOf(context);
            final isSmall = size.width < 360 || constraints.maxHeight < 700;

            final artHeight = (constraints.maxHeight * 0.52).clamp(
              260.0,
              430.0,
            );
            final flagWidth = (size.width * 0.92).clamp(240.0, 350.0);

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: artHeight,
                        width: double.infinity,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Positioned.fill(
                              child: SvgPicture.asset(
                                'assets/svg/eclipse.svg',
                                fit: BoxFit.fill,
                              ),
                            ),
                            Positioned(
                              top: 10,
                              child: Image.asset(
                                'assets/img/flag.png',
                                width: flagWidth,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomText(
                        text:
                            "Welcome To Your Best Guide in Diaspora, Deespora",
                        title: true,
                        fontSize: isSmall ? 26 : null,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      CustomText(
                        text:
                            "Discover and connect with African-owned businesses, vibrant events, and cultural spaces wherever you are in the U.S.",
                        content: true,
                        fontSize: isSmall ? 13 : null,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: CustomBtn(
                          text: "Get Started",
                          onPressed: () {
                            Nav.push(Second_Onboarding());
                          },
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom > 0
                            ? MediaQuery.of(context).padding.bottom
                            : 12,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
