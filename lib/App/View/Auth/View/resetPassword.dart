import 'package:dspora/App/View/Auth/Api/AuthService.dart';
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

  /// Handle Reset Password Request
  Future<void> _handleResetRequest() async {
    final input = _selectedIndex == 0 ? email.text.trim() : phone.text.trim();

    if (input.isEmpty) {
      _showSnackBar("Please enter ${_selectedIndex == 0 ? 'email' : 'phone'}");
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authApi.requestPasswordReset(email: input);

    setState(() => _isLoading = false);

    if (result['success']) {
      _showSnackBar("✅ Reset link or code sent!");
      Nav.push(EmailSuccess(email: input)); // pass email to next screen
    } else {
      _showSnackBar(result['message'] ?? "Failed to send reset request");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                    const SizedBox(height: 30),

                    Bar(
                      tabs: ["Email", "Phone"],
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
                      )
                    else
                      CustomTextField(
                        title: "Phone",
                        hintText: "Enter phone number",
                        controller: phone,
                        isPhone: true,
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
