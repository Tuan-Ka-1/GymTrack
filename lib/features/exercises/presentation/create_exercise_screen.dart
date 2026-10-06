import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';

class CreateExerciseScreen extends ConsumerStatefulWidget {
  const CreateExerciseScreen({super.key});

  @override
  ConsumerState<CreateExerciseScreen> createState() =>
      _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends ConsumerState<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedMuscle = AppConstants.muscleGroups.first;
  String _selectedEquipment = AppConstants.equipmentTypes.first;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveExercise() async {
    if (_formKey.currentState?.validate() ?? false) {
      final repo = ref.read(exerciseRepositoryProvider);
      await repo.createExercise(
        name: _nameController.text.trim(),
        muscleGroup: _selectedMuscle,
        equipment: _selectedEquipment,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
      );
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Custom Exercise')),
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
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description / Instructions (optional)',
                hintText: 'Setup cues, form notes, range of motion...',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saveExercise,
                child: const Text('SAVE EXERCISE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
