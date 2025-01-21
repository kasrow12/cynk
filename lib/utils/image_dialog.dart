import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

void showImageDialog(BuildContext context, String imageUrl) {
  showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          PhotoView(
            imageProvider: CachedNetworkImageProvider(imageUrl),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    ),
  );
}
