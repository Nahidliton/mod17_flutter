import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_task_manager/models/user_profile.dart';
import 'package:student_task_manager/screens/login_screen.dart';
import 'package:student_task_manager/services/app_theme.dart';
import 'package:student_task_manager/services/auth_service.dart';
import 'package:student_task_manager/services/storage_service.dart';
import 'package:student_task_manager/widgets/custom_text_field.dart';
import 'package:student_task_manager/widgets/theme_toggle.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  UserProfile? _profile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final email = AuthService.currentUserEmail;
    if (email == null) {
      return;
    }
    final profile = await StorageService.loadUser(email);
    if (profile != null) {
      _profile = profile;
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null || _profile == null) {
      return;
    }
    final updated = _profile!.copyWith(profileImagePath: image.path);
    final success = await AuthService.updateProfile(updated);
    if (!mounted) return;
    if (success) {
      setState(() {
        _profile = updated;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_profile == null) {
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your name.')));
      return;
    }
    setState(() => _saving = true);
    final updated = _profile!.copyWith(name: _nameController.text.trim());
    final success = await AuthService.updateProfile(updated);
    if (!mounted) return;
    setState(() {
      _profile = updated;
      _saving = false;
    });
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')));
    }
  }

  Future<void> _toggleTheme(bool enabled) async {
    final mode = enabled ? ThemeMode.dark : ThemeMode.light;
    AppTheme.instance.value = mode;
    await StorageService.saveThemeMode(mode);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = AppTheme.instance.value;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), actions: [const ThemeToggle()]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              Align(
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      backgroundImage: _profile?.profileImagePath != null
                          ? FileImage(File(_profile!.profileImagePath!))
                          : null,
                      child: _profile?.profileImagePath == null
                          ? Icon(Icons.person,
                              size: 56,
                              color: Theme.of(context).colorScheme.onSurfaceVariant)
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      child: FloatingActionButton.small(
                        heroTag: 'editPhoto',
                        onPressed: _pickImage,
                        child: const Icon(Icons.camera_alt, size: 18),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Name', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              CustomTextField(controller: _nameController, label: 'Name'),
              const SizedBox(height: 16),
              Text('Email', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                readOnly: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                value: themeMode == ThemeMode.dark,
                onChanged: _toggleTheme,
                title: const Text('Dark Mode'),
                secondary: const Icon(Icons.dark_mode),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _saveProfile,
                child: _saving
                    ? CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimary)
                    : const Text('Save Profile'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await AuthService.logout();
                  if (!mounted) return;
                  navigator.pushNamedAndRemoveUntil(
                      LoginScreen.routeName, (route) => false);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
