import 'package:cynk/cynk_app.dart';
import 'package:cynk/firebase_options.dart';
import 'package:cynk/pl_messages.dart';
import 'package:cynk/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  timeago.setLocaleMessages('pl', PlMessages());

  runApp(_App());
}

class _App extends StatefulWidget {
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
      builder: (context, child) => FutureBuilder(
        future: _init,
        builder: (context, snapshot) {
          if (child == null) {
            return const Placeholder();
          }

          return switch (snapshot.connectionState) {
            ConnectionState.done => CynkApp(child: child),
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
