import 'package:flutter/material.dart';
import 'package:student_task_manager/services/app_theme.dart';
import 'package:student_task_manager/services/storage_service.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to theme changes
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.instance,
      builder: (context, themeMode, child) {
        final isDark = themeMode == ThemeMode.dark;
        
        return Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.12)
                : const Color(0xFF6C63FF).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(isDark),
                color: isDark ? Colors.white : const Color(0xFF6C63FF),
                size: 22,
              ),
            ),
            onPressed: () async {
              final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
              // Update the ValueNotifier
              AppTheme.instance.value = newMode;
              // Save the preference
              await StorageService.saveThemeMode(newMode);
            },
          ),
        );
      },
    );
  }
}