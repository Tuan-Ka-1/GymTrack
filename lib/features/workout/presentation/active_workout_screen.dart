import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../data/database/app_database.dart';
import '../../../l10n/app_localizations.dart';
import 'widgets/active_exercise_card.dart';
import 'widgets/exercise_picker_dialog.dart';
import 'widgets/rest_timer_banner.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final int sessionId;

  const ActiveWorkoutScreen({super.key, required this.sessionId});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startElapsedTimer();
  }

  void _startElapsedTimer() {
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addExercise() async {
    final selected = await ExercisePickerDialog.show(context);
    if (selected != null) {
      final repo = ref.read(workoutRepositoryProvider);
      final autoFill = ref.read(autoFillPreviousProvider);
      await repo.addExerciseToSession(
        widget.sessionId,
        selected.id,
        selected.name,
        autoFillPrevious: autoFill,
      );
      setState(() {});
    }
  }

  Future<void> _finishWorkout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.activeWorkoutFinishDialogTitle,
      message: l10n.activeWorkoutFinishDialogMessage,
      confirmText: l10n.activeWorkoutFinishDialogConfirm,
    );

    if (confirmed) {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.finishWorkoutSession(
        widget.sessionId,
        notes: _notesController.text.trim(),
      );
      if (mounted) {
        context.pushReplacement('/workout-summary/${widget.sessionId}');
      }
    }
  }

  Future<void> _cancelWorkout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.activeWorkoutDiscardDialogTitle,
      message: l10n.activeWorkoutDiscardDialogMessage,
      confirmText: l10n.activeWorkoutDiscardDialogConfirm,
      isDestructive: true,
    );

    if (confirmed) {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.deleteWorkoutSession(widget.sessionId);
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final repo = ref.watch(workoutRepositoryProvider);
    final weightUnit = ref.watch(weightUnitProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _cancelWorkout();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.activeWorkoutTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                Formatters.formatTimer(_elapsedSeconds),
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _cancelWorkout,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: _finishWorkout,
                icon: const Icon(Icons.check, size: 18),
                label: Text(
                  l10n.activeWorkoutFinishButton,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const RestTimerBanner(),
        body: StreamBuilder<List<ExerciseSessionEntry>>(
          stream: repo.watchExerciseSessionsForWorkout(widget.sessionId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final exerciseSessions = snapshot.data ?? [];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...exerciseSessions.map(
                  (exSession) => ActiveExerciseCard(
                    key: ValueKey(exSession.id),
                    exSession: exSession,
                    weightUnit: weightUnit,
                    db: db,
                    repo: repo,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(
                    l10n.activeWorkoutAddExercise,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: _addExercise,
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.activeWorkoutNotesTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _notesController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: l10n.activeWorkoutNotesHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            );
          },
        ),
      ),
    );
  }
}
