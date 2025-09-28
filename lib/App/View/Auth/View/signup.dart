import 'dart:math' as math;

import 'package:dspora/App/View/Auth/Api/AuthService.dart';
import 'package:dspora/App/View/Utils/navigator.dart';
import 'package:dspora/App/View/Utils/passvalidator.dart';
import 'package:dspora/App/View/Widgets/Textfield.dart';
import 'package:dspora/App/View/Widgets/custombtn.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:dspora/App/View/Widgets/indicator.dart';
import 'package:dspora/App/View/Widgets/loader.dart';
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
  final TextEditingController phone = TextEditingController();
  final TextEditingController password = TextEditingController();

  // store currently selected dial code from the phone field
  String _selectedCountryCode = '';
  bool _isLoading = false; // <--- Added loading flag

  int totalSteps = 4;

  int get currentStep {
    int step = 0;
    if (firstname.text.isNotEmpty) step++;
    if (lastname.text.isNotEmpty) step++;
    if (email.text.isNotEmpty) step++;
    if (phone.text.isNotEmpty) step++;
    if (password.text.isNotEmpty) step++;

    return step > totalSteps ? totalSteps : step;
  }

  bool get allComplete =>
      firstname.text.isNotEmpty &&
      lastname.text.isNotEmpty &&
      email.text.isNotEmpty &&
      phone.text.isNotEmpty &&
      password.text.isNotEmpty &&
      _selectedCountryCode.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _selectedCountryCode = '+234';

    firstname.addListener(_onChanged);
    lastname.addListener(_onChanged);
    email.addListener(_onChanged);
    phone.addListener(_onChanged);
    password.addListener(_onChanged);
  }

  @override
  void dispose() {
    firstname.dispose();
    lastname.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  Future<void> _handleContinue() async {
    if (!allComplete) return;

    final fullPhone = '$_selectedCountryCode${phone.text.trim()}';
    debugPrint("📞 Final phone to send: $fullPhone");

    setState(() => _isLoading = true);

    try {
      final result = await AuthApi().register(
        firstname: firstname.text.trim(),
        lastname: lastname.text.trim(),
        email: email.text.trim(),
        phone: fullPhone,
        password: password.text.trim(),
      );

      setState(() => _isLoading = false);

      if (result['success']) {
        Nav.push(Success(email: email.text.trim()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? "Something went wrong")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  double get strengthPercent {
    final pwd = password.text;

    if (pwd.isEmpty) return 0.0;

    double strength = 0.0;

    if (pwd.length >= 8) strength += 0.2;
    if (pwd.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (pwd.contains(RegExp(r'[a-z]'))) strength += 0.2;
    if (pwd.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (pwd.contains(RegExp(r'[!@#\$&*~]'))) strength += 0.2;

    return strength;
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      // <--- Wrap Scaffold with overlay
      isLoading: _isLoading,
      text: "Registering...",
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  CustomText(
                    text: "Complete Registration $currentStep / $totalSteps",
                  ),
                  const SizedBox(height: 20),
                  StepIndicator(
                    totalSteps: totalSteps,
                    currentStep: currentStep,
                  ),
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
                    title: "Phone Number",
                    hintText: "Enter phone number",
                    isPhone: true,
                    controller: phone,
                    onCountrySelected: (code) {
                      setState(() {
                        _selectedCountryCode = code;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    title: "Password",
                    hintText: "Enter password",
                    isPassword: true,
                    controller: password,
                  ),
                  const SizedBox(height: 15),

                  // Password strength indicator
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

                  // Password validation rules
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
                    onPressed: allComplete ? _handleContinue : null,
                  ),
                ],
              ),
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
