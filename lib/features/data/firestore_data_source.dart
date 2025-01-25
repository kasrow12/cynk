import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cynk/constants.dart';
import 'package:cynk/features/chats/classes/chat.dart';
import 'package:cynk/features/chats/classes/message.dart';
import 'package:cynk/features/data/cynk_user.dart';
import 'package:cynk/utils/private_chat_id.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreDataSource {
  FirestoreDataSource({required this.db, required this.storage});

  final FirebaseFirestore db;
  final FirebaseStorage storage;

  Stream<List<Message>> getMessagesStream(String chatId, String userId) {
    return db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('date', descending: true)
        .limit(INITIAL_MESSAGES_LOAD_LIMIT)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Message.fromDocument(
                  id: doc.id,
                  doc: doc.data(),
                  userId: userId,
                ),
              )
              .toList(),
        );
  }

  Future<List<Message>> getMessages(
    String chatId,
    String userId,
    Message lastMessage,
  ) async {
    final messages = await db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('date', descending: true)
        .startAfter([lastMessage.date])
        .limit(MESSAGES_LOAD_LIMIT)
        .get()
        .then((value) => value.docs)
        .then(
          (value) => value
              .map(
                (doc) => Message.fromDocument(
                  id: doc.id,
                  doc: doc.data(),
                  userId: userId,
                ),
              )
              .toList(),
        );

    return messages;
  }

  Stream<CynkUser> getUserStream(String userId) {
    return db
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => CynkUser.fromDocument(doc.id, doc.data()!));
  }

  Future<void> updatePhoto(String userId, XFile image) async {
    final storagePath = 'users/$userId/profile.jpg';
    final fileData = await image.readAsBytes();

    final storageRef = FirebaseStorage.instance.ref().child(storagePath);
    final uploadTask = await storageRef.putData(fileData);

    if (uploadTask.state == TaskState.success) {
      final url = await storageRef.getDownloadURL();

      await db.collection('users').doc(userId).update({
        'photoUrl': url,
      });
    }
  }

  Future<void> updateName(String userId, String name) {
    if (name.isEmpty) {
      throw Exception('Name cannot be empty');
    }

    if (name.length > MAX_NAME_LENGTH) {
      throw Exception('Name is too long');
    }

    return db.collection('users').doc(userId).update({
      'name': name,
    });
  }

  Stream<List<CynkUser>> getContactsStream(String userId) {
    final contactIdsStream = db
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());

    // Transform to stream of user documents
    return contactIdsStream.switchMap((contactIds) {
      if (contactIds.isEmpty) {
        return Stream.value([]);
      }

      final userStreams = contactIds.map(
        (uid) => db
            .collection('users')
            .doc(uid)
            .snapshots()
            .map((doc) => CynkUser.fromDocument(doc.id, doc.data()!)),
      );

      return Rx.combineLatest(userStreams.toList(), (users) => users);
    });
  }

  Future<void> sendMessage({
    required String chatId,
    required String userId,
    required String message,
    String? photoUrl,
  }) async {
    message = message.trim();
    if (message.isEmpty && photoUrl == null) {
      return;
    }

    if (message.length > MAX_MESSAGE_LENGTH) {
      throw Exception('Message is too long');
    }

    await db.runTransaction((transaction) async {
      final chatRef = db.collection('chats').doc(chatId);
      final messageRef = chatRef.collection('messages').doc();

      final msg = {
        'id': messageRef.id,
        'sender': userId,
        'text': message.trim(),
        'date': FieldValue.serverTimestamp(),
        if (photoUrl != null) 'photoUrl': photoUrl,
      };

      transaction
        ..set(messageRef, msg)
        ..update(chatRef, {
          'lastMessage': msg,
        });
    });
  }

  Future<void> sendPhotoMessage({
    required String chatId,
    required String userId,
    required XFile image,
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';

    final storagePath = 'chats/$chatId/images/$fileName';
    final fileData = await image.readAsBytes();

    final storageRef = FirebaseStorage.instance.ref().child(storagePath);
    final uploadTask = await storageRef.putData(fileData);

    if (uploadTask.state == TaskState.success) {
      final downloadUrl = await storageRef.getDownloadURL();

      await sendMessage(
        chatId: chatId,
        userId: userId,
        message: 'Photo',
        photoUrl: downloadUrl,
      );
    }
  }

  Future<void> addContact(String userId, String email) async {
    if (email.isEmpty) {
      throw Exception('Cannot add empty contact');
    }

    final userDoc =
        await db.collection('users').where('email', isEqualTo: email).get();

    if (userDoc.docs.isEmpty) {
      throw Exception('User not found');
    }

    final contactId = userDoc.docs.first.id;

    if (userId == contactId) {
      throw Exception('Cannot add self as contact');
    }

    await db
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .doc(contactId)
        .get()
        .then((contactDoc) {
      if (contactDoc.exists) {
        throw Exception('Already a contact');
      }
    });

    await db.collection('users').doc(contactId).get().then((userDoc) {
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      db
          .collection('users')
          .doc(userId)
          .collection('contacts')
          .doc(contactId)
          .set({});
    });
  }

  Future<void> removeContact(String userId, String id) {
    return db
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .doc(id)
        .delete();
  }

  Stream<List<Chat>> getChats(String userId) {
    final chatDocs = db
        .collection('chats')
        .where('members', arrayContains: userId)
        .orderBy('lastMessage.date', descending: true)
        .snapshots();

    return chatDocs.switchMap((snapshot) {
      if (snapshot.docs.isEmpty) {
        return Stream.value([]);
      }

      final chatStreams = snapshot.docs.map((chatDoc) {
        final chatData = chatDoc.data();

        if (chatData['type'] == 'private') {
          final otherUserId = (chatData['members'] as List<dynamic>)
              .firstWhere((uid) => uid != userId)
              .toString();

          final otherUserDoc =
              db.collection('users').doc(otherUserId).snapshots();

          return otherUserDoc.map((userDoc) {
            if (!userDoc.exists) {
              throw Exception('Other user not found');
            }

            final userData = userDoc.data()!;
            return PrivateChat(
              id: getPrivateChatId(userId, otherUserId),
              lastMessage: Message.fromDocument(
                id: (chatData['lastMessage'] as Map<String, dynamic>)['id']
                    as String,
                doc: chatData['lastMessage'] as Map<String, dynamic>,
                userId: userId,
              ),
              otherUser: CynkUser.fromDocument(otherUserId, userData),
            );
          });
        }
        if (chatData['type'] == 'group') {
          final memberIds =
              List<String>.from(chatData['members'] as List<dynamic>);

          final memberStreams = memberIds.map(
            (uid) => db.collection('users').doc(uid).snapshots().map((doc) {
              if (!doc.exists) {
                throw Exception('User not found');
              }

              return CynkUser.fromDocument(uid, doc.data()!);
            }),
          );

          return Rx.combineLatest(memberStreams, (members) {
            return GroupChat(
              id: chatDoc.id,
              name: chatData['name'] as String,
              photoUrl: chatData['photoUrl'] as String,
              lastMessage: Message.fromDocument(
                id: (chatData['lastMessage'] as Map<String, dynamic>)['id']
                    as String,
                doc: chatData['lastMessage'] as Map<String, dynamic>,
                userId: userId,
              ),
              members: members,
            );
          });
        }

        throw Exception('Invalid chat type: ${chatData['type']}');
      });

      // Combine all individual chat streams into a list of Chat
      return Rx.combineLatest(chatStreams, (chats) => chats);
    });
  }

  Future<void> createPrivateChat(String userId, String chatId) {
    final ids = getUserIdsFromPrivateChatId(chatId);

    final otherUserId = ids.firstWhere((uid) => uid != userId);

    return db.collection('chats').doc(chatId).get().then((chatDoc) {
      if (chatDoc.exists) {
        return;
      }

      db.collection('chats').doc(chatId).set(
        {
          'type': 'private',
          'members': [userId, otherUserId],
          'lastMessage': {
            'id': '-',
            'date': DateTime
                .now(), // instead of FieldValue.serverTimestamp(), because race condition
            'sender': userId,
            'text': 'Chat created',
          },
        },
      );
    });
  }

  Future<void> createAccount({
    required String userId,
    required String email,
    required String username,
    XFile? photo,
  }) async {
    final userDoc = db.collection('users').doc(userId);

    final userDocData = {
      'email': email,
      'username': username,
      'name': username,
      'photoUrl':
          'https://cdn-icons-png.flaticon.com/512/4202/4202841.png', // default photo
      'lastSeen': FieldValue.serverTimestamp(),
    };

    if (photo != null) {
      final storagePath = 'users/$userId/profile.jpg';
      final fileData = await photo.readAsBytes();

      final storageRef = storage.ref().child(storagePath);
      final uploadTask = await storageRef.putData(fileData);

      if (uploadTask.state == TaskState.success) {
        final url = await storageRef.getDownloadURL();
        userDocData['photoUrl'] = url;
      }
    }

    await userDoc.set(userDocData);
  }
}
