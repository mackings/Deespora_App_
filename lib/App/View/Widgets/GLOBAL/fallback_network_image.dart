import 'package:flutter/material.dart';

class FallbackNetworkImage extends StatefulWidget {
  final List<String> imageUrls;
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final WidgetBuilder? placeholderBuilder;
  final VoidCallback? onAllCandidatesFailed;

  const FallbackNetworkImage({
    super.key,
    required this.imageUrls,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderBuilder,
    this.onAllCandidatesFailed,
  });

  @override
  State<FallbackNetworkImage> createState() => _FallbackNetworkImageState();
}

class _FallbackNetworkImageState extends State<FallbackNetworkImage> {
  late List<String> _imageUrls;
  int _currentIndex = 0;
  bool _reportedFailure = false;

  @override
  void initState() {
    super.initState();
    _imageUrls = _normalizeUrls(widget.imageUrls);
  }

  @override
  void didUpdateWidget(covariant FallbackNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrls != widget.imageUrls ||
        oldWidget.assetPath != widget.assetPath) {
      _imageUrls = _normalizeUrls(widget.imageUrls);
      _currentIndex = 0;
      _reportedFailure = false;
    }
  }

  List<String> _normalizeUrls(List<String> urls) {
    final seen = <String>{};
    final normalized = <String>[];

    for (final url in urls) {
      final value = url.trim();
      final uri = Uri.tryParse(value);
      final isHttp =
          uri != null &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty;
      if (isHttp && seen.add(value)) {
        normalized.add(value);
      }
    }

    return normalized;
  }

  void _advanceImage() {
    if (!mounted || _currentIndex >= _imageUrls.length) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _currentIndex += 1;
      });
    });
  }

  Widget _buildAssetImage() {
    if (!_reportedFailure) {
      _reportedFailure = true;
      widget.onAllCandidatesFailed?.call();
    }

    return Image.asset(
      widget.assetPath,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= _imageUrls.length) {
      return _buildAssetImage();
    }

    final imageUrl = _imageUrls[_currentIndex];

    return Image.network(
      imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        if (widget.placeholderBuilder != null) {
          return widget.placeholderBuilder!(context);
        }
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        _advanceImage();
        return _buildAssetImage();
      },
    );
  }
}
