import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../data/database/app_database.dart';
import '../../../l10n/app_localizations.dart';
import '../../exercises/domain/exercise_display_helper.dart';

class WorkoutHistoryDetailScreen extends ConsumerWidget {
  final int sessionId;

  const WorkoutHistoryDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final repo = ref.watch(workoutRepositoryProvider);
    final weightUnit = ref.watch(weightUnitProvider);
    final catalog = ref.watch(exerciseCatalogProvider).value;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyDetailTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: l10n.historyDetailDeleteTooltip,
            onPressed: () async {
              final confirmed = await ConfirmDialog.show(
                context,
                title: l10n.historyDetailDeleteTitle,
                message: l10n.historyDetailDeleteMessage,
                confirmText: l10n.commonDelete,
                cancelText: l10n.commonCancel,
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
            return Center(child: Text(l10n.historyDetailSessionNotFound));
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
                              locale: locale,
                            ),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMiniStat(
                                l10n.summaryDuration,
                                Formatters.formatDuration(
                                  session.durationMinutes,
                                ),
                                theme,
                              ),
                              _buildMiniStat(
                                l10n.summaryVolume,
                                Formatters.formatVolume(
                                  session.totalVolume,
                                  unit: weightUnit,
                                ),
                                theme,
                              ),
                              _buildMiniStat(
                                l10n.summaryExercises,
                                '${exSessions.length}',
                                theme,
                              ),
                            ],
                          ),
                          if (session.notes != null &&
                              session.notes!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              l10n.summaryNotePrefix(session.notes!),
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
                    l10n.historyDetailExercisesAndSets,
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
                              ExerciseDisplayHelper.resolveName(
                                es.exerciseName,
                                catalog: catalog,
                                locale: locale,
                              ),
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
                                  return Text(
                                    l10n.historyDetailNoSets,
                                    style: const TextStyle(color: Colors.grey),
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
                                                l10n.historyDetailSetLabel(
                                                  s.setNumber,
                                                ),
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                l10n.historyDetailSetSummary(
                                                  Formatters.formatWeight(
                                                    s.weight,
                                                    unit: weightUnit,
                                                  ),
                                                  s.reps,
                                                ),
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
