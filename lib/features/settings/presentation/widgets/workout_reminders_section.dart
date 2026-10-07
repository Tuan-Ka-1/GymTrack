import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../services/notification_service.dart';

class WorkoutRemindersSection extends StatelessWidget {
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final List<int> reminderDays;
  final ValueChanged<bool> onReminderEnabledChanged;
  final VoidCallback onPickTime;
  final void Function(int day, bool selected) onDaySelected;

  const WorkoutRemindersSection({
    super.key,
    required this.reminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
    required this.reminderDays,
    required this.onReminderEnabledChanged,
    required this.onPickTime,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final shortDayNames = [
      '',
      l10n.dayMonShort,
      l10n.dayTueShort,
      l10n.dayWedShort,
      l10n.dayThuShort,
      l10n.dayFriShort,
      l10n.daySatShort,
      l10n.daySunShort,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsSectionReminders,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: Text(l10n.settingsReminderSwitchTitle),
                subtitle: Text(l10n.settingsReminderSwitchSubtitle),
                value: reminderEnabled,
                onChanged: onReminderEnabledChanged,
              ),
              if (reminderEnabled) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(l10n.settingsReminderTimeTitle),
                  trailing: TextButton(
                    onPressed: onPickTime,
                    child: Text(
                      '${reminderHour.toString().padLeft(2, '0')}:${reminderMinute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsReminderDaysTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (int i = 1; i <= 7; i++)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: FilterChip(
                                  label: Text(shortDayNames[i]),
                                  selected: reminderDays.contains(i),
                                  onSelected: (selected) =>
                                      onDaySelected(i, selected),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.send_rounded),
                  title: Text(l10n.settingsReminderTestTitle),
                  subtitle: Text(l10n.settingsReminderTestSubtitle),
                  trailing: FilledButton.tonal(
                    onPressed: () {
                      NotificationService().showInstantReminder(
                        title: l10n.settingsReminderNotificationTitle,
                        body: l10n.settingsReminderNotificationBodyInstant,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.settingsReminderTestSnackBar),
                        ),
                      );
                    },
                    child: Text(l10n.commonTest),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
