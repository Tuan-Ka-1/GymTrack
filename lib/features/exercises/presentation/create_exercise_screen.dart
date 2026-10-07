import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/exercise_display_helper.dart';

class CreateExerciseScreen extends ConsumerStatefulWidget {
  final ExerciseEntry? exerciseToEdit;

  const CreateExerciseScreen({super.key, this.exerciseToEdit});

  @override
  ConsumerState<CreateExerciseScreen> createState() =>
      _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends ConsumerState<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _instructionsController;
  late final TextEditingController _tipsController;
  late String _selectedMuscle;
  late String _selectedEquipment;

  @override
  void initState() {
    super.initState();
    final ex = widget.exerciseToEdit;
    _nameController = TextEditingController(text: ex?.name ?? '');
    _descController = TextEditingController(text: ex?.description ?? '');
    _instructionsController = TextEditingController(
      text: ex?.instructions ?? '',
    );
    _tipsController = TextEditingController(text: ex?.tips ?? '');

    _selectedMuscle =
        (ex != null && AppConstants.muscleGroups.contains(ex.muscleGroup))
        ? ex.muscleGroup
        : AppConstants.muscleGroups.first;

    _selectedEquipment =
        (ex != null && AppConstants.equipmentTypes.contains(ex.equipment))
        ? ex.equipment
        : AppConstants.equipmentTypes.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _instructionsController.dispose();
    _tipsController.dispose();
    super.dispose();
  }

  Future<void> _saveExercise() async {
    if (_formKey.currentState?.validate() ?? false) {
      final repo = ref.read(exerciseRepositoryProvider);
      final desc = _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim();
      final instructions = _instructionsController.text.trim().isEmpty
          ? null
          : _instructionsController.text.trim();
      final tips = _tipsController.text.trim().isEmpty
          ? null
          : _tipsController.text.trim();

      if (widget.exerciseToEdit != null) {
        // Edit existing exercise
        final updated = widget.exerciseToEdit!.copyWith(
          name: _nameController.text.trim(),
          muscleGroup: _selectedMuscle,
          equipment: _selectedEquipment,
          description: Value(desc),
          instructions: Value(instructions),
          tips: Value(tips),
          updatedAt: DateTime.now(),
        );
        await repo.updateExercise(updated);
      } else {
        // Create new custom exercise
        await repo.createExercise(
          name: _nameController.text.trim(),
          muscleGroup: _selectedMuscle,
          equipment: _selectedEquipment,
          description: desc,
          instructions: instructions,
          tips: tips,
        );
      }

      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.exerciseToEdit != null;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? l10n.createExerciseTitleEdit
              : l10n.createExerciseTitleNew,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.createExerciseNameLabel,
                hintText: l10n.createExerciseNameHint,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return l10n.createExerciseNameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMuscle,
              decoration: InputDecoration(
                labelText: l10n.createExerciseMuscleLabel,
              ),
              items: AppConstants.muscleGroups
                  .map(
                    (m) => DropdownMenuItem(
                      value: m,
                      child: Text(
                        ExerciseDisplayHelper.getLocalizedMuscle(
                          m,
                          locale: locale,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedMuscle = val);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedEquipment,
              decoration: InputDecoration(
                labelText: l10n.createExerciseEquipmentLabel,
              ),
              items: AppConstants.equipmentTypes
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        ExerciseDisplayHelper.getLocalizedEquipment(
                          e,
                          locale: locale,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedEquipment = val);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.createExerciseDescLabel,
                hintText: l10n.createExerciseDescHint,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instructionsController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.createExerciseInstructionsLabel,
                hintText: l10n.createExerciseInstructionsHint,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tipsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.createExerciseTipsLabel,
                hintText: l10n.createExerciseTipsHint,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saveExercise,
                child: Text(
                  isEditing
                      ? l10n.createExerciseUpdateButton
                      : l10n.createExerciseSaveButton,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
