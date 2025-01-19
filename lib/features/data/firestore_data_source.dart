import 'package:cynk/features/data/chat.dart';
import 'package:cynk/features/data/cynk_user.dart';
import 'package:cynk/features/data/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cynk/utils/private_chat_id.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreDataSource {
  FirestoreDataSource({required this.db});

  final FirebaseFirestore db;

  Stream<List<Message>> getMessagesStream(String chatId, String userId) {
    return db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('date', descending: true)
        .limit(20) //TODO
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Message.fromDocument(
                    id: doc.id,
                    doc: doc.data(),
                    userId: userId,
                  ))
              .toList(),
        );
  }

  Future<List<Message>> getMessages(
    String chatId,
    String userId,
    Message lastMessage,
    int limit,
  ) async {
    final messages = await db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('date', descending: true)
        .startAfter([lastMessage.time])
        .limit(limit)
        .get()
        .then((value) => value.docs)
        .then((value) => value
            .map((doc) => Message.fromDocument(
                  id: doc.id,
                  doc: doc.data(),
                  userId: userId,
                ))
            .toList());

    return messages;
  }

  Stream<List<CynkUser>> getContactsStream(String userId) {
    // Stream of contact IDs
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

      final userStreams = contactIds.map((uid) => db
          .collection('users')
          .doc(uid)
          .snapshots()
          .map((doc) => CynkUser.fromDocument(doc.id, doc.data()!)));

      return Rx.combineLatest(userStreams.toList(), (users) => users);
    });
  }

  Stream<Chat> getChat(String chatId, String userId) {
    final chatDoc = db.collection('chats').doc(chatId).snapshots();

    return chatDoc.switchMap((chatDoc) {
      if (!chatDoc.exists) {
        return Stream.error(Exception('Chat not found'));
      }

      final chatData = chatDoc.data()!;

      if (chatData['type'] == 'private') {
        final otherUserId =
            chatData['members'].firstWhere((uid) => uid != userId); // null?

        final otherUserDoc =
            db.collection('users').doc(otherUserId).snapshots();

        return otherUserDoc.map((userDoc) {
          if (!userDoc.exists) {
            throw Exception('User not found');
          }

          return PrivateChat(
            id: chatId,
            lastMessage: Message.fromDocument(
              id: chatData['lastMessageId'],
              doc: chatData['lastMessage'],
              userId: userId,
            ),
            otherUser: CynkUser.fromDocument(otherUserId, userDoc.data()!),
          );
        });
      }

      if (chatData['type'] == 'group') {
        final memberIds = List<String>.from(chatData['members']);

        final memberStreams = memberIds.map(
            (uid) => db.collection('users').doc(uid).snapshots().map((doc) {
                  if (!doc.exists) {
                    throw Exception('User not found');
                  }

                  return CynkUser.fromDocument(uid, doc.data()!);
                }));

        return Rx.combineLatest(memberStreams, (members) {
          return GroupChat(
            id: chatId,
            lastMessage: Message.fromDocument(
              id: chatData['lastMessageId'],
              doc: chatData['lastMessage'],
              userId: userId,
            ),
            name: chatData['name'],
            photoUrl: chatData['photoUrl'],
            members: members,
          );
        });
      }

      throw Exception('Invalid chat type ${chatData['type']}');
    });
  }

  // Stream<List<ChatDisplay>> getChatsBetter(String userId) {
  //   // use chatdisplay class, for private chats get also stream of other user to update the name/profilephoto,
  //   // for group chats you only

  //   final chatDocs = db
  //       .collection('chats')
  //       .where('members', arrayContains: userId)
  //       .snapshots();

  //   return chatDocs.switchMap((snapshot) {

  // }

