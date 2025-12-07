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

  final AuthApi _authApi = AuthApi();

  // Store currently selected dial code from the phone field
  String _selectedCountryCode = '+234';
  bool _isLoading = false;

  int totalSteps = 5;

  int get currentStep {
    int step = 0;
    if (firstname.text.isNotEmpty) step++;
    if (lastname.text.isNotEmpty) step++;
    if (email.text.isNotEmpty) step++;
    if (phone.text.isNotEmpty) step++;
    if (password.text.isNotEmpty && PasswordValidator.isStrong(password.text)) {
      step++;
    }

    return step > totalSteps ? totalSteps : step;
  }

  bool get allComplete =>
      firstname.text.isNotEmpty &&
      lastname.text.isNotEmpty &&
      email.text.isNotEmpty &&
      phone.text.isNotEmpty &&
      password.text.isNotEmpty &&
      PasswordValidator.isStrong(password.text) &&
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
    if (!allComplete) {
      _showSnackBar("Please complete all fields correctly");
      return;
    }

    // Validate email format
    if (!_isValidEmail(email.text.trim())) {
      _showSnackBar("Please enter a valid email address");
      return;
    }

    // Validate phone number
    if (phone.text.trim().isEmpty || phone.text.trim().length < 7) {
      _showSnackBar("Please enter a valid phone number");
      return;
    }

    final fullPhone = '$_selectedCountryCode${phone.text.trim()}';
    debugPrint("📞 Final phone to send: $fullPhone");

    setState(() => _isLoading = true);

    try {
      final result = await _authApi.register(
        firstname: firstname.text.trim(),
        lastname: lastname.text.trim(),
        email: email.text.trim(),
        phone: fullPhone,
        password: password.text.trim(),
      );

      if (mounted) setState(() => _isLoading = false);

      if (result['success']) {
        // Navigate to email verification screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Success(email: email.text.trim()),
            ),
          );
        }
      } else {
        _showSnackBar(result['message'] ?? "Registration failed");
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showSnackBar("Error: ${e.toString()}");
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.teal,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
      isLoading: _isLoading,
      text: "Creating your account...",
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "Create Account",
                    title: true,
                    fontSize: 24,
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    text: "Complete Registration $currentStep / $totalSteps",
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  StepIndicator(
                    totalSteps: totalSteps,
                    currentStep: currentStep,
                  ),
                  const SizedBox(height: 30),

                  // First Name
                  CustomTextField(
                    title: "First name",
                    hintText: "Enter your first name",
                    controller: firstname,
                  ),
                  const SizedBox(height: 20),

                  // Last Name
                  CustomTextField(
                    title: "Last name",
                    hintText: "Enter your last name",
                    controller: lastname,
                  ),
                  const SizedBox(height: 20),

                  // Email
                  CustomTextField(
                    title: "Email",
                    hintText: "Enter your email address",
                    controller: email,
                  ),
                  const SizedBox(height: 20),

                  // Phone Number
                  CustomTextField(
                    title: "Phone Number",
                    hintText: "Enter phone number",
                    isPhone: true,
                    controller: phone,
                    onCountrySelected: (code) {
                      setState(() {
                        _selectedCountryCode = code;
                      });
                      debugPrint("🏁 Country selected: $code");
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password
                  CustomTextField(
                    title: "Password",
                    hintText: "Create a strong password",
                    isPassword: true,
                    controller: password,
                  ),
                  const SizedBox(height: 15),

                  // Password strength indicator
                  if (password.text.isNotEmpty) ...[
                    LinearProgressIndicator(
                      value: strengthPercent,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        strengthPercent < 0.4
                            ? Colors.red
                            : strengthPercent < 0.7
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
                          _ruleCheck(
                            "At least 8 characters",
                            PasswordValidator.hasMinLength(password.text),
                          ),
                          _ruleCheck(
                            "Contains uppercase letter",
                            PasswordValidator.hasUppercase(password.text),
                          ),
                          _ruleCheck(
                            "Contains lowercase letter",
                            PasswordValidator.hasLowercase(password.text),
                          ),
                          _ruleCheck(
                            "Contains number",
                            PasswordValidator.hasNumber(password.text),
                          ),
                          _ruleCheck(
                            "Contains special character (!@#\$&*~)",
                            PasswordValidator.hasSpecialChar(password.text),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          CustomText(
                            text: "Strong password ",
                            color: Colors.green,
                            fontSize: 14,
                          ),
                        ],
                      ),
                  ],

                  const SizedBox(height: 40),

                  // Continue Button
                  CustomBtn(
                    text: "Create Account",
                    onPressed: allComplete ? _handleContinue : null,
                  ),

                  const SizedBox(height: 20),

                  // Already have account
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            text: "Already have an account? ",
                            color: Colors.grey,
                          ),
                          CustomText(
                            text: "Sign In",
                            color: Colors.teal,
                            fontSize: 14,
                          ),
                        ],
                      ),
                    ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: passed ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CustomText(
              text: text,
              color: passed ? Colors.green : Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
