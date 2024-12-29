import 'package:Cynk/features/data/firestore_data_source.dart';
import 'package:Cynk/features/data/message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit({required this.dataSource}) : super(MessagesLoading()) {
    loadMessages();
  }

  final FirestoreDataSource dataSource;

  Future<void> loadMessages() async {
    emit(MessagesLoading());

    final messages = await dataSource.getChat('akrv170TpAgrEO4cvo35VZg76i42');

    emit(MessagesLoaded(messages));
  }
}

sealed class MessagesState {}

class MessagesLoading extends MessagesState {}

class MessagesLoaded extends MessagesState {
  MessagesLoaded(this.messages);

  final List<Message> messages;
}
