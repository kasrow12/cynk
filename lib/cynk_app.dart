import 'package:Cynk/data/message.dart';
import 'package:Cynk/features/auth/auth_cubit.dart';
import 'package:Cynk/features/auth/auth_gate.dart';
import 'package:Cynk/features/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class CynkApp extends StatelessWidget {
  const CynkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (context) => AuthService(
            firebase: FirebaseAuth.instance,
          ),
        ),
        BlocProvider(
          create: (context) => AuthCubit(
            authService: context.read(),
          ),
        ),
      ],
      child: AuthGate(),
    );
  }
}

List<Message> aaaamessages() {
  return [
    Message(
      message: 'Hello!',
      time: DateTime.now()
          .subtract(Duration(days: 5))
          .subtract(Duration(hours: 3)),
      isSentByUser: true,
    ),
    Message(
      message:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec nec odio vitae libero.',
      time: DateTime.now()
          .subtract(Duration(days: 5))
          .subtract(Duration(hours: 3)),
      isSentByUser: false,
    ),
    Message(
      message: 'Hello!',
      time: DateTime.now()
          .subtract(Duration(days: 5))
          .subtract(Duration(minutes: 2)),
      isSentByUser: false,
    ),
    Message(
      message: 'Hello!',
      time: DateTime.now().subtract(Duration(days: 5)),
      isSentByUser: false,
    ),
    Message(
      message: 'Hello!',
      time: DateTime.now().subtract(Duration(days: 5)),
      isSentByUser: true,
    ),
    Message(
      message: 'How are you?',
      time: DateTime.now()
          .subtract(Duration(days: 4))
          .subtract(Duration(hours: 3)),
      isSentByUser: false,
    ),
    Message(
      message: 'Hiiiiiiiiiii!',
      time: DateTime.now().subtract(Duration(days: 4)),
      isSentByUser: true,
    ),
    Message(
      message: 'How are you2?',
      time: DateTime.now().subtract(Duration(minutes: 13)),
      isSentByUser: false,
    ),
    Message(
      message:
          'I\'m fine, thanks! How about you? How was your day? What did you do today? Maybe you want to tell me something interesting?',
      time: DateTime.now().subtract(Duration(minutes: 12)),
      isSentByUser: true,
    ),
    Message(
      message: 'What about you?',
      time: DateTime.now().subtract(Duration(minutes: 1)),
      isSentByUser: true,
    ),
    Message(
      message: 'What about you?',
      time: DateTime.now(),
      isSentByUser: true,
    ),
  ].reversed.toList();
}
