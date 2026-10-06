import 'package:flutter/material.dart';

class AppInfoSection extends StatelessWidget {
  const AppInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
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
                subtitle: const Text('Version 1.0.0 • 100% Local & Offline'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'GymTrack',
                    applicationVersion: '1.0.0',
                    applicationLegalese: 'Local-first offline fitness workout tracker.\nBuilt with Flutter, Drift & SQLite.',
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
