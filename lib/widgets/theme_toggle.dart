import 'package:flutter/material.dart';
import 'package:student_task_manager/services/app_theme.dart';
import 'package:student_task_manager/services/storage_service.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  Future<void> _openThemeSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          final isDark = AppTheme.instance.value == ThemeMode.dark;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  value: isDark,
                  onChanged: (value) async {
                    final mode = value ? ThemeMode.dark : ThemeMode.light;
                    AppTheme.instance.value = mode;
                    await StorageService.saveThemeMode(mode);
                    setState(() {});
                    // close the sheet after a small delay so user sees the change
                  },
                  title: const Text('Dark Mode'),
                  secondary: const Icon(Icons.dark_mode),
                ),
                const SizedBox(height: 8),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'))
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Dark Mode',
      icon: const Icon(Icons.dark_mode),
      onPressed: () => _openThemeSheet(context),
    );
  }
}
