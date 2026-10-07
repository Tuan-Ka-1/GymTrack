import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/database/app_database.dart';
import '../../../l10n/app_localizations.dart';
import '../../exercises/domain/exercise_display_helper.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(workoutHistoryStreamProvider);
    final repo = ref.watch(workoutRepositoryProvider);
    final weightUnit = ref.watch(weightUnitProvider);
    final catalog = ref.watch(exerciseCatalogProvider).value;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: historyAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return EmptyState(
              icon: Icons.history_rounded,
              title: l10n.historyEmptyTitle,
              subtitle: l10n.historyEmptySubtitle,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push('/history-detail/${session.id}'),
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
                                session.dayName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              Formatters.formatDate(
                                session.finishedAt ?? session.startedAt,
                                locale: locale,
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FutureBuilder<List<ExerciseSessionEntry>>(
                          future: repo.getExerciseSessionsForWorkout(
                            session.id,
                          ),
                          builder: (context, exSnapshot) {
                            final exSessions = exSnapshot.data ?? [];
                            final exNames = exSessions
                                .map(
                                  (e) => ExerciseDisplayHelper.resolveName(
                                    e.exerciseName,
                                    catalog: catalog,
                                    locale: locale,
                                  ),
                                )
                                .take(4)
                                .join(', ');

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (exNames.isNotEmpty)
                                  Text(
                                    exNames +
                                        (exSessions.length > 4 ? '...' : ''),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildChip(
                                      Icons.schedule,
                                      Formatters.formatDuration(
                                        session.durationMinutes,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildChip(
                                      Icons.bar_chart,
                                      Formatters.formatVolume(
                                        session.totalVolume,
                                        unit: weightUnit,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildChip(
                                      Icons.fitness_center,
                                      l10n.historyExercisesCount(
                                        exSessions.length,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
        error: (e, _) => Center(child: Text(l10n.commonError(e.toString()))),
      ),
    );
  }

  Widget _buildChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
