import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/database/app_database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../exercises/domain/exercise_display_helper.dart';
import '../../../exercises/presentation/exercise_detail_screen.dart';

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
  String? _selectedEquipment;
  String? _selectedExerciseType;

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesStreamProvider);
    final catalogAsync = ref.watch(exerciseCatalogProvider);
    final catalog = catalogAsync.value;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

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
                      l10n.exercisePickerTitle,
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
                  decoration: InputDecoration(
                    hintText: l10n.exerciseLibrarySearchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),

              // Muscle group filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(l10n.exerciseLibraryAllMuscles),
                      selected: _selectedMuscle == null,
                      onSelected: (selected) {
                        setState(() => _selectedMuscle = null);
                      },
                    ),
                    const SizedBox(width: 8),
                    ...AppConstants.muscleGroups.map((muscle) {
                      final isSelected = _selectedMuscle == muscle;
                      final localizedMuscle =
                          ExerciseDisplayHelper.getLocalizedMuscle(
                            muscle,
                            locale: locale,
                          );
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(localizedMuscle),
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

              // Equipment & Type filter chips
              Builder(
                builder: (context) {
                  final exercises = exercisesAsync.value ?? [];
                  final availableTypes = exercises
                      .map((e) => e.exerciseType)
                      .toSet()
                      .toList();
                  final showTypeFilter = availableTypes.length > 1;

                  final equipmentLabel = _selectedEquipment != null
                      ? ExerciseDisplayHelper.getLocalizedEquipment(
                          _selectedEquipment!,
                          locale: locale,
                        )
                      : l10n.exerciseLibraryEquipmentFilter;

                  final typeLabel = _selectedExerciseType != null
                      ? ExerciseDisplayHelper.getLocalizedExerciseType(
                          _selectedExerciseType!,
                          locale: locale,
                        )
                      : l10n.exerciseLibraryTypeFilter;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        FilterChip(
                          avatar: const Icon(Icons.build_outlined, size: 14),
                          label: Text(equipmentLabel),
                          selected: _selectedEquipment != null,
                          onSelected: (_) {
                            if (_selectedEquipment != null) {
                              setState(() => _selectedEquipment = null);
                            } else {
                              _showEquipmentPicker(context);
                            }
                          },
                        ),
                        if (showTypeFilter) ...[
                          const SizedBox(width: 8),
                          FilterChip(
                            avatar: const Icon(Icons.repeat, size: 14),
                            label: Text(typeLabel),
                            selected: _selectedExerciseType != null,
                            onSelected: (_) {
                              if (_selectedExerciseType != null) {
                                setState(() => _selectedExerciseType = null);
                              } else {
                                _showTypePicker(context, availableTypes);
                              }
                            },
                          ),
                        ],
                        if (_selectedEquipment != null ||
                            (showTypeFilter &&
                                _selectedExerciseType != null)) ...[
                          const SizedBox(width: 8),
                          ActionChip(
                            avatar: const Icon(Icons.close, size: 14),
                            label: Text(l10n.commonClearFilters),
                            onPressed: () => setState(() {
                              _selectedEquipment = null;
                              _selectedExerciseType = null;
                            }),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),

              const Divider(height: 16),

              // Exercise list (Lazy ListView.builder)
              Expanded(
                child: exercisesAsync.when(
                  data: (exercises) {
                    final filtered = exercises.where((e) {
                      final matchesSearch = ExerciseDisplayHelper.matchesQuery(
                        e,
                        _searchQuery,
                        catalog: catalog,
                      );
                      final matchesMuscle =
                          _selectedMuscle == null ||
                          e.muscleGroup == _selectedMuscle;
                      final matchesEquipment =
                          _selectedEquipment == null ||
                          e.equipment == _selectedEquipment;
                      final matchesType =
                          _selectedExerciseType == null ||
                          e.exerciseType == _selectedExerciseType;
                      return matchesSearch &&
                          matchesMuscle &&
                          matchesEquipment &&
                          matchesType &&
                          !e.isArchived;
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(l10n.exerciseLibraryNoExercisesFound),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final ex = filtered[index];
                        final displayName = ExerciseDisplayHelper.getName(
                          ex,
                          catalog: catalog,
                          locale: locale,
                        );

                        final muscleText =
                            ExerciseDisplayHelper.getLocalizedMuscle(
                              ex.muscleGroup,
                              locale: locale,
                            );
                        final equipText =
                            ExerciseDisplayHelper.getLocalizedEquipment(
                              ex.equipment,
                              locale: locale,
                            );
                        final typeText =
                            ExerciseDisplayHelper.getLocalizedExerciseType(
                              ex.exerciseType,
                              locale: locale,
                            );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Icon(
                                Icons.fitness_center,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
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
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      l10n.exerciseLibraryCustomBadge,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                '$muscleText • $equipText • $typeText',
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.info_outline,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                  tooltip: l10n.exerciseDetailInstructions,
                                  onPressed: () =>
                                      ExerciseDetailScreen.show(context, ex),
                                ),
                                FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                  ),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: Text(l10n.commonAdd.toUpperCase()),
                                  onPressed: () =>
                                      Navigator.of(context).pop(ex),
                                ),
                              ],
                            ),
                            onTap: () => Navigator.of(context).pop(ex),
                          ),
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

  void _showEquipmentPicker(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: AppConstants.equipmentTypes.map((eq) {
            return ListTile(
              title: Text(
                ExerciseDisplayHelper.getLocalizedEquipment(eq, locale: locale),
              ),
              trailing: _selectedEquipment == eq
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                setState(() => _selectedEquipment = eq);
                Navigator.of(ctx).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTypePicker(BuildContext context, [List<String>? availableTypes]) {
    final locale = Localizations.localeOf(context).languageCode;
    final types =
        availableTypes ??
        ['Weight & Reps', 'Bodyweight Reps', 'Duration', 'Cardio'];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: types.map((t) {
            return ListTile(
              title: Text(
                ExerciseDisplayHelper.getLocalizedExerciseType(
                  t,
                  locale: locale,
                ),
              ),
              trailing: _selectedExerciseType == t
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                setState(() => _selectedExerciseType = t);
                Navigator.of(ctx).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
