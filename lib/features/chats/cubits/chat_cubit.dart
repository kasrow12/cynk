import 'dart:async';

import 'package:cynk/features/chats/classes/chat.dart';
import 'package:cynk/features/data/firestore_data_source.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required this.dataSource,
    required this.userId,
    required this.chatId,
  }) : super(ChatLoading());

  final FirestoreDataSource dataSource;
  final String userId;
  final String chatId;
  StreamSubscription<Chat>? _chatSubscription;

  void openChat() {
    _chatSubscription?.cancel();
    emit(ChatLoading());

    _chatSubscription = dataSource.getChat(chatId, userId).listen(
      (chat) {
        emit(ChatLoaded(chat, userId));
      },
      onError: (Object error) => emit(ChatError(error.toString())),
    );
  }

  @override
  Future<void> close() {
    _chatSubscription?.cancel();
    return super.close();
  }
}

sealed class ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  ChatLoaded(this.chat, this.userId);

  final String userId;
  final Chat chat;
}

class ChatError extends ChatState {
  ChatError(this.error);

  final String error;
}
