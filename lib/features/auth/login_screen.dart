import 'package:cynk/features/auth/auth_cubit.dart';
import 'package:cynk/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void _signIn(AuthCubit authCubit) {
    if (formKey.currentState?.validate() ?? false) {
      authCubit.signInWithEmail(
        email: email.text,
        password: password.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.watch<AuthCubit>();
    final state = authCubit.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cynk'),
        leading: const Icon(Icons.chat),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => App.changeLocale(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: 400,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.signIn,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.email,
                      ),
                      controller: email,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@')) {
                          return AppLocalizations.of(context)!.invalidEmail;
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.password,
                      ),
                      controller: password,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.passwordEmpty;
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _signIn(authCubit),
                    ),
                    const SizedBox(height: 16),
                    if (state case SignedOutState(:final error?)) ...[
                      Text(
                        error,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _SignInButton(
                      enabled: state is SignedOutState,
                      onSignIn: () => _signIn(authCubit),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: authCubit.signInWithGoogle,
                      child:
                          Text(AppLocalizations.of(context)!.signInWithGoogle),
                    ),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.or),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: authCubit.moveToSignUp,
                      child: Text(AppLocalizations.of(context)!.signUp),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
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
          ? Text(AppLocalizations.of(context)!.signIn)
          : const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
    );
  }
}
