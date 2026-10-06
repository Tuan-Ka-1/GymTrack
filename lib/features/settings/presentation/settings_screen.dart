import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../services/notification_service.dart';
import 'widgets/app_info_section.dart';
import 'widgets/backup_settings_card.dart';
import 'widgets/preferences_section.dart';
import 'widgets/workout_reminders_section.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _reminderEnabled = false;
  int _reminderHour = 18;
  int _reminderMinute = 0;
  List<int> _reminderDays = [1, 3, 5];
  int _defaultRestTime = AppConstants.defaultRestSeconds;
  bool _autoFillPrevious = AppConstants.defaultAutoFillPrevious;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repo = ref.read(settingsRepositoryProvider);
    final enabled = await repo.getReminderEnabled();
    final hour = await repo.getReminderHour();
    final minute = await repo.getReminderMinute();
    final days = await repo.getReminderDays();
    final rest = await repo.getDefaultRestTime();
    final autoFill = await repo.getAutoFillPrevious();

    if (mounted) {
      setState(() {
        _reminderEnabled = enabled;
        _reminderHour = hour;
        _reminderMinute = minute;
        _reminderDays = days;
        _defaultRestTime = rest;
        _autoFillPrevious = autoFill;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminderHour, minute: _reminderMinute),
    );
    if (picked != null) {
      final repo = ref.read(settingsRepositoryProvider);
      await repo.setReminderTime(picked.hour, picked.minute);
      setState(() {
        _reminderHour = picked.hour;
        _reminderMinute = picked.minute;
      });
      if (_reminderEnabled) {
        await _scheduleReminders();
      }
    }
  }

  Future<void> _scheduleReminders() async {
    final notificationService = NotificationService();
    await notificationService.scheduleWorkoutReminders(
      daysOfWeek: _reminderDays,
      hour: _reminderHour,
      minute: _reminderMinute,
    );
  }

  Future<void> _cancelReminders() async {
    final notificationService = NotificationService();
    await notificationService.cancelWorkoutReminders();
  }

  Future<void> _exportBackup() async {
    final repo = ref.read(settingsRepositoryProvider);
    final json = await repo.exportBackupJson();

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Export Backup'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Backup data generated successfully! You can copy to clipboard or share via device.',
              ),
              const SizedBox(height: 12),
              Container(
                height: 100,
                padding: const EdgeInsets.all(8),
                color: Colors.black26,
                child: SingleChildScrollView(
                  child: Text(
                    json,
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: json));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Backup JSON copied to clipboard!'),
                  ),
                );
              },
              child: const Text('Copy to Clipboard'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                SharePlus.instance.share(
                  ShareParams(text: json, subject: 'GymTrack_Backup.json'),
                );
              },
              child: const Text('Share File'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _importBackup() async {
    final controller = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paste your exported JSON backup string below:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Paste JSON content here...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.of(ctx).pop(true);
              }
            },
            child: const Text('Restore Data'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final repo = ref.read(settingsRepositoryProvider);
        await repo.importBackupJson(controller.text.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Database restored successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to import backup: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _resetAllData() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete All Data?',
      message: 'This will completely erase all workout history, custom exercises, routines, and body measurements. This action CANNOT be undone.',
      confirmText: 'DELETE EVERYTHING',
      isDestructive: true,
    );

    if (confirmed) {
      final repo = ref.read(settingsRepositoryProvider);
      await repo.clearAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data has been reset to defaults.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PreferencesSection(
            defaultRestTime: _defaultRestTime,
            autoFillPrevious: _autoFillPrevious,
            onRestTimeChanged: (val) {
              ref.read(settingsRepositoryProvider).setDefaultRestTime(val);
              setState(() => _defaultRestTime = val);
            },
            onAutoFillChanged: (val) async {
              await ref.read(autoFillPreviousProvider.notifier).setEnabled(val);
              setState(() => _autoFillPrevious = val);
            },
          ),
          const SizedBox(height: 24),
          WorkoutRemindersSection(
            reminderEnabled: _reminderEnabled,
            reminderHour: _reminderHour,
            reminderMinute: _reminderMinute,
            reminderDays: _reminderDays,
            onReminderEnabledChanged: (val) async {
              final repo = ref.read(settingsRepositoryProvider);
              await repo.setReminderEnabled(val);
              setState(() => _reminderEnabled = val);
              if (val) {
                await NotificationService().requestPermissions();
                await _scheduleReminders();
              } else {
                await _cancelReminders();
              }
            },
            onPickTime: _pickTime,
            onDaySelected: (day, selected) {
              setState(() {
                if (selected) {
                  _reminderDays.add(day);
                } else if (_reminderDays.length > 1) {
                  _reminderDays.remove(day);
                }
              });
              ref
                  .read(settingsRepositoryProvider)
                  .setReminderDays(_reminderDays);
              if (_reminderEnabled) {
                _scheduleReminders();
              }
            },
          ),
          const SizedBox(height: 24),
          BackupSettingsCard(
            onExport: _exportBackup,
            onImport: _importBackup,
            onDeleteAll: _resetAllData,
          ),
          const SizedBox(height: 24),
          const AppInfoSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
