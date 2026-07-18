import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/counter_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> _showTimePicker(
  BuildContext context,
  CounterProvider provider,
) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(
      hour: provider.reminderHour,
      minute: provider.reminderMinute,
    ),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: TimePickerThemeData(
            backgroundColor: Theme.of(context).colorScheme.surface,
            hourMinuteColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.1),
            hourMinuteTextColor: Theme.of(context).colorScheme.onSurface,
            dialHandColor: Theme.of(context).colorScheme.primary,
            dialBackgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.1),
            entryModeIconColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    // Save new time
    await provider.setReminderTime(picked.hour, picked.minute);

    // Reschedule if enabled
    if (provider.notificationsEnabled) {
      await NotificationService.cancelDailyReminder();
      await NotificationService.scheduleDailyReminder(
        hour: picked.hour,
        minute: picked.minute,
        title: 'Start your day with dhikr ☀️',
        body: 'SubhanAllah, Alhamdulillah, Allahu Akbar',
      );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reminder time updated to ${_formatTime(picked.hour, picked.minute)}',
          ),
        ),
      );
    }
  }
}

String _formatTime(int hour, int minute) {
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
  final displayMinute = minute.toString().padLeft(2, '0');
  return '$displayHour:$displayMinute $period';
}

Future<void> _scheduleAndEnable(
  BuildContext context,
  CounterProvider provider,
) async {
  await NotificationService.scheduleDailyReminder(
    hour: provider.reminderHour,
    minute: provider.reminderMinute,
    title: 'Start your day with dhikr ☀️',
    body: 'SubhanAllah, Alhamdulillah, Allahu Akbar',
  );
  await provider.setNotificationsEnabled(true);

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Daily reminder set for ${_formatTime(provider.reminderHour, provider.reminderMinute)}',
        ),
      ),
    );
  }
}

