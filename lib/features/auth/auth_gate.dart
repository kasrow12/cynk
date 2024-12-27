import 'package:Cynk/cynk_app.dart';
import 'package:Cynk/data/user.dart';
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
          SignedInState() => ChatPage(
              user: User(
                id: 'aaaa',
                name: 'Kacper Szafrański',
                photoUrl:
                    'https://avatars.githubusercontent.com/u/37282077?v=4',
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
