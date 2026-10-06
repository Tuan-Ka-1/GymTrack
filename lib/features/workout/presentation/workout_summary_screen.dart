import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/database/app_database.dart';

class WorkoutSummaryScreen extends ConsumerWidget {
  final int sessionId;

  const WorkoutSummaryScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final repo = ref.watch(workoutRepositoryProvider);
    final weightUnit = ref.watch(weightUnitProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<WorkoutSessionEntry?>(
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

                return FutureBuilder<int>(
                  future: _getTotalCompletedSets(db, exSessions),
                  builder: (context, setSnapshot) {
                    final totalSets = setSnapshot.data ?? 0;

                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.15,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.emoji_events_rounded,
                              size: 72,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Workout Completed! 💪',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            session.dayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Stats Grid
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.cardTheme.color,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    _buildStatItem(
                                      'Duration',
                                      Formatters.formatDuration(
                                        session.durationMinutes,
                                      ),
                                      Icons.schedule_rounded,
                                      theme,
                                    ),
                                    _buildStatItem(
                                      'Exercises',
                                      '${exSessions.length}',
                                      Icons.fitness_center_rounded,
                                      theme,
                                    ),
                                  ],
                                ),
                                const Divider(height: 32),
                                Row(
                                  children: [
                                    _buildStatItem(
                                      'Sets',
                                      '$totalSets',
                                      Icons.repeat_rounded,
                                      theme,
                                    ),
                                    _buildStatItem(
                                      'Total Volume',
                                      Formatters.formatVolume(
                                        session.totalVolume,
                                        unit: weightUnit,
                                      ),
                                      Icons.bar_chart_rounded,
                                      theme,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (session.notes != null &&
                              session.notes!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.cardTheme.color,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Note: ${session.notes}',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                context.go('/');
                              },
                              child: const Text('BACK TO HOME'),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<int> _getTotalCompletedSets(
    AppDatabase db,
    List<ExerciseSessionEntry> exSessions,
  ) async {
    int total = 0;
    for (final es in exSessions) {
      final sets = await (db.select(
        db.workoutSets,
      )..where((t) => t.exerciseSessionId.equals(es.id))).get();
      total += sets.where((s) => s.completed).length;
    }
    return total;
  }
}
