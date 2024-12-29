import 'dart:async';

import 'package:cynk/features/data/firestore_data_source.dart';
import 'package:cynk/features/data/message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit({required this.dataSource}) : super(MessagesLoading()) {
    _messagesSubscription =
        dataSource.getChatStream('a810uxkTnV1E6jkofYYy').listen((messages) {
      print('Messages: ${messages.length}');
      emit(MessagesLoaded(messages));
    });
  }

  final FirestoreDataSource dataSource;
  StreamSubscription<List<Message>>? _messagesSubscription;

  Future<void> loadMessages(String chatId) async {
    emit(MessagesLoading());

    try {
      final messages = await dataSource.getChat(chatId);

      emit(MessagesLoaded(messages));
    } catch (e) {
      emit(MessagesError(e.toString()));
    }
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
