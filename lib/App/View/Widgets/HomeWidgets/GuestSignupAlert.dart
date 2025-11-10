import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';



class GuestSignupDialog extends StatelessWidget {
  final String title;
  final VoidCallback? onCreateAccount;
  final VoidCallback? onLogin;
  final VoidCallback? onClose;

  const GuestSignupDialog({
    Key? key,
    this.title = 'Want more personalized results?',
    this.onCreateAccount,
    this.onLogin,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Get screen width and height for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ✅ Calculate dialog width (max 90% of screen)
    final dialogWidth = screenWidth * 0.9;
    final dialogHeight = screenHeight * 0.45;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: dialogWidth > 400 ? 400 : dialogWidth,
          padding: const EdgeInsets.all(16),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x3D000000),
                blurRadius: 24,
                offset: Offset(2, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Close button (top-right)
              
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: onClose,
                  child: const Icon(
                    Icons.close,
                    size: 24,
                    color: Color(0xFF404040),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Title text
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: CustomText(
                    text: title,
                    title: true,
                    textAlign: TextAlign.center,
                    fontSize: screenWidth < 400 ? 24 : 32,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Buttons section
              Column(
                children: [
                  GestureDetector(
                    onTap: onCreateAccount,
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF37B6AF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const CustomText(
                        text: 'Create Account',
                        color: Colors.white,
                        fontSize: 16,
                        title: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: onLogin,
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF8F8F8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const CustomText(
                        text: 'Login',
                        color: Color(0xFF404040),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
