import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../data/database/app_database.dart';

class ExercisePickerDialog extends ConsumerStatefulWidget {
  const ExercisePickerDialog({super.key});

  static Future<ExerciseEntry?> show(BuildContext context) {
    return showModalBottomSheet<ExerciseEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ExercisePickerDialog(),
    );
  }

  @override
  ConsumerState<ExercisePickerDialog> createState() =>
      _ExercisePickerDialogState();
}

class _ExercisePickerDialogState extends ConsumerState<ExercisePickerDialog> {
  String _searchQuery = '';
  String? _selectedMuscle;

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesStreamProvider);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      'Select Exercise',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Search input
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) =>
                      setState(() => _searchQuery = val.toLowerCase().trim()),
                ),
              ),
              // Muscle group filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedMuscle == null,
                      onSelected: (selected) {
                        setState(() => _selectedMuscle = null);
                      },
                    ),
                    const SizedBox(width: 8),
                    ...[
                      'Chest',
                      'Back',
                      'Shoulders',
                      'Legs',
                      'Biceps',
                      'Triceps',
                    ].map((muscle) {
                      final isSelected = _selectedMuscle == muscle;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(muscle),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedMuscle = selected ? muscle : null;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Exercise list
              Expanded(
                child: exercisesAsync.when(
                  data: (exercises) {
                    final filtered = exercises.where((e) {
                      final matchesSearch =
                          _searchQuery.isEmpty ||
                          e.name.toLowerCase().contains(_searchQuery);
                      final matchesMuscle =
                          _selectedMuscle == null ||
                          e.muscleGroup == _selectedMuscle;
                      return matchesSearch && matchesMuscle;
                    }).toList();

                    if (filtered.isEmpty) {
                      return const Center(child: Text('No exercises found'));
                    }

                    return ListView.separated(
                      controller: scrollController,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        final ex = filtered[index];
                        return ListTile(
                          title: Text(
                            ex.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${ex.muscleGroup} • ${ex.equipment}'),
                          trailing: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.green,
                          ),
                          onTap: () => Navigator.of(context).pop(ex),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
