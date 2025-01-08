import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cynk/features/data/chat.dart';
import 'package:cynk/features/data/message.dart';
import 'package:cynk/features/data/cynk_user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatsCubit extends Cubit<ChatsState> {
  ChatsCubit({required this.db}) : super(ChatsLoading());
  final FirebaseFirestore db;

  StreamSubscription? _chatsSubscription;
  StreamSubscription? _usersSubscription;

  Map<String, CynkUser> users = {};
  List<Chat> chats = [];

  void loadChats(String userId) {
    _chatsSubscription?.cancel();
    _usersSubscription?.cancel();
    emit(ChatsLoading());

    _chatsSubscription = db
        .collection('chats')
        .where('members', arrayContains: userId)
        .snapshots()
        .listen(
      (snapshot) async {
        // accumulate all user ids in chats
        final userIds =
            snapshot.docs.expand((doc) => doc.data()['members']).toSet();

        final missingUsers = userIds.where((uid) => !users.containsKey(uid));

        // download missing users and add them to users set
        if (missingUsers.isNotEmpty) {
          final userDocs = await db
              .collection('users')
              .where(FieldPath.documentId, whereIn: missingUsers)
              .get();

          users.addAll(Map.fromEntries(userDocs.docs.map(
            (doc) =>
                MapEntry(doc.id, CynkUser.fromDocument(doc.id, doc.data())),
          )));
        }

        chats = snapshot.docs
            .map(
              (doc) => switch (doc.data()['type']) {
                'private' => PrivateChat(
                    id: doc.id,
                    lastMessage:
                        Message.fromDocument(doc.data()['lastMessage'], userId),
                    otherUser: users[(doc.data()['members'])
                        .firstWhere((uid) => uid != userId)]!, // check null
                  ),
                'group' => GroupChat(
                    id: doc.id,
                    name: doc.data()['name'] as String,
                    lastMessage:
                        Message.fromDocument(doc.data()['lastMessage'], userId),
                    photoUrl: doc.data()['photoUrl'] as String,
                    members: (doc.data()['members'])
                        .map((uid) => users[uid]!)
                        .toList()),
                _ => throw Exception('Invalid chat type ${doc.data()['type']}'),
              },
            )
            .toList()
          ..sort((a, b) => b.lastMessage.time.compareTo(a.lastMessage.time));

        emit(ChatsLoaded(userId, chats, users));
      },
      onError: (error) => emit(ChatsError(error.toString())),
    );

    _usersSubscription = db.collection('users').snapshots().listen(
      (snapshot) {
        users = Map.fromEntries(snapshot.docs.map(
          (doc) => MapEntry(doc.id, CynkUser.fromDocument(doc.id, doc.data())),
        ));
        emit(ChatsLoaded(userId, chats, users));
      },
      onError: (error) => emit(ChatsError(error.toString())),
    );
  }
}

sealed class ChatsState {}

class ChatsLoading extends ChatsState {}

class ChatsLoaded extends ChatsState {
  ChatsLoaded(this.userId, this.chats, this.users);

  final String userId;
  final List<Chat> chats;
  final Map<String, CynkUser> users;
}

class ChatsError extends ChatsState {
  ChatsError(this.error);

  final String error;
}
