import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../l10n/app_localizations.dart';
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
        await rescheduleWorkoutReminders(ref);
      }
    }
  }

  Future<void> _exportBackup() async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(settingsRepositoryProvider);
    final json = await repo.exportBackupJson();

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.settingsExportDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.settingsExportDialogMessage),
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
                  SnackBar(content: Text(l10n.settingsExportCopiedSnackBar)),
                );
              },
              child: Text(l10n.settingsExportCopyButton),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                SharePlus.instance.share(
                  ShareParams(text: json, subject: 'GymTrack_Backup.json'),
                );
              },
              child: Text(l10n.settingsExportShareButton),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _importBackup() async {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsImportDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsImportDialogMessage),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: l10n.settingsImportDialogHint,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.of(ctx).pop(true);
              }
            },
            child: Text(l10n.commonRestore),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final repo = ref.read(settingsRepositoryProvider);
        await repo.importBackupJson(controller.text.trim());
        // Run catalog sync after import to ensure catalog exercises are present and backfilled
        await ref.read(exerciseCatalogSyncProvider).syncIfNeeded(force: true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.settingsImportSuccessSnackBar)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.settingsImportFailedSnackBar(e.toString())),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _resetAllData() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.settingsDeleteAllDialogTitle,
      message: l10n.settingsDeleteAllDialogMessage,
      confirmText: l10n.settingsDeleteAllDialogConfirm,
      cancelText: l10n.commonCancel,
      isDestructive: true,
    );

    if (confirmed) {
      final repo = ref.read(settingsRepositoryProvider);
      await repo.clearAllData();
      // Re-seed and re-sync catalog after clearing all data
      final db = ref.read(databaseProvider);
      final catalog = await ref.read(exerciseCatalogProvider.future);
      await db.seedDatabaseIfEmpty(catalog: catalog);
      await ref.read(exerciseCatalogSyncProvider).syncIfNeeded(force: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsDeleteAllSuccessSnackBar)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
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
                await ref
                    .read(notificationServiceProvider)
                    .requestPermissions();
                await rescheduleWorkoutReminders(ref);
              } else {
                await ref
                    .read(notificationServiceProvider)
                    .cancelWorkoutReminders();
              }
            },
            onPickTime: _pickTime,
            onDaySelected: (day, selected) async {
              setState(() {
                if (selected) {
                  _reminderDays.add(day);
                } else if (_reminderDays.length > 1) {
                  _reminderDays.remove(day);
                }
              });
              await ref
                  .read(settingsRepositoryProvider)
                  .setReminderDays(_reminderDays);
              if (_reminderEnabled) {
                await rescheduleWorkoutReminders(ref);
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
