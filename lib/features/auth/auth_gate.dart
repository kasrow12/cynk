import 'package:cynk/features/data/cynk_user.dart';
import 'package:cynk/features/auth/auth_cubit.dart';
import 'package:cynk/screens/chat/chat_screen.dart';
import 'package:cynk/screens/chats/chats_screen.dart';
import 'package:cynk/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({required this.child, super.key});

  final Widget child;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return switch (state) {
          // SignedInState(:final user) => ChatScreen(
          //     user: User(
          //       id: user.uid,
          //       name: user.displayName ?? 'brak',
          //       photoUrl: user.photoURL ??
          //           'https://cdn.pixabay.com/photo/2019/08/11/18/59/icon-4399701_1280.png',
          //       lastSeen: DateTime.now().subtract(Duration(minutes: 34)),
          //     ),
          //     chatId: 'a810uxkTnV1E6jkofYYy',
          //   ),
          // SignedInState(:final user) => ChatsScreen(
          //     user: User(
          //       id: user.uid,
          //       name: user.displayName ?? 'brak',
          //       photoUrl: user.photoURL ??
          //           'https://cdn.pixabay.com/photo/2019/08/11/18/59/icon-4399701_1280.png',
          //       lastSeen: DateTime.now().subtract(Duration(minutes: 34)),
          //     ),
          //   ),
          SignedInState(:final user) => Provider(
              create: (context) => user,
              child: child,
            ),
          SigningInState() || SignedOutState() => const LoginScreen(),
        };
      },
    );
  }
}
