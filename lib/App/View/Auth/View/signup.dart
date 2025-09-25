import 'dart:math' as math;

import 'package:dspora/App/View/Utils/navigator.dart';
import 'package:dspora/App/View/Utils/passvalidator.dart';
import 'package:dspora/App/View/Widgets/Textfield.dart';
import 'package:dspora/App/View/Widgets/custombtn.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:dspora/App/View/Widgets/indicator.dart';
import 'package:dspora/App/View/Widgets/success.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUp extends ConsumerStatefulWidget {
  const SignUp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignUp> {
  final TextEditingController firstname = TextEditingController();
  final TextEditingController lastname = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  int totalSteps = 3;

  // 🔹 Instead of a static counter, calculate step progress
  int get currentStep {
    int step = 0;
    if (firstname.text.isNotEmpty) step++;
    if (lastname.text.isNotEmpty) step++;
    if (email.text.isNotEmpty) step++;
    if (password.text.isNotEmpty) step++;
    return step > totalSteps ? totalSteps : step;
  }

  bool get allComplete =>
      firstname.text.isNotEmpty &&
      lastname.text.isNotEmpty &&
      email.text.isNotEmpty &&
      password.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    firstname.addListener(_onChanged);
    lastname.addListener(_onChanged);
    email.addListener(_onChanged);
    password.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    firstname.dispose();
    lastname.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int strengthScore = PasswordValidator.strength(password.text);
    final double strengthPercent = strengthScore / 5;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                // 🔹 Dynamic registration indicator
                CustomText(
                  text: "Complete Registration $currentStep / $totalSteps",
                ),

                const SizedBox(height: 20),

                StepIndicator(totalSteps: totalSteps, currentStep: currentStep),

                const SizedBox(height: 40),

                CustomTextField(
                  title: "First name",
                  hintText: "First name",
                  controller: firstname,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  title: "Last name",
                  hintText: "Last name",
                  controller: lastname,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  title: "Email",
                  hintText: "Email address",
                  controller: email,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  title: "Password",
                  hintText: "Enter password",
                  isPassword: true,
                  controller: password,
                ),

                const SizedBox(height: 15),

                // 🔹 Password strength bar
                LinearProgressIndicator(
                  value: strengthPercent,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    strengthPercent < 0.3
                        ? Colors.red
                        : strengthPercent < 0.6
                        ? Colors.orange
                        : Colors.green,
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 15),

                if (!PasswordValidator.isStrong(password.text))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!PasswordValidator.hasMinLength(password.text))
                        _ruleCheck("At least 8 characters", false),
                      if (!PasswordValidator.hasUppercase(password.text))
                        _ruleCheck("Contains uppercase", false),
                      if (!PasswordValidator.hasLowercase(password.text))
                        _ruleCheck("Contains lowercase", false),
                      if (!PasswordValidator.hasNumber(password.text))
                        _ruleCheck("Contains number", false),
                      if (!PasswordValidator.hasSpecialChar(password.text))
                        _ruleCheck("Contains special char (!@#\$&*~)", false),
                    ],
                  )
                else
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      CustomText(
                        text: "Password set to go ",
                        color: Colors.green,
                      ),
                    ],
                  ),

                const SizedBox(height: 40),

                CustomBtn(
                  text: "Continue",
                  onPressed: allComplete
                      ? () {
                          debugPrint(
                            "✅ Step $currentStep / $totalSteps complete!",
                          );
                          Nav.push(Success());
                        }
                      : () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _ruleCheck(String text, bool passed) {
    return Row(
      children: [
        Icon(
          passed ? Icons.check_circle : Icons.cancel,
          size: 18,
          color: passed ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 6),
        CustomText(text: text, color: passed ? Colors.green : Colors.red),
      ],
    );
  }
}
