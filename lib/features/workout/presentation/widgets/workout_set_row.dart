import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/utils/calculator.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/database/app_database.dart';
import '../../../../domain/repositories/workout_repository.dart';

class WorkoutSetRow extends ConsumerStatefulWidget {
  final WorkoutSetEntry setEntry;
  final String weightUnit;
  final WorkoutRepository repo;
  final String exerciseName;
  final int? restSeconds;

  const WorkoutSetRow({
    super.key,
    required this.setEntry,
    required this.weightUnit,
    required this.repo,
    required this.exerciseName,
    this.restSeconds,
  });

  @override
  ConsumerState<WorkoutSetRow> createState() => _WorkoutSetRowState();
}

class _WorkoutSetRowState extends ConsumerState<WorkoutSetRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    final displayWeight = widget.setEntry.weight > 0
        ? (widget.weightUnit == 'lb'
              ? Calculator.kgToLb(widget.setEntry.weight)
              : widget.setEntry.weight)
        : 0.0;
    _weightController = TextEditingController(
      text: displayWeight > 0
          ? (displayWeight % 1 == 0
                ? displayWeight.toInt().toString()
                : double.parse(displayWeight.toStringAsFixed(1)).toString())
          : '',
    );
    _repsController = TextEditingController(
      text: widget.setEntry.reps > 0 ? widget.setEntry.reps.toString() : '',
    );
  }

  @override
  void didUpdateWidget(covariant WorkoutSetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.setEntry.weight != widget.setEntry.weight &&
        _weightController.text.isEmpty) {
      final displayWeight = widget.setEntry.weight > 0
          ? (widget.weightUnit == 'lb'
                ? Calculator.kgToLb(widget.setEntry.weight)
                : widget.setEntry.weight)
          : 0.0;
      _weightController.text = displayWeight > 0
          ? (displayWeight % 1 == 0
                ? displayWeight.toInt().toString()
                : double.parse(displayWeight.toStringAsFixed(1)).toString())
          : '';
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _saveValues({bool? completed}) {
    final weight =
        Formatters.parseWeight(
          _weightController.text,
          unit: widget.weightUnit,
        ) ??
        0.0;
    final reps = Formatters.parseInt(_repsController.text) ?? 0;
    final isDone = completed ?? widget.setEntry.completed;

    widget.repo.updateSet(
      widget.setEntry.copyWith(weight: weight, reps: reps, completed: isDone),
    );

    // If marked completed, start rest timer automatically (Section 12)
    if (completed == true) {
      final restSecs = widget.restSeconds ?? 90;
      ref
          .read(restTimerProvider.notifier)
          .startTimer(seconds: restSecs, exerciseName: widget.exerciseName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.setEntry.completed;
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(widget.setEntry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red.withValues(alpha: 0.8),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        widget.repo.deleteSet(widget.setEntry.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          color: isCompleted
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(
                '${widget.setEntry.setNumber}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCompleted
                      ? theme.colorScheme.primary
                      : Colors.white70,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 44,
                child: TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    hintText: '0',
                    fillColor: isCompleted
                        ? theme.colorScheme.primary.withValues(alpha: 0.05)
                        : null,
                  ),
                  onChanged: (_) => _saveValues(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 44,
                child: TextField(
                  controller: _repsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    hintText: '0',
                    fillColor: isCompleted
                        ? theme.colorScheme.primary.withValues(alpha: 0.05)
                        : null,
                  ),
                  onChanged: (_) => _saveValues(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 48,
              height: 44,
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: isCompleted
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  foregroundColor: isCompleted ? Colors.black : Colors.white60,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.check, size: 20),
                onPressed: () {
                  _saveValues(completed: !isCompleted);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
