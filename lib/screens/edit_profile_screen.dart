import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_profile.dart';
import '../services/app_controller.dart';
import '../services/auth_error_mapper.dart';
import '../utils/translations.dart';
import '../widgets/profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.profile,
  });

  final UserProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late int _avatarSeed;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _avatarSourcePath;
  Uint8List? _avatarBytes;
  bool _removeAvatar = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.displayName);
    _emailController = TextEditingController(text: widget.profile.email);
    _avatarSeed = widget.profile.avatarSeed;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF111827) : Colors.white;
    final mutedColor = theme.colorScheme.onSurface.withValues(alpha: 0.65);
    final previewPath = _removeAvatar
        ? null
        : (_avatarSourcePath ?? widget.profile.localAvatarPath);
    final previewBytes = _removeAvatar
        ? null
        : (_avatarBytes ?? widget.profile.localAvatarBytes);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          tr('Edit Profile'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    tr('Save'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  ProfileAvatar(
                    displayName: _nameController.text.isEmpty
                        ? widget.profile.displayName
                        : _nameController.text,
                    avatarSeed: _avatarSeed,
                    imagePath: previewPath,
                    imageBytes: previewBytes,
                    size: 88,
                    fontSize: 34,
                    borderRadius: 28,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: _pickAvatar,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(tr('Choose Photo')),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _avatarSeed = (_avatarSeed + 1) % 6;
                            _removeAvatar = false;
                          });
                        },
                        icon: const Icon(Icons.auto_awesome_outlined),
                        label: Text(tr('Shuffle Avatar')),
                      ),
                      if (previewPath != null || previewBytes != null)
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _avatarSourcePath = null;
                              _avatarBytes = null;
                              _removeAvatar = true;
                            });
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: Text(tr('Remove Photo')),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr('Change your name, avatar, and contact email.'),
                    style: TextStyle(color: mutedColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      validator: _validateName,
                      decoration: InputDecoration(
                        labelText: tr('Display name'),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.email],
                      validator: _validateEmail,
                      onFieldSubmitted: (_) => _saveProfile(),
                      decoration: InputDecoration(
                        labelText: tr('Email'),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF172033)
                            : const Color(0xFFF8F7FF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        tr('If email update fails, Firebase may require a fresh sign-in before changing it.'),
                        style: TextStyle(color: mutedColor, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
    );

    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();
    if (!mounted) {
      return;
    }

    setState(() {
      _avatarSourcePath = image.path;
      _avatarBytes = bytes;
      _removeAvatar = false;
    });
  }

  Future<void> _saveProfile() async {
    if (_isSaving) {
      return;
    }
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSaving = true);
    final requestedEmail = _emailController.text.trim();
    final emailChanged =
        requestedEmail.isNotEmpty && requestedEmail != widget.profile.email;

    try {
      await AppController.instance.updateProfile(
        displayName: _nameController.text,
        email: _emailController.text,
        avatarSeed: _avatarSeed,
        avatarSourcePath: _avatarSourcePath,
        avatarBytes: _avatarBytes,
        removeAvatar: _removeAvatar,
      );

      if (!mounted) {
        return;
      }

      if (emailChanged) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(tr('Check your inbox to verify the new email.'))),
        );
      }
      Navigator.of(context).pop(true);
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(authErrorMessage(error))));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Unable to save profile right now.'))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String? _validateName(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return tr('Name is required.');
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return tr('Email is required.');
    }
    if (!email.contains('@') || !email.contains('.')) {
      return tr('Please enter a valid email address.');
    }
    return null;
  }
}