// previous version had
// _chatsSubscription = db
  //     .collection('chats')
  //     .where('members', arrayContains: userId)
  // Stream<List<Chat>> getChats(String userId) {
  //   // get chats where user is a member
  //   // then use getChat function
  //   final chatDocs = db
  //       .collection('chats')
  //       .where('members', arrayContains: userId)
  //       .snapshots();

  //   return chatDocs.switchMap((snapshot) {
  //     final chatStreams = snapshot.docs.map((doc) {
  //       final chatId = doc.id;
  //       return getChat(chatId, userId);
  //     });

  //     return Rx.combineLatest(chatStreams.toList(), (chats) => chats);
  //   });
  // }

  Future<void> sendMessage({
    required String chatId,
    required String userId,
    required String message,
  }) async {
    final date = DateTime.now();

    await db.runTransaction((transaction) async {
      final chatRef = db.collection('chats').doc(chatId);
      final messageRef = chatRef.collection('messages').doc();

      final msg = {
        'sender': userId,
        'text': message,
        'date': date,
      };

      transaction.set(messageRef, msg);

      transaction.update(chatRef, {
        'lastMessage': msg,
      });
    });
  }

  Future<Map<String, CynkUser>> fetchUsers(List<String> id) async {
    if (id.isEmpty) {
      return {};
    }
    final users = await db
        .collection('users')
        .where(FieldPath.documentId, whereIn: id)
        .get();

    // return dictionary of uid: CynkUser
    return Map.fromEntries(users.docs.map(
      (doc) => MapEntry(doc.id, CynkUser.fromDocument(doc.id, doc.data())),
    ));

    // if (!userDoc.exists) {
    //   throw Exception('User not found');
    // }

    // return CynkUser.fromDocument(userDoc.id, userDoc.data()!);
  }

  Future<void> addContact(String userId, String id) async {
    if (userId == id) {
      throw ErrorDescription('Error: Cannot add self as contact');
    }
    if (id.isEmpty) {
      throw ErrorDescription('Error: Cannot add empty contact');
    }

    await db
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .doc(id)
        .get()
        .then((contactDoc) {
      if (contactDoc.exists) {
        throw ErrorDescription('Already a contact');
      }
    });

    await db.collection('users').doc(id).get().then((userDoc) {
      if (!userDoc.exists) {
        throw ErrorDescription('User not found');
      }

      db.collection('users').doc(userId).collection('contacts').doc(id).set({});
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

  Stream<List<ChatDisplay>> getChatDisplays(String userId) {
    final chatDocs = db
        .collection('chats')
        .where('members', arrayContains: userId)
        .orderBy('lastMessage.date', descending: true)
        .snapshots();

    return chatDocs.switchMap((snapshot) {
      final chatStreams = snapshot.docs.map((chatDoc) {
        final chatData = chatDoc.data();

        if (chatData['type'] == 'private') {
          // For private chats, get the other user's name and photo
          final otherUserId = chatData['members']
              .firstWhere((uid) => uid != userId, orElse: () => null);

          if (otherUserId == null) {
            throw Exception('Invalid private chat with no other user.');
          }

          final otherUserDoc =
              db.collection('users').doc(otherUserId).snapshots();

          return otherUserDoc.map((userDoc) {
            if (!userDoc.exists) {
              throw Exception('Other user not found');
            }

            final userData = userDoc.data()!;
            return ChatDisplay(
              id: getPrivateChatId(userId, otherUserId),
              name: userData['name'],
              photoUrl: userData['photoUrl'],
              lastMessage: Message.fromDocument(
                id: chatData['lastMessageId'],
                doc: chatData['lastMessage'],
                userId: userId,
              ),
            );
          });
        }
        if (chatData['type'] == 'group') {
          // For group chats, directly use chat document fields
          return Stream.value(ChatDisplay(
            id: chatDoc.id,
            name: chatData['name'],
            photoUrl: chatData['photoUrl'],
            lastMessage: Message.fromDocument(
              id: chatData['lastMessageId'],
              doc: chatData['lastMessage'],
              userId: userId,
            ),
          ));
        }

        throw Exception('Invalid chat type: ${chatData['type']}');
      });

      // Combine all individual chat streams into a list of ChatDisplay
      return Rx.combineLatest(chatStreams, (chatDisplays) => chatDisplays);
    });
  }

  // Future<List<Message>> getChat(String chatId) async {
  //   final chat = await db.collection('chats').doc(chatId).get();

  //   final msgs = await chat.reference
  //       .collection('messages')
  //       .orderBy('date', descending: true)
  //       .get()
  //       .then((value) => value.docs)
  //       .then((value) => value
  //           .map((doc) => Message(
  //                 message: doc['text'],
  //                 time: doc['date'].toDate(),
  //                 isSentByUser: true,
  //               ))
  //           .toList());

  //   return msgs;
  // }
  // List<Message> getChat(String userId) {
  //   final chat = db
  //       .collection('chats')
  //       .where('users', arrayContains: userId)
  //       .get()
  //       .then((value) => value.docs);

  //   // print createdat
  //   // print(chat.docs[0].data()['createdBy']);

  //   // final messages = chat.docs[0].reference.collection('messages').get();
  //   // final messages =

  //   final msgs = chat
  //       .then((value) => value[0].reference.collection('messages').get())
  //       .then((value) => value.docs)
  //       .then((value) => value
  //           .map((doc) => Message(
  //                 message: doc['text'],
  //                 time: doc['date'].toDate(),
  //                 isSentByUser: doc['sender'] == userId,
  //               ))
  //           .toList());

  //   return msgs;
  // return Chat(
  //   user: User(
  //     id: userId,
  //     name: user['name'],
  //     photoUrl: user['photoUrl'],
  //     lastSeen: user['lastSeen'],
  //   ),
  //   messages: messages.docs
  //       .map((doc) => Message(
  //             message: doc['message'],
  //             time: doc['time'].toDate(),
  //             isSentByUser: doc['sender'] == userId,
  //           ))
  //       .toList(),
  // );
  // }
}

class ChatDisplay {
  ChatDisplay({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.lastMessage,
  });

  final String id;
  final String name;
  final String photoUrl;
  final Message lastMessage;
}
