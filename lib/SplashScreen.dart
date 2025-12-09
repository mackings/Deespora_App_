import 'package:dspora/App/View/Auth/View/onboarding.dart';
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
        _navigateToHome();
      });
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3)); // match video length
    if (!mounted) return;

    // ✅ Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Onboarding()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // fills empty edges cleanly
      body: _controller.value.isInitialized
          ? SizedBox.expand(
              child: FittedBox(
               fit: BoxFit.contain, // ✅ PREVENTS over-zoom
                child: SizedBox(
                  width: _controller.value.size.width,
                 height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}