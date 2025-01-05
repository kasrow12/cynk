class CynkUser {
  CynkUser({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.lastSeen,
  });

  final String id;
  final String name;
  final String photoUrl;
  final DateTime lastSeen;

  static CynkUser fromDocument(String id, Map<String, dynamic> doc) {
    return CynkUser(
      id: id,
      name: doc['name'],
      photoUrl: doc['photoUrl'],
      lastSeen: doc['lastSeen'].toDate(),
    );
  }
}
