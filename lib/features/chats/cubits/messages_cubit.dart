import 'dart:async';

import 'package:cynk/constants.dart';
import 'package:cynk/features/chats/classes/message.dart';
import 'package:cynk/features/data/firestore_data_source.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit({
    required this.dataSource,
    required this.userId,
    required this.chatId,
  }) : super(MessagesLoading());

  final FirestoreDataSource dataSource;
  final String userId;
  final String chatId;
  StreamSubscription<List<Message>>? _messagesSubscription;

  void loadMessages() {
    _messagesSubscription?.cancel();
    emit(MessagesLoading());

    _messagesSubscription = dataSource.getMessagesStream(chatId, userId).listen(
      (messages) {
        emit(MessagesLoaded(messages: messages));
      },
      onError: (Object error) => emit(MessagesError(error.toString())),
    );
  }

  Future<void> loadMoreMessages() async {
    if (state is! MessagesLoaded) {
      return;
    }

    final currentState = state as MessagesLoaded;
    if (!currentState.hasMore || currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final messages = currentState.messages;
    final lastMessage = messages.last;

    return dataSource
        .getMessages(chatId, userId, lastMessage)
        .then((newMessages) {
      if (newMessages.length < MESSAGES_LOAD_LIMIT) {
        emit(
          currentState.copyWith(
            messages: messages + newMessages,
            hasMore: false,
            isLoadingMore: false,
          ),
        );
      } else {
        emit(
          currentState.copyWith(
            messages: messages + newMessages,
            isLoadingMore: false,
          ),
        );
      }
    }).catchError((Object error) {
      emit(MessagesError(error.toString()));
    });
  }

  Future<void> sendMessage(String text) {
    return dataSource.sendMessage(
      chatId: chatId,
      userId: userId,
      message: text,
    );
  }

  Future<void> sendImage(XFile image) {
    return dataSource.sendPhotoMessage(
      chatId: chatId,
      userId: userId,
      image: image,
    );
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}

sealed class MessagesState {}

class MessagesLoading extends MessagesState {}

class MessagesLoaded extends MessagesState {
  MessagesLoaded({
    required this.messages,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final List<Message> messages;
  final bool hasMore;
  final bool isLoadingMore;

  MessagesLoaded copyWith({
    List<Message>? messages,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return MessagesLoaded(
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class MessagesError extends MessagesState {
  MessagesError(this.error);

  final String error;
}
