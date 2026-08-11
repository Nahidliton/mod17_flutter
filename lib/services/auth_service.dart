import 'package:student_task_manager/models/user_profile.dart';
import 'package:student_task_manager/services/storage_service.dart';

class AuthService {
  static Future<UserProfile?> getCurrentUser() async {
    final email = StorageService.getCurrentUserEmail();
    if (email == null) {
      return null;
    }
    return await StorageService.loadUser(email);
  }

  static String? get currentUserEmail => StorageService.getCurrentUserEmail();

  static Future<bool> login(String email, String password) async {
    final user = await StorageService.loadUser(email);
    if (user == null) {
      return false;
    }
    if (user.password != password) {
      return false;
    }
    await StorageService.setCurrentUserEmail(email);
    return true;
  }

  static Future<bool> signUp(String name, String email, String password) async {
    final existing = await StorageService.loadUser(email);
    if (existing != null) {
      return false;
    }
    final user = UserProfile(name: name, email: email, password: password);
    await StorageService.saveUser(user);
    await StorageService.setCurrentUserEmail(email);
    return true;
  }

  static Future<bool> resetPassword(String email, String newPassword) async {
    final user = await StorageService.loadUser(email);
    if (user == null) {
      return false;
    }
    final updated = user.copyWith(password: newPassword);
    await StorageService.saveUser(updated);
    return true;
  }

  static Future<void> logout() async {
    await StorageService.setCurrentUserEmail(null);
  }

  static Future<bool> updateProfile(UserProfile profile) async {
    final existing = await StorageService.loadUser(profile.email);
    if (existing == null) {
      return false;
    }
    await StorageService.saveUser(profile);
    return true;
  }
}
