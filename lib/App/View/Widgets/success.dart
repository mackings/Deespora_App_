import 'package:dspora/App/View/Auth/View/Signin.dart';
import 'package:dspora/App/View/Auth/View/verifyAccount.dart';
import 'package:dspora/App/View/Utils/navigator.dart';
import 'package:dspora/App/View/Widgets/custombtn.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Success extends ConsumerStatefulWidget {
  final String email; // Received from SignUp

  const Success({super.key, required this.email});

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
                    CustomText(
                      text: "Welcome to Deespora! 👋",
                      color: Colors.white,
                      title: true,
                      textAlign: TextAlign.center,
                      fontSize: 33,
                    ),
                    CustomText(
                      text:
                          "Your account has been created. Let’s explore your community.",
                      textAlign: TextAlign.center,
                      color: const Color.fromARGB(255, 184, 201, 197),
                    ),
                    const SizedBox(height: 30),
                    CustomBtn(
                      text: "Continue",
                      onPressed: () {
                        // Pass email to VerifyAccount
                        Nav.pushReplacement(VerifyAccount(email: widget.email));
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
