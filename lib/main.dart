import 'package:cynk/cynk_app.dart';
import 'package:cynk/features/auth/auth_gate.dart';
import 'package:cynk/features/data/user.dart';
import 'package:cynk/firebase_options.dart';
import 'package:cynk/pl_messages.dart';
import 'package:cynk/routes/routes.dart';
import 'package:cynk/screens/chat/chat_screen.dart';
import 'package:cynk/screens/chats/chats_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  timeago.setLocaleMessages('pl', PlMessages());

  runApp(const _App(child: CynkApp()));
}

class _App extends StatefulWidget {
  const _App({
    required this.child,
  });

  final Widget child;

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<_App> {
  final _init =
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // final _router = GoRouter(
  //   // initialLocation: '/',
  //   debugLogDiagnostics: true,
  //   routes: [
  //     GoRoute(
  //       path: '/',
  //       builder: (context, state) => AuthGate(),
  //     ),
  //     GoRoute(
  //       path: '/chat/:chatId',
  //       builder: (context, state) {
  //         final user = state.extra as User;
  //         final chatId = state.pathParameters['chatId'] ?? '';
  //         return ChatScreen(user: user, chatId: chatId);
  //       },
  //     ),
  //   ],
  // );

  final _router = GoRouter(
    routes: $appRoutes,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Cynk',
      builder: (ctxt, chld) => FutureBuilder(
        future: _init,
        builder: (context, snapshot) {
          return switch (snapshot.connectionState) {
            ConnectionState.done => widget.child,
            _ => const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          };
        },
      ),
    );
  }
}
