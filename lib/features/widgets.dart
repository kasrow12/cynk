import 'package:cached_network_image/cached_network_image.dart';
import 'package:cynk/features/data/cynk_user.dart';
import 'package:cynk/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class TrimmedText extends StatelessWidget {
  const TrimmedText({
    super.key,
    required this.text,
    this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}

class CynkTile extends StatelessWidget {
  const CynkTile({
    super.key,
    required this.photoUrl,
    required this.name,
    required this.subtitle,
    required this.onTap,
  });

  final String photoUrl;
  final String name;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: CachedNetworkImageProvider(photoUrl),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TrimmedText(
                text: name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              TrimmedText(
                text: subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserItem extends StatelessWidget {
  const UserItem({
    super.key,
    required this.user,
  });

  final CynkUser user;

  @override
  Widget build(BuildContext context) {
    return CynkTile(
      photoUrl: user.photoUrl,
      name: user.name,
      subtitle: 'widziano ${timeago.format(user.lastSeen, locale: 'pl')}',
      onTap: () => ProfileRoute(userId: user.id).go(context),
    );
  }
}

class GroupItem extends StatelessWidget {
  const GroupItem({
    super.key,
    required this.name,
    required this.photoUrl,
    required this.count,
  });

  final String name;
  final String photoUrl;
  final int count;

  @override
  Widget build(BuildContext context) {
    return CynkTile(
      photoUrl: photoUrl,
      name: name,
      subtitle: '$count members',
      onTap: () {}, // group members not implemented
    );
  }
}
