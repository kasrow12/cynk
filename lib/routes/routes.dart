import 'package:cynk/screens/chat/chat_screen.dart';
import 'package:cynk/screens/chats/chats_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'routes.g.dart';

@TypedGoRoute<HomeRoute>(path: '/', routes: [
  TypedGoRoute<ChatRoute>(
    path: '/chat/:chatId',
  )
])
class HomeRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChatsScreen();
  }
}

class ChatRoute extends GoRouteData {
  ChatRoute({required this.chatId});

  final String chatId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChatScreen(chatId: chatId);
  }
}
