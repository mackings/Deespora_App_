import 'package:dspora/App/View/Auth/View/Signin.dart';
import 'package:dspora/App/View/Auth/View/signup.dart';
import 'package:dspora/App/View/Utils/socialSignin.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/Homepage.dart';
import 'package:dspora/App/View/Widgets/custombtn.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:dspora/App/View/Utils/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';



class Second_Onboarding extends ConsumerStatefulWidget {
  const Second_Onboarding({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _Second_OnboardingState();
}

class _Second_OnboardingState extends ConsumerState<Second_Onboarding> {
  
  Future<void> _continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Set userName to 'Guest' explicitly
    await prefs.setString('userName', 'Guest');
    
    // Clear any existing auth data
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userEmail');
    await prefs.remove('emailVerified');
    await prefs.remove('phoneVerified');
    
    debugPrint('✅ Guest mode activated');
    
    // Navigate to HomePage
    Nav.push(HomePage());
  }

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

                  const SizedBox(height: 20),

                  CustomText(
                    text: "Lets get you started with Deespora",
                    fontSize: 20,
                    title: true,
                  ),
                  const SizedBox(height: 40),
                  SocialSigninButton(
                    text: "Sign in Using Google Account",
                    svgAsset: "assets/svg/google.svg",
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.only(left: 20,right: 20),
                    child: CustomBtn(
                      text: "Sign in using Password",
                      onPressed: () {
                        Nav.push(SignIn());
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(text: "New To Deespora"),
                        const SizedBox(width: 4),
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

                  const SizedBox(height: 60),

                  GestureDetector(
                    onTap: _continueAsGuest,
                    child: CustomText(
                      text: "Continue as Guest",
                      underline: true,
                    ),
                  ),
                  const SizedBox(height: 60),

                  CustomText(text: "By using Deespora,you agree to the"),
                  const SizedBox(height: 10),

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