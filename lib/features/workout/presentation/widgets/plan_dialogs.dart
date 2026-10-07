import 'package:flutter/material.dart';

import '../../../../data/database/app_database.dart';
import '../../../../l10n/app_localizations.dart';

abstract class PlanDialogs {
  static Future<String?> showAddWorkoutDay(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dialogAddWorkoutDayTitle),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.dialogWorkoutDayHint),
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
            child: Text(l10n.commonAdd),
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
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: plan.name);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dialogRenamePlanTitle),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.dialogRenamePlanHint),
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
            child: Text(l10n.commonSave),
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
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: day.name);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dialogRenameDayTitle),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.dialogRenameDayHint),
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
            child: Text(l10n.commonSave),
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
    final l10n = AppLocalizations.of(context)!;
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
        title: Text(l10n.dialogEditExerciseParamsTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: setsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.dialogTargetSetsLabel,
                ),
              ),
              TextField(
                controller: minRepsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.dialogMinRepsLabel),
              ),
              TextField(
                controller: maxRepsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.dialogMaxRepsLabel),
              ),
              TextField(
                controller: restController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.dialogRestSecondsLabel,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonSave),
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
