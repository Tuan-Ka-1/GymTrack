import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../l10n/app_localizations.dart';

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
    final currentLang = ref.watch(languageProvider);
    final isDark = themeMode == ThemeMode.dark;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsSectionPreferences,
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
                title: Text(l10n.settingsDarkModeTitle),
                subtitle: Text(l10n.settingsDarkModeSubtitle),
                value: isDark,
                onChanged: (_) {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.scale_outlined),
                title: Text(l10n.settingsWeightUnitTitle),
                subtitle: Text(
                  l10n.settingsWeightUnitSubtitle(weightUnit.toUpperCase()),
                ),
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.language_outlined),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.settingsLanguageTitle,
                                style: theme.textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.settingsLanguageSubtitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'en', label: Text('English')),
                          ButtonSegment(value: 'vi', label: Text('Tiếng Việt')),
                        ],
                        selected: {currentLang},
                        onSelectionChanged: (val) {
                          ref
                              .read(languageProvider.notifier)
                              .setLanguage(val.first);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(l10n.settingsRestTimerTitle),
                subtitle: Text(l10n.settingsRestTimerSubtitle(defaultRestTime)),
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
                title: Text(l10n.settingsAutoFillTitle),
                subtitle: Text(l10n.settingsAutoFillSubtitle),
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
