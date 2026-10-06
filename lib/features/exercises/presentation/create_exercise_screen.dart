import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Exercise' : 'New Custom Exercise'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Exercise Name *',
                hintText: 'e.g. Bulgarian Split Squat',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter exercise name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMuscle,
              decoration: const InputDecoration(labelText: 'Muscle Group *'),
              items: AppConstants.muscleGroups
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedMuscle = val);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedEquipment,
              decoration: const InputDecoration(labelText: 'Equipment *'),
              items: AppConstants.equipmentTypes
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedEquipment = val);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Short summary of the exercise...',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instructionsController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Instructions (optional)',
                hintText:
                    'Step 1: Set up...\nStep 2: Lower...\nStep 3: Press...',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tipsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Form Tips & Cues (optional)',
                hintText: 'Cues, common mistakes to avoid...',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saveExercise,
                child: Text(isEditing ? 'UPDATE EXERCISE' : 'SAVE EXERCISE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