void _showOpenSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Permission Required'),
      content: const Text(
        'Notification permission was permanently denied. Please enable it in your device settings.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            openAppSettings(); // From permission_handler
            Navigator.pop(context);
          },
          child: const Text('Open Settings'),
        ),
      ],
    ),
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final counterProvider = Provider.of<CounterProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionTitle(context, 'Appearance'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Dark Mode'),
                  subtitle: Text(
                    themeProvider.isDarkMode
                        ? 'Currently dark'
                        : 'Currently light',
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Feedback Section
          _buildSectionTitle(context, 'Feedback'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.vibration,
                    color: counterProvider.vibrationEnabled
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                  title: const Text('Vibration'),
                  subtitle: const Text('Haptic feedback on each tap'),
                  value: counterProvider.vibrationEnabled,
                  onChanged: (_) => counterProvider.toggleVibration(),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(
                    Icons.volume_up,
                    color: counterProvider.soundEnabled
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                  title: const Text('Sound'),
                  subtitle: const Text('Audio feedback on each tap'),
                  value: counterProvider.soundEnabled,
                  onChanged: (_) => counterProvider.toggleSound(),
                ),

                // Notifications Section
              ],
            ),
          ),

          const SizedBox(height: 16),
          _buildSectionTitle(context, 'Notifications'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.volume_up,
                    color: counterProvider.dikhrNotificationsEnabled
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                  title: const Text('Dhikr Completion Alert'),
                  subtitle: const Text(
                    'Show instant notification when you hit your target counter goal',
                  ),
                  value: counterProvider.dikhrNotificationsEnabled,
                  onChanged: (value) async {
                    if (value) {
                      // 1. Check standard notification permission
                      final status = await Permission.notification.status;

                      if (status.isGranted) {
                        // Request exact alarm permission (Android 13+ requirement)
                        final exactAlarmGranted =
                            await NotificationService.requestExactAlarmsPermission();

                        if (exactAlarmGranted) {
                          await counterProvider
                              .setDikhrCompletionNotificationsEnabled(true);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Exact alarms permission is required for on-time reminders.',
                                ),
                              ),
                            );
                          }
                        }
                      } else if (status.isDenied) {
                        final result = await Permission.notification.request();

                        if (result.isGranted) {
                          // Request exact alarm permission after standard is granted
                          final exactAlarmGranted =
                              await NotificationService.requestExactAlarmsPermission();
                          if (exactAlarmGranted) {
                            await counterProvider
                                .setDikhrCompletionNotificationsEnabled(true);
                          }
                        } else {
                          // Handle normal permission denied...
                        }
                      } else if (status.isPermanentlyDenied) {
                        _showOpenSettingsDialog(context);
                      }
                    } else {
                      // Turn off — cancel reminders
                      await counterProvider
                          .setDikhrCompletionNotificationsEnabled(false);
                    }
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(
                    Icons.notifications,
                    color: counterProvider.notificationsEnabled
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                  title: const Text('Daily Reminders'),
                  subtitle: Text(
                    counterProvider.notificationsEnabled
                        ? 'Daily at ${_formatTime(counterProvider.reminderHour, counterProvider.reminderMinute)}'
                        : 'Get notified for dhikr',
                  ),
                  value: counterProvider.notificationsEnabled,
                  onChanged: (value) async {
                    if (value) {
                      // 1. Check standard notification permission
                      final status = await Permission.notification.status;

                      if (status.isGranted) {
                        // Request exact alarm permission (Android 13+ requirement)
                        final exactAlarmGranted =
                            await NotificationService.requestExactAlarmsPermission();

                        if (exactAlarmGranted) {
                          await _scheduleAndEnable(context, counterProvider);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Exact alarms permission is required for on-time reminders.',
                                ),
                              ),
                            );
                          }
                        }
                      } else if (status.isDenied) {
                        final result = await Permission.notification.request();

                        if (result.isGranted) {
                          // Request exact alarm permission after standard is granted
                          final exactAlarmGranted =
                              await NotificationService.requestExactAlarmsPermission();
                          if (exactAlarmGranted) {
                            await _scheduleAndEnable(context, counterProvider);
                          }
                        } else {
                          // Handle normal permission denied...
                        }
                      } else if (status.isPermanentlyDenied) {
                        _showOpenSettingsDialog(context);
                      }
                    } else {
                      // Turn off — cancel reminders
                      await NotificationService.cancelDailyReminder();
                      await counterProvider.setNotificationsEnabled(false);
                    }
                  },
                ),

                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Reminder Time'),
                  subtitle: Text(
                    _formatTime(
                      counterProvider.reminderHour,
                      counterProvider.reminderMinute,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showTimePicker(context, counterProvider);
                    // TODO: Show time picker
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Daily Goal Section
          _buildSectionTitle(context, 'Daily Goal'),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.flag,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Daily Goal'),
              subtitle: Text('${counterProvider.dailyGoal} dhikr per day'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDailyGoalDialog(context, counterProvider),
            ),
          ),

          const SizedBox(height: 16),

          // Data Section
          _buildSectionTitle(context, 'Data'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.delete_forever,
                    color: Colors.red.withValues(alpha: 0.8),
                  ),
                  title: const Text(
                    'Clear All Data',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text('Reset all counters and history'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear All Data?'),
                        content: const Text(
                          'This will permanently delete all your counter data and history. This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              counterProvider.clearAllData();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('All data cleared'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Text(
                              'Clear',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // About Section
          _buildSectionTitle(context, 'About'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Tasbeeh Counter'),
                  subtitle: Text('Version 1.0.0'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.favorite_outline),
                  title: Text('Made with ❤️ for the Ummah'),
                  subtitle: Text('May Allah accept your dhikr'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Pass counterProvider as parameter
  void _showDailyGoalDialog(
    BuildContext context,
    CounterProvider counterProvider,
  ) {
    final controller = TextEditingController(
      text: counterProvider.dailyGoal.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter daily goal',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                counterProvider.setDailyGoal(value);
              }
              Navigator.pop(context);
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }
}
