import 'package:flutter/material.dart';
import '../config/network_config.dart';

/// Reusable network image widget with fallback for missing images
/// Automatically corrects image URLs based on device type
class CustomNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final String fallbackText;
  final bool showText;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.fallbackText = "No Image Available",
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    // If imageUrl is null or empty, show fallback immediately
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallbackWidget();
    }

    // ============================================
    // Use NetworkConfig to correct the image URL
    // This ensures images work on both emulator and physical device
    // ============================================
    final correctedUrl = NetworkConfig.getImageUrl(imageUrl!);

    return Image.network(
      correctedUrl,
      height: height,
      width: width,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: height,
          width: width,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackWidget();
      },
    );
  }

  Widget _buildFallbackWidget() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: (height ?? 140) * 0.3,
              color: Colors.grey[400],
            ),
            if (showText) ...[
              const SizedBox(height: 8),
              Text(
                fallbackText,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}