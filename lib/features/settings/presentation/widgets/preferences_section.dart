import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';

class PreferencesSection extends ConsumerWidget {
  final int defaultRestTime;
  final bool autoFillPrevious;
  final ValueChanged<int> onRestTimeChanged;
  final ValueChanged<bool> onAutoFillChanged;

  const PreferencesSection({
    super.key,
    required this.defaultRestTime,
    required this.autoFillPrevious,
    required this.onRestTimeChanged,
    required this.onAutoFillChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final weightUnit = ref.watch(weightUnitProvider);
    final isDark = themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferences',
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
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark Mode'),
                subtitle: const Text('Sleek dark theme optimized for the gym'),
                value: isDark,
                onChanged: (_) {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.scale_outlined),
                title: const Text('Weight Unit'),
                subtitle: Text('Currently: ${weightUnit.toUpperCase()}'),
                trailing: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'kg', label: Text('KG')),
                    ButtonSegment(value: 'lb', label: Text('LB')),
                  ],
                  selected: {weightUnit},
                  onSelectionChanged: (val) {
                    ref.read(weightUnitProvider.notifier).setUnit(val.first);
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: const Text('Default Rest Timer'),
                subtitle: Text('$defaultRestTime seconds between sets'),
                trailing: DropdownButton<int>(
                  value: defaultRestTime,
                  items: const [
                    DropdownMenuItem(value: 60, child: Text('60s')),
                    DropdownMenuItem(value: 90, child: Text('90s')),
                    DropdownMenuItem(value: 120, child: Text('120s')),
                    DropdownMenuItem(value: 180, child: Text('180s')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      onRestTimeChanged(val);
                    }
                  },
                ),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.auto_fix_high_outlined),
                title: const Text('Auto-fill Previous Performance'),
                subtitle: const Text(
                  'When ON, pre-fills weight/reps from last workout. When OFF, sets start empty (reference only).',
                ),
                value: autoFillPrevious,
                onChanged: onAutoFillChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
