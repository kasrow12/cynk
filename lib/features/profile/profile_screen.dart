import 'package:cached_network_image/cached_network_image.dart';
import 'package:cynk/constants.dart';
import 'package:cynk/features/data/cynk_user.dart';
import 'package:cynk/features/profile/profile_cubit.dart';
import 'package:cynk/features/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final cubit = context.read<ProfileCubit>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) {
        return;
      }

      setState(() {
        _isUploading = true;
      });

      await cubit.updatePhoto(image);

      messenger.showSnackBar(
        const SnackBar(content: Text('Photo uploaded successfully')),
      );
    } catch (err) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to upload photo: $err')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showEditNameDialog(CynkUser user, void Function(String) onSave) {
    _nameController.text = user.name;
    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Username'),
            content: Form(
              autovalidateMode: AutovalidateMode.always,
              key: _formkey,
              child: TextFormField(
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length < 3) {
                    return 'Username must be at least 3 characters long';
                  }
                  if (value.trim().length > MAX_NAME_LENGTH) {
                    return 'Username must be at most $MAX_NAME_LENGTH characters long';
                  }
                  return null;
                },
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  errorMaxLines: 2,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  try {
                    onSave(_nameController.text.trim());
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name updated')),
                    );
                  } catch (err) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(err.toString())),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) => switch (state) {
          ProfileLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          ProfileError(:final error) => Center(
              child: Text('Error: $error'),
            ),
          ProfileLoaded(:final user) => SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 100,
                            backgroundImage:
                                CachedNetworkImageProvider(user.photoUrl),
                          ),
                          if (_isUploading)
                            const Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt),
                                onPressed: _isUploading ? null : _pickImage,
                                iconSize: 32,
                                tooltip: 'Change photo',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: TrimmedText(
                              text: user.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditNameDialog(
                              user,
                              (name) =>
                                  context.read<ProfileCubit>().updateName(name),
                            ),
                            tooltip: 'Edit username',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
