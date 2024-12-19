class User {
  User({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.lastSeen,
  });

  final String id;
  final String name;
  final String photoUrl;
  final DateTime lastSeen;
}
