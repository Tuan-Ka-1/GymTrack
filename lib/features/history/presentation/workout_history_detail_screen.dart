import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../data/database/app_database.dart';

class WorkoutHistoryDetailScreen extends ConsumerWidget {
  final int sessionId;

  const WorkoutHistoryDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final repo = ref.watch(workoutRepositoryProvider);
    final weightUnit = ref.watch(weightUnitProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Delete Log',
            onPressed: () async {
              final confirmed = await ConfirmDialog.show(
                context,
                title: 'Delete Workout Log?',
                message: 'Are you sure you want to permanently delete this workout from history?',
                isDestructive: true,
              );
              if (confirmed) {
                await repo.deleteWorkoutSession(sessionId);
                if (context.mounted) {
                  context.pop();
                }
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<WorkoutSessionEntry?>(
        future: (db.select(
          db.workoutSessions,
        )..where((t) => t.id.equals(sessionId))).getSingleOrNull(),
        builder: (context, sessionSnapshot) {
          if (sessionSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final session = sessionSnapshot.data;
          if (session == null) {
            return const Center(child: Text('Session not found'));
          }

          return FutureBuilder<List<ExerciseSessionEntry>>(
            future: repo.getExerciseSessionsForWorkout(sessionId),
            builder: (context, exSnapshot) {
              final exSessions = exSnapshot.data ?? [];

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.dayName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.formatDate(
                              session.finishedAt ?? session.startedAt,
                            ),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMiniStat(
                                'Duration',
                                Formatters.formatDuration(
                                  session.durationMinutes,
                                ),
                                theme,
                              ),
                              _buildMiniStat(
                                'Volume',
                                Formatters.formatVolume(
                                  session.totalVolume,
                                  unit: weightUnit,
                                ),
                                theme,
                              ),
                              _buildMiniStat(
                                'Exercises',
                                '${exSessions.length}',
                                theme,
                              ),
                            ],
                          ),
                          if (session.notes != null &&
                              session.notes!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Note: ${session.notes}',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Exercises & Sets',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...exSessions.map(
                    (es) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              es.exerciseName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder<List<WorkoutSetEntry>>(
                              future: repo.getSetsForExerciseSession(es.id),
                              builder: (context, setSnapshot) {
                                final sets = setSnapshot.data ?? [];
                                if (sets.isEmpty) {
                                  return const Text(
                                    'No sets recorded',
                                    style: TextStyle(color: Colors.grey),
                                  );
                                }

                                return Column(
                                  children: sets
                                      .map(
                                        (s) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Set ${s.setNumber}:',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                '${Formatters.formatWeight(s.weight, unit: weightUnit)} × ${s.reps} reps',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const Spacer(),
                                              if (s.completed)
                                                const Icon(
                                                  Icons.check_circle,
                                                  size: 18,
                                                  color: Colors.green,
                                                )
                                              else
                                                const Icon(
                                                  Icons.remove_circle_outline,
                                                  size: 18,
                                                  color: Colors.grey,
                                                ),
                                            ],
                                          ),
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
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
