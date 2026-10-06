import 'package:flutter/material.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workout Reminders',
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
                title: const Text('Daily / Scheduled Reminder'),
                subtitle: const Text(
                  'Local notification to remind you to workout',
                ),
                value: reminderEnabled,
                onChanged: onReminderEnabledChanged,
              ),
              if (reminderEnabled) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Reminder Time'),
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
                      const Text(
                        'Reminder Days',
                        style: TextStyle(
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
                                  label: Text(
                                    [
                                      '',
                                      'Mon',
                                      'Tue',
                                      'Wed',
                                      'Thu',
                                      'Fri',
                                      'Sat',
                                      'Sun',
                                    ][i],
                                  ),
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
                  title: const Text('Test Notification'),
                  subtitle: const Text('Sends an instant local notification'),
                  trailing: FilledButton.tonal(
                    onPressed: () {
                      NotificationService().showInstantReminder(
                        title: 'Time to workout 💪',
                        body:
                            'Don\'t skip today\'s session! Consistency is key.',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notification triggered!'),
                        ),
                      );
                    },
                    child: const Text('Test'),
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
