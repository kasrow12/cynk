import 'package:cynk/features/auth/auth_gate.dart';
import 'package:cynk/features/data/user.dart';
import 'package:cynk/screens/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'routes.g.dart';

@TypedGoRoute<AuthGateRoute>(path: '/', routes: [
  TypedGoRoute<ChatRoute>(
    path: '/chat/:chatId',
  )
])
class AuthGateRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return AuthGate();
  }
}

class ChatRoute extends GoRouteData {
  ChatRoute({required this.chatId, required this.$extra});

  final String chatId;
  final User $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChatScreen(user: $extra, chatId: chatId);
  }
}
