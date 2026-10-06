import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';
import 'widgets/day_card.dart';
import 'widgets/plan_dialogs.dart';

class PlanDetailScreen extends ConsumerStatefulWidget {
  final int planId;

  const PlanDetailScreen({super.key, required this.planId});

  @override
  ConsumerState<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends ConsumerState<PlanDetailScreen> {
  Future<void> _addWorkoutDay(BuildContext context, int currentDayCount) async {
    final dayName = await PlanDialogs.showAddWorkoutDay(context);
    if (dayName != null) {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.createWorkoutDay(
        widget.planId,
        dayName,
        null,
        currentDayCount,
      );
    }
  }

  Future<void> _renamePlan(BuildContext context, WorkoutPlanEntry plan) async {
    final newName = await PlanDialogs.showRenamePlan(context, plan);
    if (newName != null) {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.updateWorkoutPlan(plan.copyWith(name: newName));
    }
  }

  Future<void> _renameDay(BuildContext context, WorkoutDayEntry day) async {
    final newName = await PlanDialogs.showRenameDay(context, day);
    if (newName != null) {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.updateWorkoutDay(day.copyWith(name: newName));
    }
  }

  Future<void> _editExerciseParams(
    BuildContext context,
    WorkoutExerciseEntry we,
  ) async {
    final updated = await PlanDialogs.showEditExerciseParams(context, we);
    if (updated != null) {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.updateWorkoutExercise(updated);
    }
  }

  Future<void> _startWorkoutForDay(
    WorkoutPlanEntry plan,
    WorkoutDayEntry day,
  ) async {
    final repo = ref.read(workoutRepositoryProvider);
    final dayExercises = await repo.getExercisesForDay(day.id);

    final autoFill = ref.read(autoFillPreviousProvider);
    final sessionId = await repo.startWorkoutSession(
      workoutDayId: day.id,
      planName: plan.name,
      dayName: '${plan.name} - ${day.name}',
      workoutExercises: dayExercises,
      autoFillPrevious: autoFill,
    );

    if (mounted) {
      context.push('/active-workout/$sessionId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final repo = ref.watch(workoutRepositoryProvider);

    return FutureBuilder<WorkoutPlanEntry?>(
      future: (db.select(
        db.workoutPlans,
      )..where((t) => t.id.equals(widget.planId))).getSingleOrNull(),
      builder: (context, planSnapshot) {
        final plan = planSnapshot.data;
        if (plan == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(plan.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Rename Plan',
                onPressed: () => _renamePlan(context, plan),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('Add Day'),
            onPressed: () async {
              final days = await repo.getDaysForPlan(plan.id);
              if (context.mounted) {
                _addWorkoutDay(context, days.length);
              }
            },
          ),
          body: StreamBuilder<List<WorkoutDayEntry>>(
            stream: repo.watchDaysForPlan(plan.id),
            builder: (context, daysSnapshot) {
              final days = daysSnapshot.data ?? [];
              if (days.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 56,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No workout days yet',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add days like "Push", "Pull", or "Legs" to organize exercises.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Workout Day'),
                        onPressed: () => _addWorkoutDay(context, 0),
                      ),
                    ],
                  ),
                );
              }

              return ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: days.length,
                onReorder: (oldIndex, newIndex) async {
                  if (oldIndex < newIndex) newIndex--;
                  final dayIds = days.map((d) => d.id).toList();
                  final dayId = dayIds.removeAt(oldIndex);
                  dayIds.insert(newIndex, dayId);
                  await repo.reorderDaysForPlan(plan.id, dayIds);
                },
                itemBuilder: (context, index) {
                  final day = days[index];
                  return DayCard(
                    key: ValueKey(day.id),
                    day: day,
                    plan: plan,
                    repo: repo,
                    db: db,
                    onStartWorkout: () => _startWorkoutForDay(plan, day),
                    onRenameDay: () => _renameDay(context, day),
                    onEditExercise: _editExerciseParams,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
