import 'package:cynk/features/data/cynk_user.dart';
import 'package:cynk/features/chats/chat_screen.dart';
import 'package:flutter/material.dart';

class ContactTile extends StatelessWidget {
  ContactTile({
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
            PopupMenuItem(
              child: Text('View Profile'),
              onTap: () {
                print('View Profile');
              },
            ),
            PopupMenuItem(
              child: Text('Remove Contact'),
              onTap: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
