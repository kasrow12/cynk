import 'package:cynk/features/chats/chat_screen.dart';
import 'package:cynk/screens/chats/chats_screen.dart';
import 'package:cynk/features/contacts/contacts_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'routes.g.dart';

@TypedGoRoute<HomeRoute>(path: '/', routes: [
  TypedGoRoute<ChatRoute>(
    path: '/chat/:chatId',
  ),
  TypedGoRoute<ContactsRoute>(
    path: '/contacts',
  ),
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

class ContactsRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ContactsScreen();
  }
}
