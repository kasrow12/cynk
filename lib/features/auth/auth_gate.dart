import 'package:Cynk/cynk_app.dart';
import 'package:Cynk/features/data/user.dart';
import 'package:Cynk/features/auth/auth_cubit.dart';
import 'package:Cynk/screens/chat/chat_screen.dart';
import 'package:Cynk/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return switch (state) {
          SignedInState(:final user) => ChatPage(
              user: User(
                id: user.uid,
                name: user.displayName ?? 'brak',
                photoUrl: user.photoURL ??
                    'https://cdn.pixabay.com/photo/2019/08/11/18/59/icon-4399701_1280.png',
                lastSeen: DateTime.now().subtract(Duration(minutes: 34)),
              ),
              messages: aaaamessages(),
            ),
          SigningInState() || SignedOutState() => const LoginScreen(),
        };
      },
    );
  }
}
