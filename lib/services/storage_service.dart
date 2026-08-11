import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_task_manager/models/task.dart';
import 'package:student_task_manager/models/user_profile.dart';

class StorageService {
  static const _userKey = 'users';
  static const _currentEmailKey = 'current_user_email';
  static const _themeModeKey = 'theme_mode';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<ThemeMode> loadThemeMode() async {
    final value = _prefs?.getString(_themeModeKey);
    if (value == 'dark') {
      return ThemeMode.dark;
    }
    if (value == 'light') {
      return ThemeMode.light;
    }
    return ThemeMode.system;
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs?.setString(
      _themeModeKey,
      mode == ThemeMode.dark
          ? 'dark'
          : mode == ThemeMode.light
              ? 'light'
              : 'system',
    );
  }

  static Map<String, dynamic> _loadRawUsers() {
    final raw = _prefs?.getString(_userKey);
    if (raw == null || raw.isEmpty) {
      return {};
    }
    final data = jsonDecode(raw);
    return data is Map<String, dynamic> ? data : {};
  }

  static Future<void> _saveRawUsers(Map<String, dynamic> users) async {
    await _prefs?.setString(_userKey, jsonEncode(users));
  }

  static Future<void> saveUser(UserProfile profile) async {
    final users = _loadRawUsers();
    users[profile.email] = profile.toMap();
    await _saveRawUsers(users);
  }

  static Future<UserProfile?> loadUser(String email) async {
    final users = _loadRawUsers();
    if (!users.containsKey(email)) {
      return null;
    }
    return UserProfile.fromMap(Map<String, dynamic>.from(users[email] as Map));
  }

  static Future<void> setCurrentUserEmail(String? email) async {
    if (email == null) {
      await _prefs?.remove(_currentEmailKey);
      return;
    }
    await _prefs?.setString(_currentEmailKey, email);
  }

  static String? getCurrentUserEmail() {
    return _prefs?.getString(_currentEmailKey);
  }

  static Future<List<Task>> loadTasksForUser(String email) async {
    final raw = _prefs?.getString('tasks_$email');
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => Task.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  static Future<void> saveTasksForUser(String email, List<Task> tasks) async {
    final data = tasks.map((task) => task.toMap()).toList();
    await _prefs?.setString('tasks_$email', jsonEncode(data));
  }
}
