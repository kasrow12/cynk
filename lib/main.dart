import 'package:Cynk/cynk_app.dart';
import 'package:Cynk/firebase_options.dart';
import 'package:Cynk/pl_messages.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cynk',
      home: FutureBuilder(
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
