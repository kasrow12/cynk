import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:universal_html/html.dart' as html;

Future<void> downloadImage(String imageUrl, BuildContext context) async {
  try {
    final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

    if (kIsWeb) {
      final anchor = html.AnchorElement(href: imageUrl)
        ..setAttribute(
          'download',
          fileName,
        )
        ..style.display = 'none';

      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
    } else {
      // For Android 13 and above
      if (Platform.isAndroid) {
        final photos = await Permission.photos.request();
        if (!photos.isGranted) {
          // Show settings dialog if permission is permanently denied
          if (photos.isPermanentlyDenied) {
            if (context.mounted) {
              final shouldOpenSettings = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Storage Permission Required'),
                  content: const Text(
                    'Please grant storage permission from settings to download images.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Open Settings'),
                    ),
                  ],
                ),
              );
              if (shouldOpenSettings ?? false) {
                await openAppSettings();
              }
            }
            return;
          }
          throw Exception('Storage permission denied');
        }
      }

      final dio = Dio();
      Directory? directory;

      directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        directory = await getExternalStorageDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      final filePath = '${directory.path}/$fileName';

      await dio.download(
        imageUrl,
        filePath,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image downloaded to ${directory.path}')),
        );
      }
    }
  } catch (err) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download image: $err')),
      );
    }
  }
}

void showImageViewerDialog(BuildContext context, String imageUrl) {
  showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          PhotoView(
            imageProvider: CachedNetworkImageProvider(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.download,
                    color: Colors.white,
                  ),
                  onPressed: () => downloadImage(imageUrl, context),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
