import 'package:dspora/App/View/Auth/Api/AuthService.dart';
import 'package:dspora/App/View/Auth/View/resetPassword.dart';
import 'package:dspora/App/View/Auth/View/signup.dart';
import 'package:dspora/App/View/Utils/navigator.dart';
import 'package:dspora/App/View/Utils/tabBar.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/Homepage.dart';
import 'package:dspora/App/View/Widgets/Textfield.dart';
import 'package:dspora/App/View/Widgets/custombtn.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:dspora/App/View/Widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignIn extends ConsumerStatefulWidget {
  const SignIn({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignInState();
}

class _SignInState extends ConsumerState<SignIn> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController phone = TextEditingController();

  final AuthApi _authApi = AuthApi();

  int _selectedIndex = 0;
  bool _isLoading = false;
  String _selectedCountryCode = '+1'; // Changed default to US

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    phone.dispose();
    super.dispose();
  }

  /// Login handler - supports both email and phone login
  Future<void> _handleLogin() async {
    // Validate inputs based on selected tab
    if (_selectedIndex == 0) {
      // Email login
      if (email.text.trim().isEmpty || password.text.isEmpty) {
        _showSnackBar("Please enter email and password");
        return;
      }

      if (!_isValidEmail(email.text.trim())) {
        _showSnackBar("Please enter a valid email address");
        return;
      }
    } else {
      // Phone login
      if (phone.text.trim().isEmpty || password.text.isEmpty) {
        _showSnackBar("Please enter phone and password");
        return;
      }

      if (phone.text.trim().length < 7) {
        _showSnackBar("Please enter a valid phone number");
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> result;

      if (_selectedIndex == 0) {
        // Login with email
        result = await _authApi.login(
          email: email.text.trim(),
          password: password.text.trim(),
        );
      } else {
        // Login with phone
        final fullPhone = '$_selectedCountryCode${phone.text.trim()}';
        debugPrint("📞 Logging in with phone: $fullPhone");

        result = await _authApi.login(
          phoneNumber: fullPhone,
          password: password.text.trim(),
        );
      }

      if (mounted) setState(() => _isLoading = false);

      if (result['success']) {
        // Navigate to home page
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
          );
        }
      } else {
        _showSnackBar(result['message'] ?? "Login failed");
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showSnackBar("An error occurred: ${e.toString()}");
      debugPrint("🔥 Login error: $e");
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
        content: CustomText(text: message, color: Colors.white),
        backgroundColor: Colors.teal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        text: "Logging in...",
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                child: Column(
                  children: [
                    CustomText(
                      text: "Log into account",
                      title: true,
                      fontSize: 20,
                    ),
                    const SizedBox(height: 20),

                    /// Tab Bar - Email or Phone
                    Bar(
                      tabs: const ["Email", "Phone"],
                      selectedIndex: _selectedIndex,
                      onTabSelected: (index) {
                        setState(() {
                          _selectedIndex = index;
                          // Clear inputs when switching tabs
                          email.clear();
                          phone.clear();
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    /// Email login fields
                    if (_selectedIndex == 0) ...[
                      CustomTextField(
                        key: const ValueKey('email_field'),
                        title: "Email",
                        hintText: "Enter email",
                        controller: email,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        key: const ValueKey('email_password_field'),
                        title: "Password",
                        hintText: "Enter password",
                        controller: password,
                        isPassword: true,
                      ),
                    ] else ...[
                      /// Phone login fields
                      CustomTextField(
                        key: const ValueKey('phone_field'),
                        title: "Phone",
                        hintText: "Enter phone number",
                        controller: phone,
                        isPhone: true,
                        onCountrySelected: (code) {
                          setState(() {
                            _selectedCountryCode = code;
                          });
                          debugPrint("🏁 Country code selected: $code");
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        key: const ValueKey('phone_password_field'),
                        title: "Password",
                        hintText: "Enter password",
                        controller: password,
                        isPassword: true,
                      ),
                    ],

                    const SizedBox(height: 40),

                    /// Login Button
                    CustomBtn(text: "Login", onPressed: _handleLogin),

                    const SizedBox(height: 20),

                    // Forgot Password Link
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResetPassword(),
                          ),
                        );
                      },
                      child: CustomText(text: "Forgot Password"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}