import 'package:dspora/App/View/Auth/Api/AuthService.dart';
import 'package:dspora/App/View/Auth/View/Signin.dart';
import 'package:dspora/App/View/Utils/PinFields.dart';
import 'package:dspora/App/View/Utils/navigator.dart';
import 'package:dspora/App/View/Widgets/custombtn.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:dspora/App/View/Widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class VerifyAccount extends ConsumerStatefulWidget {
  final String email; // Passed from Success page

  const VerifyAccount({super.key, required this.email});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VerifyAccountState();
}

class _VerifyAccountState extends ConsumerState<VerifyAccount> {
  String otpCode = "";
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);

    try {
      final result = await AuthApi().verifyOtp(
        email: widget.email,
        code: otpCode,
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP verified successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Nav.push(SignIn());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "OTP verification failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      text: "Verifying OTP...",
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  children: [
                    CustomText(
                      text: "Verify your Account",
                      title: true,
                      fontSize: 20,
                    ),
                    const SizedBox(height: 20),
                    CustomText(text: "Enter the five-digit OTP sent to your email"),
                    const SizedBox(height: 20),

                    PinInputFields(
                      onCompleted: (value) {
                        setState(() => otpCode = value);
                      },
                    ),
                    const SizedBox(height: 50),

                    CustomBtn(
                      text: "Verify Email",
                      onPressed: () {
                        if (otpCode.length == 6) {
                          _verifyOtp();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter a valid 5-digit code"),
                            ),
                          );
                        }
                      },
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

