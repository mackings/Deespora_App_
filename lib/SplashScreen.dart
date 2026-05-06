import 'package:dspora/App/Services/DiscoveryPreloader.dart';
import 'package:dspora/App/View/Auth/Api/AuthService.dart';
import 'package:dspora/App/View/Auth/View/onboarding.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/Homepage.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.warmUpOverride,
    this.isLoggedInOverride,
    this.enableVideo = true,
    this.navigationDelay = const Duration(seconds: 3),
  });

  final Future<void> Function()? warmUpOverride;
  final Future<bool> Function()? isLoggedInOverride;
  final bool enableVideo;
  final Duration navigationDelay;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _controller;
  final AuthApi _authApi = AuthApi(); // Add this
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Start discovery/API warm-up immediately on app launch for all users.
    debugPrint('🚀 App launch: requesting background discovery warm-up');
    unawaited(
      _warmUp().catchError((error) {
        debugPrint('⚠️ Launch preload failed: $error');
      }),
    );

    // ✅ Immersive fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    if (!widget.enableVideo) {
      _checkAuthAndNavigate();
      return;
    }

    _controller = VideoPlayerController.asset('assets/vid/deespora.mp4')
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller?.play();
        _checkAuthAndNavigate(); // Changed from _navigateToHome
      });
  }

  void _checkAuthAndNavigate() {
    _navigationTimer?.cancel();
    _navigationTimer = Timer(widget.navigationDelay, () async {
      if (!mounted) return;

      // ✅ Restore system UI
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      // Check if user is logged in
      final isLoggedIn =
          await (widget.isLoggedInOverride?.call() ?? _authApi.isLoggedIn());

      if (!mounted) return;

      if (isLoggedIn) {
        try {
          await _warmUp();
        } catch (e) {
          debugPrint('⚠️ Startup personalization preload failed: $e');
        }

        if (!mounted) return;

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
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _warmUp() {
    return widget.warmUpOverride?.call() ?? DiscoveryPreloader.warmUp();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableVideo) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: _controller != null && _controller!.value.isInitialized
          ? Center(
              child: ClipRect(
                child: Transform.scale(
                  // Slight zoom to hide any thin letterbox lines in the video itself.
                  scale: 1.02,
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
