import 'dart:async';

import 'package:cynk/features/chats/classes/chat.dart';
import 'package:cynk/features/data/firestore_data_source.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatsCubit extends Cubit<ChatsState> {
  ChatsCubit({
    required this.db,
    required this.userId,
  }) : super(ChatsLoading());

  final String userId;
  final FirestoreDataSource db;
  StreamSubscription<List<Chat>>? _chatsSubscription;

  void loadChats() {
    _chatsSubscription?.cancel();
    emit(ChatsLoading());

    _chatsSubscription = db.getChats(userId).listen(
      (chats) {
        emit(ChatsLoaded(userId, chats));
      },
      onError: (Object error) {
        emit(ChatsError(error.toString()));
      },
    );
  }

  void createPrivateChat(String chatId) {
    db.createPrivateChat(userId, chatId);
  }
}

sealed class ChatsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatsLoading extends ChatsState {}

class ChatsEmpty extends ChatsState {}

class ChatsLoaded extends ChatsState {
  ChatsLoaded(this.userId, this.chats);

  final String userId;
  final List<Chat> chats;

  @override
  List<Object?> get props => [userId, chats];
}

class ChatsError extends ChatsState {
  ChatsError(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}
