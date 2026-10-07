import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/database/app_database.dart';
import '../../../l10n/app_localizations.dart';

class WorkoutPlansScreen extends ConsumerWidget {
  const WorkoutPlansScreen({super.key});

  Future<void> _createNewPlan(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final descController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n.dialogCreatePlanTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.dialogPlanNameLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: l10n.dialogPlanDescLabel),
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
              if (nameController.text.trim().isNotEmpty) {
                Navigator.of(ctx).pop(true);
              }
            },
            child: Text(l10n.commonCreate),
          ),
        ],
      ),
    );

    if (created == true) {
      final repo = ref.read(workoutRepositoryProvider);
      final id = await repo.createWorkoutPlan(
        nameController.text.trim(),
        descController.text.trim().isEmpty ? null : descController.text.trim(),
      );
      if (context.mounted) {
        context.push('/plan-detail/$id');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(workoutPlansStreamProvider);
    final repo = ref.watch(workoutRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workoutPlansTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.workoutPlansNewTooltip,
            onPressed: () => _createNewPlan(context, ref),
          ),
        ],
      ),
      body: plansAsync.when(
        data: (plans) {
          if (plans.isEmpty) {
            return EmptyState(
              icon: Icons.fitness_center_rounded,
              title: l10n.workoutPlansEmptyTitle,
              subtitle: l10n.workoutPlansEmptySubtitle,
              action: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(l10n.workoutPlansCreateButton),
                onPressed: () => _createNewPlan(context, ref),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push('/plan-detail/${plan.id}'),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                plan.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (val) async {
                                if (val == 'delete') {
                                  final confirmed = await ConfirmDialog.show(
                                    context,
                                    title: l10n.workoutPlansDeleteTitle,
                                    message: l10n.workoutPlansDeleteMessage(
                                      plan.name,
                                    ),
                                    isDestructive: true,
                                  );
                                  if (confirmed) {
                                    await repo.deleteWorkoutPlan(plan.id);
                                  }
                                }
                              },
                              itemBuilder: (ctx) => [
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.workoutPlansDeleteAction,
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (plan.description != null &&
                            plan.description!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            plan.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        StreamBuilder<List<WorkoutDayEntry>>(
                          stream: repo.watchDaysForPlan(plan.id),
                          builder: (context, snapshot) {
                            final days = snapshot.data ?? [];
                            if (days.isEmpty) {
                              return Text(
                                l10n.workoutPlansDayCount(0),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              );
                            }
                            return Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: days
                                  .map(
                                    (day) => Chip(
                                      label: Text(
                                        day.name,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      backgroundColor:
                                          theme.colorScheme.surface,
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
