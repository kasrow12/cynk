import 'dart:io';
import 'dart:typed_data';

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
        .limit(30) // TODO
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
    int limit,
  ) async {
    final messages = await db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('date', descending: true)
        .startAfter([lastMessage.date])
        .limit(limit)
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

  // Stream<Chat> getChat(String chatId, String userId) {
  //   final chatDoc = db.collection('chats').doc(chatId).snapshots();

  //   return chatDoc.switchMap((chatDoc) {
  //     if (!chatDoc.exists) {
  //       return Stream.error(Exception('Chat not found'));
  //     }

  //     final chatData = chatDoc.data()!;

  //     if (chatData['type'] == 'private') {
  //       final otherUserId = (chatData['members'] as List<dynamic>)
  //           .firstWhere((uid) => uid != userId)
  //           .toString();

  //       final otherUserDoc =
  //           db.collection('users').doc(otherUserId).snapshots();

  //       return otherUserDoc.map((userDoc) {
  //         if (!userDoc.exists) {
  //           throw Exception('User not found');
  //         }

  //         return PrivateChat(
  //           id: chatId,
  //           lastMessage: Message.fromDocument(
  //             id: chatData['lastMessageId'] as String,
  //             doc: chatData['lastMessage'] as Map<String, dynamic>,
  //             userId: userId,
  //           ),
  //           otherUser: CynkUser.fromDocument(otherUserId, userDoc.data()!),
  //         );
  //       });
  //     }

  //     if (chatData['type'] == 'group') {
  //       final memberIds =
  //           List<String>.from(chatData['members'] as List<dynamic>);

  //       final memberStreams = memberIds.map(
  //         (uid) => db.collection('users').doc(uid).snapshots().map((doc) {
  //           if (!doc.exists) {
  //             throw Exception('User not found');
  //           }

  //           return CynkUser.fromDocument(uid, doc.data()!);
  //         }),
  //       );

  //       return Rx.combineLatest(memberStreams, (members) {
  //         return GroupChat(
  //           id: chatId,
  //           lastMessage: Message.fromDocument(
  //             id: chatData['lastMessageId'] as String,
  //             doc: chatData['lastMessage'] as Map<String, dynamic>,
  //             userId: userId,
  //           ),
  //           name: chatData['name'] as String,
  //           photoUrl: chatData['photoUrl'] as String,
  //           members: members,
  //         );
  //       });
  //     }

  //     throw Exception('Invalid chat type ${chatData['type']}');
  //   });
  // }

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
    String? photoUrl,
  }) async {
    await db.runTransaction((transaction) async {
      final chatRef = db.collection('chats').doc(chatId);
      final messageRef = chatRef.collection('messages').doc();

      // // if there are no messages, add 'otherUser' field to private chat
      // final chatDoc = await transaction.get(chatRef);
      // if ((chatDoc.data()!['lastMessage'] as Map<String, dynamic>)['id'] ==
      //     FIRST_MESSAGE_ID) {
      //   final otherUserId = chatDoc.data()!['otherUser'] as String;

      //   transaction.update(chatRef, {
      //     'members': [userId, otherUserId],
      //   });
      // }

      final msg = {
        'id': messageRef.id,
        'sender': userId,
        'text': message,
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
    required String fileName,
  }) async {
    final storagePath = 'chats/$chatId/images/$fileName';
    final fileData = await image.readAsBytes();

    // Upload to Firebase Storage
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

  // Future<Map<String, CynkUser>> fetchUsers(List<String> userIds) async {
  //   if (userIds.isEmpty) {
  //     return {};
  //   }
  //   final users = await db
  //       .collection('users')
  //       .where(FieldPath.documentId, whereIn: userIds)
  //       .get();

  //   // Return dictionary of uid: CynkUser
  //   return Map.fromEntries(
  //     users.docs.map(
  //       (doc) => MapEntry(doc.id, CynkUser.fromDocument(doc.id, doc.data())),
  //     ),
  //   );
  // }

  Future<void> addContact(String userId, String id) async {
    if (userId == id) {
      throw Exception('Cannot add self as contact');
    }
    if (id.isEmpty) {
      throw Exception('Cannot add empty contact');
    }

    await db
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .doc(id)
        .get()
        .then((contactDoc) {
      if (contactDoc.exists) {
        throw Exception('Already a contact');
      }
    });

    await db.collection('users').doc(id).get().then((userDoc) {
      if (!userDoc.exists) {
        throw Exception('User not found');
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
          // For private chats, get the other user's name and photo
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

          // For group chats, directly use chat document fields
          // return Stream.value(
          //   ChatDisplay(
          //     id: chatDoc.id,
          //     name: chatData['name'] as String,
          //     photoUrl: chatData['photoUrl'] as String,
          //     lastMessage: Message.fromDocument(
          //       id: chatData['lastMessageId'] as String,
          //       doc: chatData['lastMessage'] as Map<String, dynamic>,
          //       userId: userId,
          //     ),
          //   ),
          // );
        }

        throw Exception('Invalid chat type: ${chatData['type']}');
      });

      // Combine all individual chat streams into a list of ChatDisplay
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
            'id': FIRST_MESSAGE_ID,
            'date': DateTime.now(),
            'sender': userId,
            'text': 'Chat created',
          },
        },
      );
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
