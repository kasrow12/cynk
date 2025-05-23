import 'package:cynk/features/data/cynk_user.dart';
import 'package:cynk/features/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
              child: Text(AppLocalizations.of(context)!.removeContact),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
