import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:student_task_manager/firebase_options.dart';
import 'package:student_task_manager/screens/add_edit_task_screen.dart';
import 'package:student_task_manager/screens/forgot_password_screen.dart';
import 'package:student_task_manager/screens/home_screen.dart';
import 'package:student_task_manager/screens/login_screen.dart';
import 'package:student_task_manager/screens/profile_screen.dart';
import 'package:student_task_manager/screens/signup_screen.dart';
import 'package:student_task_manager/services/app_theme.dart';
import 'package:student_task_manager/services/auth_service.dart';
import 'package:student_task_manager/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Handle Firebase initialization error
    print('Firebase initialization error: $e');
  }
  
  // Initialize Storage Service
  await StorageService.init();
  
  // Load saved theme mode
  final savedTheme = await StorageService.loadThemeMode();
  AppTheme.instance.value = savedTheme;
  
  runApp(const StudentTaskManagerApp());
}

class StudentTaskManagerApp extends StatelessWidget {
  const StudentTaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final initialRoute = AuthService.currentUserEmail == null
        ? LoginScreen.routeName
        : HomeScreen.routeName;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.instance,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Student Task Manager',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppTheme.buildThemeData(Brightness.light),
          darkTheme: AppTheme.buildThemeData(Brightness.dark),
          initialRoute: initialRoute,
          routes: {
            LoginScreen.routeName: (context) => const LoginScreen(),
            SignupScreen.routeName: (context) => const SignupScreen(),
            ForgotPasswordScreen.routeName: (context) =>
                const ForgotPasswordScreen(),
            HomeScreen.routeName: (context) => const HomeScreen(),
            ProfileScreen.routeName: (context) => const ProfileScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == AddEditTaskScreen.routeName) {
              final task = settings.arguments as dynamic;
              return MaterialPageRoute(
                builder: (_) => AddEditTaskScreen(task: task),
              );
            }
            return null;
          },
        );
      },
    );
  }
}