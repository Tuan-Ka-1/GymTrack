import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class AppInfoSection extends StatelessWidget {
  const AppInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsSectionAbout,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('GymTrack'),
                subtitle: Text(l10n.settingsAboutSubtitle),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'GymTrack',
                    applicationVersion: '1.0.0',
                    applicationLegalese: l10n.settingsAboutLegalese,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
