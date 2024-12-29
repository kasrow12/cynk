import 'package:Cynk/features/data/firestore_data_source.dart';
import 'package:Cynk/features/data/message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit({required this.dataSource}) : super(MessagesLoading()) {
    loadMessages('akrv170TpAgrEO4cvo35VZg76i42'); // wrzucić w chat_screen.dart
  }

  final FirestoreDataSource dataSource;

  Future<void> loadMessages(String chatId) async {
    emit(MessagesLoading());

    try {
      final messages = await dataSource.getChat(chatId);
      // final messages = await dataSource.getChat('akrv170TpAgrEO4cvo35VZg76i42');

      emit(MessagesLoaded(messages));
    } catch (e) {
      emit(MessagesError(e.toString()));
    }
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
