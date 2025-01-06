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

  void loadChats(String userId) {
    _chatsSubscription?.cancel();
    emit(ChatsLoading());

    db.collection('users').doc(userId).get().then(
      (userDoc) {
        final chatIds = List<String>.from(userDoc.data()?['chats']);

        _chatsSubscription = db
            .collection('chats')
            .where(FieldPath.documentId, whereIn: chatIds)
            // .orderBy('lastMessageDate', descending: true) nie działa
            .snapshots()
            .listen(
          (snapshot) async {
            final chats = snapshot.docs
                .map(
                  (doc) => Chat(
                    id: doc.id,
                    name: doc.data()['name'] as String,
                    photoUrl: doc.data()['photoUrl'] as String,
                    members: List<String>.from(doc.data()['members']),
                    lastMessage: Message(
                      message: doc.data()['lastMessage']['text'] as String,
                      time: doc.data()['lastMessage']['date'].toDate(),
                      sender: doc.data()['lastMessage']['sender'] as String,
                      isSentByUser:
                          doc.data()['lastMessage']['sender'] == userId,
                    ),
                  ),
                )
                .toList()
              ..sort(
                  (a, b) => b.lastMessage.time.compareTo(a.lastMessage.time));

            final userIds = chats.expand((chat) => chat.members).toSet();

            final userDocs = await db
                .collection('users')
                .where(FieldPath.documentId, whereIn: userIds)
                .get();

            final users = Map.fromEntries(
              userDocs.docs.map((doc) =>
                  MapEntry(doc.id, CynkUser.fromDocument(doc.id, doc.data()))),
            );

            emit(ChatsLoaded(userId, chats, users));
          },
          onError: (error) => emit(ChatsError(error.toString())),
        );
      },
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
