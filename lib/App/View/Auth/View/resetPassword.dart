import 'package:dspora/App/View/Auth/Api/AuthService.dart';
import 'package:dspora/App/View/Auth/View/verifyAccount.dart';
import 'package:dspora/App/View/Utils/emailSuccess.dart';
import 'package:dspora/App/View/Utils/navigator.dart';
import 'package:dspora/App/View/Utils/tabBar.dart';
import 'package:dspora/App/View/Widgets/Textfield.dart';
import 'package:dspora/App/View/Widgets/custombtn.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:dspora/App/View/Widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class ResetPassword extends ConsumerStatefulWidget {
  const ResetPassword({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends ConsumerState<ResetPassword> {
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();

  final AuthApi _authApi = AuthApi();

  int _selectedIndex = 0;
  bool _isLoading = false;
  String _selectedCountryCode = '+234'; // Default Nigeria

  /// Handle Reset Password Request
  Future<void> _handleResetRequest() async {
    final input = _selectedIndex == 0 ? email.text.trim() : phone.text.trim();

    if (input.isEmpty) {
      _showSnackBar("Please enter ${_selectedIndex == 0 ? 'email' : 'phone number'}");
      return;
    }

    // Basic validation
    if (_selectedIndex == 0 && !_isValidEmail(input)) {
      _showSnackBar("Please enter a valid email address");
      return;
    }

    if (_selectedIndex == 1 && input.length < 10) {
      _showSnackBar("Please enter a valid phone number");
      return;
    }

    setState(() => _isLoading = true);

    // Combine country code with phone number
    String? fullPhoneNumber;
    if (_selectedIndex == 1) {
      fullPhoneNumber = '$_selectedCountryCode$input';
      print("📱 Sending phone number: $fullPhoneNumber");
    }

    // Call the unified API with either email or phone
    final result = await _authApi.requestPasswordReset(
      email: _selectedIndex == 0 ? input : null,
      phoneNumber: _selectedIndex == 1 ? fullPhoneNumber : null,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      _showSnackBar("✅ Reset code sent!");

      Nav.push(
        VerifyAccount(
          email: _selectedIndex == 0 ? input : null,
          phoneNumber: _selectedIndex == 1 ? fullPhoneNumber : null,
          isPasswordReset: true,
          verificationType: _selectedIndex == 0 ? "email" : "phone",
        ),
      );
    } else {
      _showSnackBar(result['message'] ?? "Failed to send reset request");
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    email.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        text: "Sending reset request...",
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
                      text: "Reset your password",
                      title: true,
                      fontSize: 20,
                    ),
                    const SizedBox(height: 10),
                    CustomText(
                      text: "Enter your ${_selectedIndex == 0 ? 'email' : 'phone number'} to receive a reset code",
                      fontSize: 14,
                    ),
                    const SizedBox(height: 30),

                    Bar(
                      tabs: const ["Email", "Phone"],
                      selectedIndex: _selectedIndex,
                      onTabSelected: (index) {
                        setState(() => _selectedIndex = index);
                      },
                    ),
                    const SizedBox(height: 30),

                    if (_selectedIndex == 0)
                      CustomTextField(
                        title: "Email",
                        hintText: "Enter email",
                        controller: email,
                       // keyboardType: TextInputType.emailAddress,
                      )
                    else
                      CustomTextField(
                        title: "Phone",
                        hintText: "Enter phone number",
                        controller: phone,
                        isPhone: true,
                       // keyboardType: TextInputType.phone,
                      ),

                    const SizedBox(height: 20),

                    CustomBtn(
                      text: "Reset Password",
                      onPressed: _handleResetRequest,
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