
import 'package:dspora/App/View/Utils/tabBar.dart';
import 'package:dspora/App/View/Widgets/Textfield.dart';
import 'package:dspora/App/View/Widgets/custombtn.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class SignIn extends ConsumerStatefulWidget {
  const SignIn({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignInState();
}

class _SignInState extends ConsumerState<SignIn> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phone = TextEditingController();

  int _selectedIndex = 0; 


  @override
  void initState() {
    super.initState();
  }


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
                    CustomTextField(
                      title: "Password",
                      hintText: "Enter password",
                      controller: password,
                      isPassword: true,
                    ),
                  ] else ...[
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

                  CustomBtn(
                    text: "Login",
                    onPressed: () {
                      if (_selectedIndex == 0) {
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