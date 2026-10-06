import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) => Card(
    child: Column(
      children: [
        ListTile(
          leading: const Icon(Icons.upload_file_outlined),
          title: const Text('Export Backup (JSON)'),
          subtitle: const Text(
            'Export all workouts, routines, and measurements',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onExport,
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.download_for_offline_outlined),
          title: const Text('Import Backup'),
          subtitle: const Text('Restore data from JSON backup'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onImport,
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text(
            'Delete All Data',
            style: TextStyle(color: Colors.red),
          ),
          subtitle: const Text('Erase all local data with confirmation'),
          onTap: onDeleteAll,
        ),
      ],
    ),
  );
}
