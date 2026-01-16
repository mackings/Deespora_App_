import 'package:dspora/App/View/Auth/Api/AuthService.dart';
import 'package:dspora/App/View/Auth/View/Signin.dart';
import 'package:dspora/App/View/Auth/View/signup.dart';
import 'package:dspora/App/View/Utils/PinFields.dart';
import 'package:dspora/App/View/Utils/navigator.dart';
import 'package:dspora/App/View/Widgets/Textfield.dart';
import 'package:dspora/App/View/Widgets/custombtn.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:dspora/App/View/Widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class VerifyAccount extends ConsumerStatefulWidget {
  final String? email;
  final String? phoneNumber;
  final bool isPasswordReset;
  final String verificationType; // "email" or "phone"

  const VerifyAccount({
    super.key,
    this.email,
    this.phoneNumber,
    this.isPasswordReset = false,
    this.verificationType = "email",
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VerifyAccountState();
}

class _VerifyAccountState extends ConsumerState<VerifyAccount> {
  String otpCode = "";
  bool _isLoading = false;
  final TextEditingController newPasswordController = TextEditingController();

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> result;

      if (widget.verificationType == "email") {
        if (widget.isPasswordReset) {
          if (newPasswordController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please enter your new password"),
                backgroundColor: Colors.red,
              ),
            );
            setState(() => _isLoading = false);
            return;
          }

          // Email password reset - use OTP token + new password
          result = await AuthApi().resetPassword(
            email: widget.email!,
            token: otpCode,
            newPassword: newPasswordController.text.trim(),
          );
        } else {
          // Regular email verification
          result = await AuthApi().verifyOtp(
            email: widget.email!,
            code: otpCode,
          );
        }
      } else {
        // Phone verification
        if (widget.isPasswordReset) {
          // Phone password reset - need both OTP and new password
          if (newPasswordController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please enter your new password"),
                backgroundColor: Colors.red,
              ),
            );
            setState(() => _isLoading = false);
            return;
          }

          // CHANGED: Use unified resetPassword service
          result = await AuthApi().resetPassword(
            phoneNumber: widget.phoneNumber!,
            token: otpCode,
            newPassword: newPasswordController.text.trim(),
          );
        } else {
          // Regular phone verification
          result = await AuthApi().verifyPhoneOtp(
            phoneNumber: widget.phoneNumber!,
            code: otpCode,
          );
        }
      }

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Verification successful!"),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate based on context
        if (widget.isPasswordReset) {
          Nav.pushReplacement(SignIn());
        } else {
          Nav.push(SignIn());
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Verification failed"),
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

  // ✅ RESEND CODE FUNCTION
  Future<void> _handleResendCode() async {
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> result;

      if (widget.verificationType == "email") {
        // Resend email OTP
        result = await AuthApi().requestPasswordReset(
          email: widget.email,
          phoneNumber: null,
        );
      } else {
        // Resend phone OTP
        result = await AuthApi().requestPasswordReset(
          email: null,
          phoneNumber: widget.phoneNumber,
        );
      }

      setState(() => _isLoading = false);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Code resent successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Failed to resend code"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String get _title {
    if (widget.isPasswordReset) {
      return "Reset Password";
    }
    return widget.verificationType == "email"
        ? "Verify your Account"
        : "Verify Phone Number";
  }

  String get _subtitle {
    final target = widget.verificationType == "email" 
        ? widget.email 
        : widget.phoneNumber;
    
    if (widget.isPasswordReset) {
      return "Enter the code sent to $target to reset your password";
    }
    return "Enter the six-digit OTP sent to $target";
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      text: "Verifying OTP...",
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () => Nav.pushReplacement(SignUp()),
          ),
        ),
        body: SafeArea(
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
                      text: _title,
                      title: true,
                      fontSize: 20,
                    ),
                    const SizedBox(height: 20),
                    CustomText(
                      text: _subtitle,
                    ),
                    const SizedBox(height: 20),

                    PinInputFields(
                      onCompleted: (value) {
                        setState(() => otpCode = value);
                      },
                    ),
                    
                    // Show password field for email/phone password reset
                    if (widget.isPasswordReset) ...[
                      const SizedBox(height: 30),
                      CustomTextField(
                        title: "New Password",
                        hintText: "Enter new password",
                        controller: newPasswordController,
                      ),
                    ],

                    const SizedBox(height: 50),

                    CustomBtn(
                      text: widget.isPasswordReset 
                          ? "Reset Password" 
                          : "Verify ${widget.verificationType == 'email' ? 'Email' : 'Phone'}",
                      onPressed: () {
                        if (otpCode.length == 6) {
                          _verifyOtp();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please enter a valid 6-digit code",
                              ),
                            ),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 15),

                    // ✅ RESEND CODE BUTTON
                    TextButton(
                      onPressed: _handleResendCode,
                      child: const Text(
                        "Resend Code",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
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

  @override
  void dispose() {
    newPasswordController.dispose();
    super.dispose();
  }
}
