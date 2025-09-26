
import 'package:flutter/material.dart';


class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? text;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    trackGap: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                  if (text != null) ...[
                    const SizedBox(height: 16),
                  ]
                ],
              ),
            ),
          ),
      ],
    );
  }
}
