import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class BackupSettingsCard extends StatelessWidget {
  final VoidCallback onExport;
  final VoidCallback onImport;
  final VoidCallback onDeleteAll;

  const BackupSettingsCard({
    super.key,
    required this.onExport,
    required this.onImport,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: Text(l10n.settingsExportTitle),
            subtitle: Text(l10n.settingsExportSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: onExport,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.download_for_offline_outlined),
            title: Text(l10n.settingsImportTitle),
            subtitle: Text(l10n.settingsImportSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: onImport,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(
              l10n.settingsDeleteAllTitle,
              style: const TextStyle(color: Colors.red),
            ),
            subtitle: Text(l10n.settingsDeleteAllSubtitle),
            onTap: onDeleteAll,
          ),
        ],
      ),
    );
  }
}
