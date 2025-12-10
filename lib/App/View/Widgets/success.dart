import 'package:dspora/App/View/Auth/View/Signin.dart';
import 'package:dspora/App/View/Auth/View/verifyAccount.dart';
import 'package:dspora/App/View/Utils/navigator.dart';
import 'package:dspora/App/View/Widgets/custombtn.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Success extends ConsumerStatefulWidget {
  final String? email; // Optional - for backward compatibility
  final String? phoneNumber; // Phone number for verification

  const Success({
    super.key, 
    this.email,
    this.phoneNumber,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SuccessState();
}

class _SuccessState extends ConsumerState<Success> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Image.asset(
                "assets/img/image.png",
                width: 170,
                height: 150,
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset("assets/svg/check.svg"),
                    const SizedBox(height: 20),
                    CustomText(
                      text: "Welcome to Deespora! 👋",
                      color: Colors.white,
                      title: true,
                      textAlign: TextAlign.center,
                      fontSize: 33,
                    ),
                    const SizedBox(height: 15),
                    CustomText(
                      text:
                          "Your account has been created successfully!",
                      textAlign: TextAlign.center,
                      color: const Color.fromARGB(255, 184, 201, 197),
                      fontSize: 16,
                    ),
                    const SizedBox(height: 10),
                    CustomText(
                      text:
                          "A verification code has been sent to your phone number.",
                      textAlign: TextAlign.center,
                      color: const Color.fromARGB(255, 184, 201, 197),
                      fontSize: 14,
                    ),
                    if (widget.phoneNumber != null) ...[
                      const SizedBox(height: 10),
                      CustomText(
                        text: widget.phoneNumber!,
                        textAlign: TextAlign.center,
                        color: Colors.white,
                        fontSize: 16,
                        title: true,
                      ),
                    ],
                    const SizedBox(height: 30),
                    CustomBtn(
                      text: "Verify Phone Number",
                      onPressed: () {
                        // Navigate to phone verification
                        Nav.pushReplacement(
                          VerifyAccount(
                            phoneNumber: widget.phoneNumber,
                            verificationType: "phone",
                            isPasswordReset: false,
                          ),
                        );
                      },
                      outlined: true,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}