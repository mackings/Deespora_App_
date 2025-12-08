// ============================================
// 1. Global Review Button Widget
// ============================================
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class GlobalReviewButton extends StatelessWidget {
  final String placeName;
  final String placeAddress;
  final VoidCallback? onPressed;

  const GlobalReviewButton({
    super.key,
    required this.placeName,
    required this.placeAddress,
    this.onPressed,
  });

  Future<void> _openReviewInMaps(BuildContext context) async {
    try {
      final encodedName = Uri.encodeComponent(placeName);
      final encodedAddress = Uri.encodeComponent(placeAddress);
      
      // Google Maps URL for searching and reviewing a place
      final mapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedName+$encodedAddress'
      );

      if (await canLaunchUrl(mapsUrl)) {
        await launchUrl(
          mapsUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open Google Maps'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening Maps: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed ?? () => _openReviewInMaps(context),
      icon: const Icon(Icons.rate_review, size: 20),
      label: const Text('Write Review'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF37B6AF),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }
}

// ============================================
// 2. Global Share Button Widget
// ============================================
class GlobalShareButton extends StatelessWidget {
  final String placeName;
  final String placeAddress;
  final double? rating;
  final String? imageUrl;
  final VoidCallback? onPressed;

  const GlobalShareButton({
    super.key,
    required this.placeName,
    required this.placeAddress,
    this.rating,
    this.imageUrl,
    this.onPressed,
  });

  Future<void> _sharePlace(BuildContext context) async {
    try {
      // Build share message
      final ratingText = rating != null ? '⭐ Rating: $rating/5\n' : '';
      final message = '''
Check out $placeName!

$ratingText📍 Location: $placeAddress

Find it on Google Maps:
https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$placeName $placeAddress')}
''';

      // Share using share_plus package
      await Share.share(
        message,
        subject: 'Check out $placeName',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed ?? () => _sharePlace(context),
      icon: const Icon(Icons.share, size: 20),
      label: const Text('Share'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF37B6AF),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF37B6AF), width: 1.5),
        ),
        elevation: 0,
      ),
    );
  }
}

// ============================================
// 3. Combined Review & Share Action Row
// ============================================
class GlobalReviewShareActions extends StatelessWidget {
  final String placeName;
  final String placeAddress;
  final double? rating;
  final String? imageUrl;
  final VoidCallback? onReviewPressed;
  final VoidCallback? onSharePressed;

  const GlobalReviewShareActions({
    super.key,
    required this.placeName,
    required this.placeAddress,
    this.rating,
    this.imageUrl,
    this.onReviewPressed,
    this.onSharePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: GlobalReviewButton(
              placeName: placeName,
              placeAddress: placeAddress,
              onPressed: onReviewPressed,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GlobalShareButton(
              placeName: placeName,
              placeAddress: placeAddress,
              rating: rating,
              imageUrl: imageUrl,
              onPressed: onSharePressed,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// 4. Compact Icon-Only Version (Alternative)
// ============================================
class GlobalReviewShareIconButtons extends StatelessWidget {
  final String placeName;
  final String placeAddress;
  final double? rating;
  final String? imageUrl;
  final VoidCallback? onReviewPressed;
  final VoidCallback? onSharePressed;

  const GlobalReviewShareIconButtons({
    super.key,
    required this.placeName,
    required this.placeAddress,
    this.rating,
    this.imageUrl,
    this.onReviewPressed,
    this.onSharePressed,
  });

  Future<void> _openReviewInMaps(BuildContext context) async {
    try {
      final encodedName = Uri.encodeComponent(placeName);
      final encodedAddress = Uri.encodeComponent(placeAddress);
      
      final mapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedName+$encodedAddress'
      );

      if (await canLaunchUrl(mapsUrl)) {
        await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open Google Maps'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _sharePlace(BuildContext context) async {
    try {
      final ratingText = rating != null ? '⭐ Rating: $rating/5\n' : '';
      final message = '''
Check out $placeName!

$ratingText📍 Location: $placeAddress

Find it on Google Maps:
https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$placeName $placeAddress')}
''';

      await Share.share(message, subject: 'Check out $placeName');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Review Button
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF37B6AF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: onReviewPressed ?? () => _openReviewInMaps(context),
            icon: const Icon(Icons.rate_review, color: Colors.white),
            tooltip: 'Write Review',
          ),
        ),
        const SizedBox(width: 16),
        // Share Button
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF37B6AF), width: 1.5),
          ),
          child: IconButton(
            onPressed: onSharePressed ?? () => _sharePlace(context),
            icon: const Icon(Icons.share, color: Color(0xFF37B6AF)),
            tooltip: 'Share',
          ),
        ),
      ],
    );
  }
}