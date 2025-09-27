import 'package:dspora/App/View/Auth/View/Signin.dart';
import 'package:dspora/App/View/Auth/View/signup.dart';
import 'package:dspora/App/View/Utils/socialSignin.dart';
import 'package:dspora/App/View/Widgets/custombtn.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:dspora/App/View/Utils/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Second_Onboarding extends ConsumerStatefulWidget {
  const Second_Onboarding({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _Second_OnboardingState();
}

class _Second_OnboardingState extends ConsumerState<Second_Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 90),
              child: Column(
                children: [
                  Image.asset("assets/img/logo.png"),

                  SizedBox(height: 20),

                  CustomText(
                    text: "Lets get you started with Deespora",
                    fontSize: 20,
                    title: true,
                  ),
                  SizedBox(height: 40),
                  SocialSigninButton(
                    text: "Sign in Using Google Account",
                    svgAsset: "assets/svg/google.svg",
                  ),
                  SizedBox(height: 20),
                  SocialSigninButton(
                    text: "Sign in Using Facebook Account",
                    svgAsset: "assets/svg/facebook.svg",
                  ),
                  SizedBox(height: 40),
                  CustomBtn(
                    text: "Sign in using Password",
                    onPressed: () {
                      Nav.push(SignIn());
                    },
                  ),
                  SizedBox(height: 20),

                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(text: "New To Deespora"),
                        SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Nav.push(SignUp());
                          },
                          child: CustomText(
                            text: "Register Now",
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  CustomText(text: "Continue as Guest", underline: true),
                  SizedBox(height: 80),

                  CustomText(text: "By using Deespora,you agree to the"),
                  SizedBox(height: 10),

                  CustomText(
                    text: "Terms and Privacy Policy",
                    underline: true,
                    color: Colors.teal,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
