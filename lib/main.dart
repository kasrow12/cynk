import 'package:cynk/cynk_app.dart';
import 'package:cynk/firebase_options.dart';
import 'package:cynk/pl_messages.dart';
import 'package:cynk/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  timeago.setLocaleMessages('pl', PlMessages());
  timeago.setDefaultLocale('pl');

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  static void changeLocale(BuildContext context) {
    context.findAncestorStateOfType<_AppState>()?.changeLanguage();
  }

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final _init =
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final _router = GoRouter(
    routes: $appRoutes,
  );

  Locale locale = const Locale('pl');

  void changeLanguage() {
    setState(() {
      locale = locale == const Locale('pl')
          ? const Locale('en')
          : const Locale('pl');
      timeago.setDefaultLocale(locale.languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Cynk',
      darkTheme: ThemeData.dark(),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (context) => FutureBuilder(
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
          ),
        ],
      ),
    );
  }
}
