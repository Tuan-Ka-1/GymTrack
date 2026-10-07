import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../data/database/app_database.dart';
import '../../../../domain/repositories/workout_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../exercises/domain/exercise_display_helper.dart';
import 'exercise_picker_dialog.dart';

class DayCard extends StatelessWidget {
  final WorkoutDayEntry day;
  final WorkoutPlanEntry plan;
  final WorkoutRepository repo;
  final AppDatabase db;
  final VoidCallback onStartWorkout;
  final VoidCallback onRenameDay;
  final void Function(BuildContext, WorkoutExerciseEntry) onEditExercise;

  const DayCard({
    super.key,
    required this.day,
    required this.plan,
    required this.repo,
    required this.db,
    required this.onStartWorkout,
    required this.onRenameDay,
    required this.onEditExercise,
  });

  Future<void> _addExerciseToDay(BuildContext context) async {
    final selected = await ExercisePickerDialog.show(context);
    if (selected != null) {
      final currentExercises = await repo.getExercisesForDay(day.id);
      await repo.addExerciseToDay(day.id, selected.id, currentExercises.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    day.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                  tooltip: l10n.dayCardRenameTooltip,
                  onPressed: onRenameDay,
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(
                    l10n.dayCardStartButton,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: onStartWorkout,
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: () async {
                    final confirmed = await ConfirmDialog.show(
                      context,
                      title: l10n.dayCardDeleteTitle,
                      message: l10n.dayCardDeleteMessage(day.name),
                      isDestructive: true,
                    );
                    if (confirmed) {
                      await repo.deleteWorkoutDay(day.id);
                    }
                  },
                ),
              ],
            ),
            const Divider(height: 16),
            StreamBuilder<List<WorkoutExerciseEntry>>(
              stream: repo.watchExercisesForDay(day.id),
              builder: (context, exSnapshot) {
                final dayExercises = exSnapshot.data ?? [];
                if (dayExercises.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: Text(l10n.dayCardAddExerciseEmpty),
                        onPressed: () => _addExerciseToDay(context),
                      ),
                    ),
                  );
                }

                return ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorder: (oldIndex, newIndex) async {
                    if (oldIndex < newIndex) newIndex--;
                    final item = dayExercises.removeAt(oldIndex);
                    dayExercises.insert(newIndex, item);
                    final idsInOrder = dayExercises.map((e) => e.id).toList();
                    await repo.reorderExercisesForDay(day.id, idsInOrder);
                  },
                  children: [
                    ...dayExercises
                        .where((we) => we.exerciseId != null)
                        .map(
                          (we) => ExerciseListTile(
                            key: ValueKey(we.id),
                            we: we,
                            db: db,
                            repo: repo,
                            onEdit: onEditExercise,
                          ),
                        ),
                    Padding(
                      key: const ValueKey('add_exercise_button'),
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(
                            l10n.dayCardAddExerciseButton,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _addExerciseToDay(context),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseListTile extends ConsumerWidget {
  final WorkoutExerciseEntry we;
  final AppDatabase db;
  final WorkoutRepository repo;
  final void Function(BuildContext, WorkoutExerciseEntry) onEdit;

  const ExerciseListTile({
    super.key,
    required this.we,
    required this.db,
    required this.repo,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(exerciseCatalogProvider).value;
    final locale = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<ExerciseEntry?>(
      future: (db.select(
        db.exercises,
      )..where((t) => t.id.equals(we.exerciseId!))).getSingleOrNull(),
      builder: (context, exDetailSnapshot) {
        final exercise = exDetailSnapshot.data;
        if (exercise == null) {
          return const SizedBox.shrink();
        }

        final exerciseDisplayName = ExerciseDisplayHelper.resolveName(
          exercise.name,
          catalog: catalog,
          locale: locale,
        );

        return ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          leading: const Icon(Icons.drag_handle, size: 18, color: Colors.grey),
          title: Text(
            exerciseDisplayName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            l10n.planDetailExerciseSubtitle(
              we.targetSets,
              we.targetMinReps,
              we.targetMaxReps,
              we.restSeconds,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  size: 18,
                  color: Colors.blueAccent,
                ),
                onPressed: () => onEdit(context, we),
                tooltip: l10n.planDetailEditTooltip,
              ),
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  size: 18,
                  color: Colors.redAccent,
                ),
                onPressed: () => repo.removeExerciseFromDay(we.id),
                tooltip: l10n.planDetailRemoveTooltip,
              ),
            ],
          ),
        );
      },
    );
  }
}
