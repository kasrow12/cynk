import 'package:cynk/features/chats/chat_screen.dart';
import 'package:cynk/features/data/cynk_user.dart';
import 'package:flutter/material.dart';

class ContactTile extends StatelessWidget {
  const ContactTile({
    super.key,
    required this.user,
    required this.onTap,
    required this.onRemove,
  });

  final CynkUser user;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        title: UserItem(user: user),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            // const PopupMenuItem<void>(
            //   child: Text('View Profile'),
            // ),
            PopupMenuItem<void>(
              onTap: onRemove,
              child: const Text('Remove Contact'),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
