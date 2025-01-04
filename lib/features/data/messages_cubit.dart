import 'dart:async';

import 'package:cynk/features/data/firestore_data_source.dart';
import 'package:cynk/features/data/message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit({
    required this.dataSource,
    required this.userId,
  }) : super(MessagesLoading());

  final FirestoreDataSource dataSource;
  final String userId;
  StreamSubscription<List<Message>>? _messagesSubscription;

  void openChat(String chatId) {
    _messagesSubscription?.cancel();
    emit(MessagesLoading());

    _messagesSubscription =
        dataSource.getChatStream(chatId, userId).listen((messages) {
      emit(MessagesLoaded(messages));
    }, onError: (error) => emit(MessagesError(error.toString())));
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
  MessagesLoaded(this.messages);

  final List<Message> messages;
}

class MessagesError extends MessagesState {
  MessagesError(this.error);

  final String error;
}
