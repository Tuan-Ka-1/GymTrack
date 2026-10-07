import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/database/app_database.dart';
import '../../../../domain/repositories/workout_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../exercises/domain/exercise_display_helper.dart';
import 'workout_set_row.dart';

class ActiveExerciseCard extends ConsumerWidget {
  final ExerciseSessionEntry exSession;
  final String weightUnit;
  final AppDatabase db;
  final WorkoutRepository repo;

  const ActiveExerciseCard({
    super.key,
    required this.exSession,
    required this.weightUnit,
    required this.db,
    required this.repo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final catalog = ref.watch(exerciseCatalogProvider).value;
    final locale = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;

    final displayName = ExerciseDisplayHelper.resolveName(
      exSession.exerciseName,
      catalog: catalog,
      locale: locale,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.timer_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    ref
                        .read(restTimerProvider.notifier)
                        .startTimer(seconds: 90, exerciseName: displayName);
                  },
                ),
              ],
            ),
            // Section 11: Auto-fill / Show previous performance
            FutureBuilder<List<WorkoutSetEntry>>(
              future: exSession.exerciseId != null
                  ? repo.getPreviousPerformance(exSession.exerciseId!)
                  : Future.value([]),
              builder: (context, prevSnapshot) {
                final prevSets = prevSnapshot.data ?? [];
                if (prevSets.isEmpty) return const SizedBox.shrink();

                final prevSummary = prevSets
                    .map(
                      (s) =>
                          '${Formatters.formatWeight(s.weight, unit: weightUnit)}×${s.reps}',
                    )
                    .join('  •  ');

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.history,
                        size: 16,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.activeWorkoutPrevious(prevSummary),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            // Sets Table Header
            Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    l10n.activeWorkoutSetHeader,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Center(
                    child: Text(
                      l10n.activeWorkoutWeightHeader(weightUnit),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Center(
                    child: Text(
                      l10n.activeWorkoutRepsHeader,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(
                  width: 48,
                  child: Center(
                    child: Icon(Icons.check, size: 18, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            // Sets Rows
            StreamBuilder<List<WorkoutSetEntry>>(
              stream: repo.watchSetsForExerciseSession(exSession.id),
              builder: (context, setSnapshot) {
                final sets = setSnapshot.data ?? [];
                return Column(
                  children: [
                    ...sets.map(
                      (setEntry) => WorkoutSetRow(
                        key: ValueKey(setEntry.id),
                        setEntry: setEntry,
                        weightUnit: weightUnit,
                        repo: repo,
                        exerciseName: displayName,
                        restSeconds: exSession.restSeconds,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(
                          l10n.activeWorkoutAddSet,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          final autoFill = ref.read(autoFillPreviousProvider);
                          repo.addSetToExerciseSession(
                            exSession.id,
                            autoFillPrevious: autoFill,
                          );
                        },
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
