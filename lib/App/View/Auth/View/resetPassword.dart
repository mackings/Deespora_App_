import 'package:dspora/App/View/Utils/emailSuccess.dart';
import 'package:dspora/App/View/Utils/navigator.dart';
import 'package:dspora/App/View/Utils/tabBar.dart';
import 'package:dspora/App/View/Widgets/Textfield.dart';
import 'package:dspora/App/View/Widgets/custombtn.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResetPassword extends ConsumerStatefulWidget {
  const ResetPassword({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends ConsumerState<ResetPassword> {
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  CustomText(
                    text: "Log into account",
                    title: true,
                    fontSize: 20,
                  ),
                  const SizedBox(height: 20),

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

                  if (_selectedIndex == 0) ...[
                    CustomTextField(
                      title: "Email",
                      hintText: "Enter email",
                      controller: email,
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    CustomTextField(
                      title: "Phone",
                      hintText: "Enter phone number",
                      controller: phone,
                      isPhone: true,
                    ),

                    const SizedBox(height: 20),
                  ],

                  CustomBtn(
                    text: "Reset Password",
                    onPressed: () {
                      if (_selectedIndex == 0) {
                        Nav.push(EmailSuccess());
                        // email login
                      } else {
                        // phone login
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
