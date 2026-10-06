import 'package:flutter/material.dart';

import '../../../../data/database/app_database.dart';

abstract class PlanDialogs {
  static Future<String?> showAddWorkoutDay(BuildContext context) async {
    final nameController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Workout Day'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Day Name (e.g., Push, Chest & Back)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.of(ctx).pop(true);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (created == true && nameController.text.trim().isNotEmpty) {
      return nameController.text.trim();
    }
    return null;
  }

  static Future<String?> showRenamePlan(
    BuildContext context,
    WorkoutPlanEntry plan,
  ) async {
    final nameController = TextEditingController(text: plan.name);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Plan'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Plan name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.of(ctx).pop(true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed == true && nameController.text.trim().isNotEmpty) {
      return nameController.text.trim();
    }
    return null;
  }

  static Future<String?> showRenameDay(
    BuildContext context,
    WorkoutDayEntry day,
  ) async {
    final nameController = TextEditingController(text: day.name);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Day'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Day name (e.g., Push, Pull)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.of(ctx).pop(true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed == true && nameController.text.trim().isNotEmpty) {
      return nameController.text.trim();
    }
    return null;
  }

  static Future<WorkoutExerciseEntry?> showEditExerciseParams(
    BuildContext context,
    WorkoutExerciseEntry we,
  ) async {
    final setsController = TextEditingController(
      text: we.targetSets.toString(),
    );
    final minRepsController = TextEditingController(
      text: we.targetMinReps.toString(),
    );
    final maxRepsController = TextEditingController(
      text: we.targetMaxReps.toString(),
    );
    final restController = TextEditingController(
      text: we.restSeconds.toString(),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Exercise Settings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: setsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Target Sets'),
              ),
              TextField(
                controller: minRepsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Min Reps'),
              ),
              TextField(
                controller: maxRepsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Max Reps'),
              ),
              TextField(
                controller: restController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Rest (seconds)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      return we.copyWith(
        targetSets: int.tryParse(setsController.text) ?? we.targetSets,
        targetMinReps: int.tryParse(minRepsController.text) ?? we.targetMinReps,
        targetMaxReps: int.tryParse(maxRepsController.text) ?? we.targetMaxReps,
        restSeconds: int.tryParse(restController.text) ?? we.restSeconds,
      );
    }
    return null;
  }
}
