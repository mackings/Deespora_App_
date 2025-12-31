import 'package:dspora/App/View/Auth/Api/AuthService.dart';
import 'package:dspora/App/View/Auth/View/onboarding.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/Homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';




class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  final AuthApi _authApi = AuthApi(); // Add this

  @override
  void initState() {
    super.initState();

    // ✅ Immersive fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = VideoPlayerController.asset('assets/vid/deespora.mp4')
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.play();
        _checkAuthAndNavigate(); // Changed from _navigateToHome
      });
  }

  void _checkAuthAndNavigate() async {
    // Wait for video to finish (match your video length)
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // ✅ Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Check if user is logged in
    final isLoggedIn = await _authApi.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      // User is logged in, go directly to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } else {
      // User not logged in, show onboarding/signin
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Onboarding()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _controller.value.isInitialized
          ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: _controller.value.size.width - 20,
                  height: _controller.value.size.height - 20,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}