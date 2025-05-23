import 'dart:typed_data';

import 'package:cynk/features/auth/auth_cubit.dart';
import 'package:cynk/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final username = TextEditingController();
  final picker = ImagePicker();
  XFile? selectedPhoto;
  Uint8List? photoBytes;
  bool isUploading = false;

  final formKey = GlobalKey<FormState>();
  bool showPassword = false;

  Future<void> pickPhoto() async {
    final messenger = ScaffoldMessenger.of(context);
    final localizations = AppLocalizations.of(context)!;

    setState(() {
      isUploading = true;
    });

    try {
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 80,
      );

      if (image == null) {
        setState(() {
          isUploading = false;
        });
        return;
      }
      final bytes = await image.readAsBytes();

      setState(() {
        selectedPhoto = image;
        photoBytes = bytes;
      });
    } catch (err) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(localizations.photoUpdateFail(err.toString())),
          ),
        );
      }
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  void _signUp(AuthCubit authCubit) {
    if (formKey.currentState?.validate() ?? false) {
      authCubit.signUpWithEmail(
        email: email.text.trim(),
        password: password.text,
        username: username.text.trim(),
        photo: selectedPhoto,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.read<AuthCubit>().signOut(),
        ),
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
                      AppLocalizations.of(context)!.signUp,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(AppLocalizations.of(context)!.profilePhoto),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: pickPhoto,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: photoBytes != null
                                  ? MemoryImage(photoBytes!)
                                  : null,
                              child: selectedPhoto == null
                                  ? const Icon(
                                      Icons.camera_alt,
                                      size: 40,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        if (isUploading)
                          const Positioned.fill(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
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
                    StatefulBuilder(
                      builder: (context, setState) {
                        return TextFormField(
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.password,
                            suffixIcon: ExcludeFocus(
                              child: IconButton(
                                icon: Icon(
                                  showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          controller: password,
                          obscureText: !showPassword,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .passwordEmpty;
                            }
                            if (value.length < 6) {
                              return AppLocalizations.of(context)!
                                  .passwordTooShort(6);
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).nextFocus,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.username,
                      ),
                      controller: username,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.invalidUsername;
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _signUp(authCubit),
                    ),
                    const SizedBox(height: 16),
                    if (state case SigningUpScreenState(:final error?)) ...[
                      Text(
                        error,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                    ],
                    FilledButton.tonal(
                      onPressed: state is SigningUpScreenState
                          ? () => _signUp(authCubit)
                          : null,
                      child: state is SigningUpScreenState
                          ? Text(AppLocalizations.of(context)!.signUp)
                          : const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.or),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: authCubit.signOut,
                      child: Text(AppLocalizations.of(context)!.backToSignIn),
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

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    username.dispose();
    super.dispose();
  }
}
