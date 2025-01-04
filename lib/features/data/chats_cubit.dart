import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cynk/features/data/chat.dart';
import 'package:cynk/features/data/message.dart';
import 'package:cynk/features/data/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatsCubit extends Cubit<ChatsState> {
  ChatsCubit({required this.db}) : super(ChatsLoading());
  final FirebaseFirestore db;

  StreamSubscription<List<Chat>>? _chatsSubscription;

  void loadChats(String userId) {
    _chatsSubscription?.cancel();
    emit(ChatsLoading());

    // user has array with ids of chats
    // chats is separate collection
    // return list of chats mentioned in user's field chats
    // chat doesnt have users field

    db.collection('users').doc(userId).get().then(
      (userDoc) {
        final chatIds = List<String>.from(userDoc.data()?['chats']);
        print(chatIds);
        print(chatIds.runtimeType);

        _chatsSubscription = db
            .collection('chats')
            .where(FieldPath.documentId, whereIn: chatIds)
            .snapshots()
            .map(
              (snapshot) => snapshot.docs.map(
                (doc) {
                  final chat = Chat(
                    id: doc.id,
                    name: doc.data()['name'] as String,
                    photoUrl: doc.data()['photoUrl'] as String,
                    lastMessage: Message(
                      message: doc.data()['lastMessage']['text'] as String,
                      time: doc.data()['lastMessage']['date'].toDate(),
                      sender: doc.data()['lastMessage']['sender'] as String,
                      isSentByUser:
                          doc.data()['lastMessage']['sender'] == userId,
                    ),
                  );
                  return chat;
                },
              ).toList(),
            )
            .listen(
              (chats) => emit(ChatsLoaded(chats)),
              onError: (error) => emit(ChatsError(error.toString())),
            );
      },
    );
  }
}

sealed class ChatsState {}

class ChatsLoading extends ChatsState {}

class ChatsLoaded extends ChatsState {
  ChatsLoaded(this.chats);

  final List<Chat> chats;
}

class ChatsError extends ChatsState {
  ChatsError(this.error);

  final String error;
}
