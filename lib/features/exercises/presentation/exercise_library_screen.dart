import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/repositories/exercise_repository.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  String _searchQuery = '';
  String? _selectedMuscle;
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesStreamProvider);
    final repo = ref.watch(exerciseRepositoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Custom Exercise',
            onPressed: () => context.push('/create-exercise'),
          ),
          IconButton(
            icon: Icon(_showArchived ? Icons.archive : Icons.archive_outlined),
            tooltip: _showArchived ? 'Hide Archived' : 'Show Archived',
            onPressed: () => setState(() => _showArchived = !_showArchived),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by exercise name...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) =>
                  setState(() => _searchQuery = val.toLowerCase().trim()),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedMuscle == null,
                  onSelected: (_) => setState(() => _selectedMuscle = null),
                ),
                const SizedBox(width: 8),
                ...AppConstants.muscleGroups.map((muscle) {
                  final isSelected = _selectedMuscle == muscle;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(muscle),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(
                          () => _selectedMuscle = selected ? muscle : null,
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 16),
          Expanded(
            child: _showArchived
                ? _buildArchivedList(repo, theme)
                : _buildActiveList(exercisesAsync, repo, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveList(
    AsyncValue<List<ExerciseEntry>> exercisesAsync,
    ExerciseRepository repo,
    ThemeData theme,
  ) {
    return exercisesAsync.when(
      data: (exercises) {
        final filtered = exercises.where((e) {
          final matchesSearch =
              _searchQuery.isEmpty ||
              e.name.toLowerCase().contains(_searchQuery);
          final matchesMuscle =
              _selectedMuscle == null || e.muscleGroup == _selectedMuscle;
          return matchesSearch && matchesMuscle;
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No exercises found'));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final ex = filtered[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      ex.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (ex.isCustom)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'CUSTOM',
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Text('${ex.muscleGroup} • ${ex.equipment}'),
              trailing: ex.isCustom
                  ? IconButton(
                      icon: const Icon(
                        Icons.archive_outlined,
                        size: 20,
                        color: Colors.grey,
                      ),
                      onPressed: () async {
                        final confirmed = await ConfirmDialog.show(
                          context,
                          title: 'Archive Exercise?',
                          message:
                              'This will hide "${ex.name}" from the library and pickers.\nYour workout history for this exercise will be preserved.',
                          confirmText: 'Archive',
                          isDestructive: true,
                        );
                        if (confirmed) {
                          await repo.archiveExercise(ex.id);
                        }
                      },
                    )
                  : null,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildArchivedList(ExerciseRepository repo, ThemeData theme) {
    return FutureBuilder<List<ExerciseEntry>>(
      future: repo.getAllExercises(includeArchived: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final allExercises = snapshot.data ?? [];
        final archived = allExercises.where((e) => e.isArchived).toList();
        if (archived.isEmpty) {
          return const Center(child: Text('No archived exercises'));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: archived.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final ex = archived[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      ex.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  if (ex.isCustom)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ARCHIVED',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Text(
                '${ex.muscleGroup} • ${ex.equipment}',
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.unarchive_outlined,
                  size: 20,
                  color: Colors.green,
                ),
                onPressed: () async {
                  final confirmed = await ConfirmDialog.show(
                    context,
                    title: 'Restore Exercise?',
                    message: 'Restore "${ex.name}" to the library and pickers?',
                    isDestructive: false,
                  );
                  if (confirmed) {
                    await repo.unarchiveExercise(ex.id);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
