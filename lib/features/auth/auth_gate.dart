import 'package:cynk/features/auth/auth_cubit.dart';
import 'package:cynk/features/auth/login_screen.dart';
import 'package:cynk/features/auth/register_screen.dart';
import 'package:cynk/features/chats/cubits/chats_cubit.dart';
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
          SignedInState(:final userId) => MultiProvider(
              providers: [
                BlocProvider(
                  create: (context) =>
                      ChatsCubit(db: context.read(), userId: userId)
                        ..loadChats(),
                ),
              ],
              child: child,
            ),
          SigningUpScreenState() || SingingUpState() => const RegisterScreen(),
          SigningInState() || SignedOutState() => const LoginScreen(),
        };
      },
    );
  }
}
