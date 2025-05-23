import 'package:cached_network_image/cached_network_image.dart';
import 'package:cynk/features/chats/classes/message.dart';
import 'package:cynk/utils/image_dialog.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  const MessageTile({
    super.key,
    required this.message,
  });

  final Message message;

  static const EdgeInsets sentByUserPadding = EdgeInsets.only(left: 30);
  static const EdgeInsets sentByOtherPadding = EdgeInsets.only(right: 30);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: message.isSentByUser ? sentByUserPadding : sentByOtherPadding,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: message.isSentByUser ? Colors.green[700] : Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (message.photoUrl != null)
                  GestureDetector(
                    onTap: () =>
                        showImageViewerDialog(context, message.photoUrl!),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width *
                            0.6, // Limit width
                        maxHeight: MediaQuery.of(context).size.height *
                            0.4, // Limit height
                      ),
                      child: CachedNetworkImage(
                        imageUrl: message.photoUrl!,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const SizedBox(
                          width: 100,
                          height: 100,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                if (message.photoUrl == null)
                  Text(
                    message.message,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                const SizedBox(height: 5),
                Text(
                  '${message.date.hour.toString().padLeft(2, '0')}:${message.date.minute.toString().padLeft(2, '0')}',
                  // message.time.toString(),
                  style: TextStyle(
                    color: message.isSentByUser
                        ? Colors.grey[300]
                        : Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
