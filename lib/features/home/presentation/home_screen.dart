import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/database/app_database.dart';
import '../../../l10n/app_localizations.dart';
import '../../exercises/domain/exercise_display_helper.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.homeGreetingMorning;
    if (hour < 18) return l10n.homeGreetingAfternoon;
    return l10n.homeGreetingEvening;
  }

  Future<void> _startQuickWorkout(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(workoutRepositoryProvider);
    final activePlan = await repo.getActiveWorkoutPlan();

    if (activePlan != null) {
      final days = await repo.getDaysForPlan(activePlan.id);
      if (days.isNotEmpty) {
        // Pick day based on weekday or first day
        final todayWeekday = DateTime.now().weekday;
        final matchingDay = days.firstWhere(
          (d) => d.dayOfWeek == todayWeekday,
          orElse: () => days.first,
        );

        final dayExercises = await repo.getExercisesForDay(matchingDay.id);

        final autoFill = ref.read(autoFillPreviousProvider);
        final sessionId = await repo.startWorkoutSession(
          workoutDayId: matchingDay.id,
          planName: activePlan.name,
          dayName: '${activePlan.name} - ${matchingDay.name}',
          workoutExercises: dayExercises,
          autoFillPrevious: autoFill,
        );

        if (context.mounted) {
          context.push('/active-workout/$sessionId');
        }
        return;
      }
    }

    // Default quick freestyle session
    final autoFill = ref.read(autoFillPreviousProvider);
    final sessionId = await repo.startWorkoutSession(
      dayName: 'Quick Workout',
      autoFillPrevious: autoFill,
    );
    if (context.mounted) {
      context.push('/active-workout/$sessionId');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(workoutRepositoryProvider);
    final bodyRepo = ref.watch(bodyRepositoryProvider);
    final weightUnit = ref.watch(weightUnitProvider);
    final historyAsync = ref.watch(workoutHistoryStreamProvider);
    final prsAsync = ref.watch(allTimePRsProvider);
    final catalog = ref.watch(exerciseCatalogProvider).value;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(l10n),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
            const Text(
              'GymTrack',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.scale_rounded),
            tooltip: l10n.homeTooltipBodyWeight,
            onPressed: () => context.push('/body-tracking'),
          ),
          IconButton(
            icon: const Icon(Icons.fitness_center),
            tooltip: l10n.homeTooltipExerciseLibrary,
            onPressed: () => context.push('/exercises'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // TODAY'S WORKOUT HERO CARD (Section 7)
          FutureBuilder<WorkoutPlanEntry?>(
            future: repo.getActiveWorkoutPlan(),
            builder: (context, planSnapshot) {
              final plan = planSnapshot.data;

              return Card(
                color: const Color(0xFF1B2332),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              l10n.homeTodayBadge,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            Formatters.formatDayOfWeek(
                              DateTime.now(),
                              locale: locale,
                            ),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        plan != null ? plan.name : l10n.homeQuickWorkoutRoutine,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan?.description ?? l10n.homeNoRoutineDesc,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow_rounded, size: 24),
                          label: Text(
                            l10n.homeStartWorkout,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          onPressed: () => _startQuickWorkout(context, ref),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // QUICK STATS ROW: Current Weight & Last Workout
          Row(
            children: [
              // Latest Body Weight
              Expanded(
                child: FutureBuilder<BodyMeasurementEntry?>(
                  future: bodyRepo.getLatestBodyMeasurement(),
                  builder: (context, snapshot) {
                    final latest = snapshot.data;
                    return InkWell(
                      onTap: () => context.push('/body-tracking'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.monitor_weight_outlined,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.homeBodyWeight,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              latest != null
                                  ? Formatters.formatWeight(
                                      latest.bodyWeight,
                                      unit: weightUnit,
                                    )
                                  : '--',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              latest != null
                                  ? Formatters.formatShortDate(
                                      latest.date,
                                      locale: locale,
                                    )
                                  : l10n.homeTapToLog,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Last Workout Duration
              Expanded(
                child: historyAsync.when(
                  data: (sessions) {
                    final lastSession = sessions.isNotEmpty
                        ? sessions.first
                        : null;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.history_rounded,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.homeLastSession,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lastSession != null
                                ? Formatters.formatDuration(
                                    lastSession.durationMinutes,
                                  )
                                : '--',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lastSession != null
                                ? Formatters.formatShortDate(
                                    lastSession.finishedAt ??
                                        lastSession.startedAt,
                                    locale: locale,
                                  )
                                : l10n.homeNoWorkoutsYet,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // RECENT PR HIGHLIGHTS (Section 7)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.homeRecentPrHighlights,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/progress'),
                child: Text(l10n.homeViewAll),
              ),
            ],
          ),
          prsAsync.when(
            data: (prs) {
              if (prs.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.emoji_events_outlined,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.homeEmptyPrDesc,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final topPRs = prs.take(3).toList();
              return Column(
                children: topPRs
                    .map(
                      (pr) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.military_tech_rounded,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            ExerciseDisplayHelper.resolveName(
                              pr.exerciseName,
                              catalog: catalog,
                              locale: locale,
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            l10n.homePrAchievedOn(
                              Formatters.formatShortDate(
                                pr.achievedAt,
                                locale: locale,
                              ),
                            ),
                          ),
                          trailing: Text(
                            Formatters.formatWeight(
                              pr.maxWeight,
                              unit: weightUnit,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
