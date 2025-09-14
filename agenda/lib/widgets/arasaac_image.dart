import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

/// Widget per caricare immagini ARASAAC con cache
class ArasaacImage extends ConsumerWidget {
  const ArasaacImage({
    super.key,
    required this.url,
    this.fallbackUrl,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.errorIcon = Icons.broken_image,
  });

  final String url;
  final String? fallbackUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData errorIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Uint8List?>(
      future: ref.read(imageCacheProvider).fetchAndCache(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
          );
        }

        // Se fallisce, prova con fallbackUrl se disponibile
        if (fallbackUrl != null && fallbackUrl != url) {
          return ArasaacImage(
            url: fallbackUrl!,
            width: width,
            height: height,
            fit: fit,
            errorIcon: errorIcon,
          );
        }

        return _buildErrorWidget();
      },
    );
  }

  Widget _buildErrorWidget() {
    return SizedBox(
      width: width,
      height: height,
      child: Icon(
        errorIcon,
        color: Colors.grey,
        size: (width != null && height != null) 
            ? (width! < height! ? width! : height!) * 0.6
            : 32,
      ),
    );
  }
}