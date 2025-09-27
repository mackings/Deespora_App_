import 'dart:async';
import 'package:dspora/App/View/Auth/Api/AuthService.dart';
import 'package:dspora/App/View/Auth/View/Signin.dart';
import 'package:dspora/App/View/Utils/navigator.dart';
import 'package:dspora/App/View/Widgets/Textfield.dart';
import 'package:dspora/App/View/Widgets/custombtn.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:dspora/App/View/Widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



Future<void> showOtpModalSheet({
  required BuildContext context,
  required String email,
  required Null Function() onResend,
  required Null Function(dynamic code) onCompleted,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _OtpSheet(
        email: email,
        onCompleted: (String value) {},
        resendCooldown: Duration(),
      ),
    ),
  );
}

class _OtpSheet extends StatefulWidget {
  final String email;

  const _OtpSheet({
    required this.email,
    required Duration resendCooldown,
    required Null Function(String value) onCompleted,
  });

  @override
  State<_OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<_OtpSheet> {
  static const int length = 5;

  final AuthApi _authApi = AuthApi();

  final List<TextEditingController> _controllers = List.generate(
    length,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(length, (_) => FocusNode());

  final TextEditingController _newPass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();

  bool _isLoading = false;
  String _error = '';

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _newPass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _handleReset() async {
    if (_code.length != length) {
      setState(() => _error = "Please enter the full token");
      return;
    }

    if (_newPass.text.trim().isEmpty ||
        _confirmPass.text.trim().isEmpty ||
        _newPass.text.trim() != _confirmPass.text.trim()) {
      setState(() => _error = "Passwords do not match");
      return;
    }

    setState(() {
      _error = '';
      _isLoading = true;
    });

    final result = await _authApi.resetPassword(
      email: widget.email,
      token: _code,
      newPassword: _newPass.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      Navigator.pop(context); // Close OTP modal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Password reset successfully!")),
      );
      Nav.pushReplacement(SignIn());
    } else {
      setState(() => _error = result['message'] ?? "Reset failed");
    }
  }

  Widget _field(int i) => SizedBox(
    width: 55,
    height: 65,
    child: TextField(
      controller: _controllers[i],
      focusNode: _focusNodes[i],
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      maxLength: 1,
      decoration: InputDecoration(
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onChanged: (v) {
        if (v.isNotEmpty && i < length - 1) {
          _focusNodes[i + 1].requestFocus();
        }
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      text: "Resetting password...",
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  CustomText(text: "Enter Token", title: true, fontSize: 20),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(length, _field),
              ),
              const SizedBox(height: 20),

              CustomTextField(
                title: "New Password",
                hintText: "Enter new password",
                controller: _newPass,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                title: "Confirm Password",
                hintText: "Re-enter new password",
                controller: _confirmPass,
                isPassword: true,
              ),

              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: CustomText(
                    text: _error,
                    fontSize: 13,
                    color: Colors.red,
                  ),
                ),

              const SizedBox(height: 20),

              CustomBtn(text: "Reset Password", onPressed: _handleReset),
            ],
          ),
        ),
      ),
    );
  }
}
