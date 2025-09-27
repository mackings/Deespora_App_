import 'package:dspora/App/View/Auth/Api/AuthService.dart';
import 'package:dspora/App/View/Auth/View/resetPassword.dart';
import 'package:dspora/App/dashboard.dart';
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

  /// Login handler
  Future<void> _handleLogin() async {
    if (_selectedIndex == 0) {
      // Email login
      if (email.text.isEmpty || password.text.isEmpty) {
        _showSnackBar("Please enter email and password");
        return;
      }

      setState(() => _isLoading = true);

      try {
        final result = await _authApi.login(
          email: email.text.trim(),
          password: password.text.trim(),
        );

        if (result['success']) {
           Nav.pushReplacement(HomePage());
         // _showSnackBar("✅ Login Successful!");
        } else {
          _showSnackBar(result['message'] ?? "Login failed");
        }
      } catch (e) {
        _showSnackBar("An error occurred: $e");
      } finally {
        // ALWAYS turn off loading
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      // Phone login
      if (phone.text.isEmpty || password.text.isEmpty) {
        _showSnackBar("Please enter phone and password");
        return;
      }

      setState(() => _isLoading = true);

      try {
        final result = await _authApi.login(
          email: phone.text.trim(),
          password: password.text.trim(),
        );

        if (result['success']) {
        //  Nav.pushReplacement(Dashboard());
          // _showSnackBar("✅ Login Successful!");
        } else {
          _showSnackBar(result['message'] ?? "Login failed");
        }
      } catch (e) {
        _showSnackBar("An error occurred: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
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

                    /// Tab Bar
                    Bar(
                      tabs: ["Email", "Phone"],
                      selectedIndex: _selectedIndex,
                      onTabSelected: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    /// Email login fields
                    if (_selectedIndex == 0) ...[
                      CustomTextField(
                        title: "Email",
                        hintText: "Enter email",
                        controller: email,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        title: "Password",
                        hintText: "Enter password",
                        controller: password,
                        isPassword: true,
                      ),
                    ] else ...[
                      /// Phone login fields
                      CustomTextField(
                        title: "Phone",
                        hintText: "Enter phone number",
                        controller: phone,
                        isPhone: true,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
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

                    GestureDetector(
                      onTap: () {
                        Nav.push(ResetPassword());
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
