import 'package:cloud_firestore/cloud_firestore.dart';

class CynkUser {
  CynkUser({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.lastSeen,
    required this.email,
  });

  factory CynkUser.fromDocument(String id, Map<String, dynamic> doc) {
    return CynkUser(
      id: id,
      name: doc['name'] as String,
      photoUrl: doc['photoUrl'] as String,
      lastSeen: (doc['lastSeen'] as Timestamp).toDate(),
      email: doc['email'] as String,
    );
  }

  final String id;
  final String name;
  final String photoUrl;
  final DateTime lastSeen;
  final String email;
}
