// login screen
import 'package:Cynk/features/auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authCubit = context.watch<AuthCubit>();
    final state = authCubit.state;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: 'Email address',
              ),
              controller: email,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: 'Password',
              ),
              controller: password,
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (state case SignedOutState(:final error?)) ...[
              Text(error),
              const SizedBox(height: 16),
            ] else
              const SizedBox(height: 32),
            _SignInButton(
              enabled: state is SignedOutState,
              onSignIn: () => authCubit.signInWithEmail(
                email: email.text,
                password: password.text,
              ),
            ),
            _SignInButton(
              enabled: state is SignedOutState,
              onSignIn: () => authCubit.signInWithGoogle(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton({
    required this.enabled,
    required this.onSignIn,
  });

  final bool enabled;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: enabled ? onSignIn : null,
      child: enabled
          ? const Text('Sign in')
          : const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
    );
  }
}
