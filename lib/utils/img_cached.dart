import 'package:bananagram/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
class CachedImage extends StatelessWidget {
  final String? imageUrl;
  const CachedImage(this.imageUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const Icon(Icons.image_not_supported, color: Colors.grey);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: LoadingWidget()
      ),
      errorWidget: (context, url, error) =>
      const Icon(Icons.error, color: Colors.red),
    );
  }
}
