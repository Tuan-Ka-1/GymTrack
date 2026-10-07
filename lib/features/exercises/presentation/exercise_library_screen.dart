import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/repositories/exercise_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/exercise_catalog.dart';
import '../domain/exercise_display_helper.dart';
import 'exercise_detail_screen.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  String _searchQuery = '';
  String? _selectedMuscle;
  String? _selectedEquipment;
  String? _selectedExerciseType;
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesStreamProvider);
    final catalogAsync = ref.watch(exerciseCatalogProvider);
    final catalog = catalogAsync.value;
    final repo = ref.watch(exerciseRepositoryProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exerciseLibraryTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.exerciseLibraryAddTooltip,
            onPressed: () => context.push('/create-exercise'),
          ),
          IconButton(
            icon: Icon(_showArchived ? Icons.archive : Icons.archive_outlined),
            tooltip: _showArchived
                ? l10n.exerciseLibraryHideArchivedTooltip
                : l10n.exerciseLibraryShowArchivedTooltip,
            onPressed: () => setState(() => _showArchived = !_showArchived),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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

          // Horizontal Filter Chips: Muscle Group
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                FilterChip(
                  label: Text(l10n.exerciseLibraryAllMuscles),
                  selected: _selectedMuscle == null,
                  onSelected: (_) => setState(() => _selectedMuscle = null),
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

          // Horizontal Filter Chips: Equipment & Type
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
                        (showTypeFilter && _selectedExerciseType != null)) ...[
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
          Expanded(
            child: _showArchived
                ? _buildArchivedList(repo, theme, catalog, locale, l10n)
                : _buildActiveList(
                    exercisesAsync,
                    repo,
                    theme,
                    catalog,
                    locale,
                    l10n,
                  ),
          ),
        ],
      ),
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

  Widget _buildActiveList(
    AsyncValue<List<ExerciseEntry>> exercisesAsync,
    ExerciseRepository repo,
    ThemeData theme,
    ExerciseCatalog? catalog,
    String locale,
    AppLocalizations l10n,
  ) {
    return exercisesAsync.when(
      data: (exercises) {
        final filtered = exercises.where((e) {
          final matchesSearch = ExerciseDisplayHelper.matchesQuery(
            e,
            _searchQuery,
            catalog: catalog,
          );
          final matchesMuscle =
              _selectedMuscle == null || e.muscleGroup == _selectedMuscle;
          final matchesEquipment =
              _selectedEquipment == null || e.equipment == _selectedEquipment;
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
          return Center(child: Text(l10n.exerciseLibraryNoExercisesFound));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final ex = filtered[index];
            final displayName = ExerciseDisplayHelper.getName(
              ex,
              catalog: catalog,
              locale: locale,
            );

            final muscleText = ExerciseDisplayHelper.getLocalizedMuscle(
              ex.muscleGroup,
              locale: locale,
            );
            final equipText = ExerciseDisplayHelper.getLocalizedEquipment(
              ex.equipment,
              locale: locale,
            );
            final typeText = ExerciseDisplayHelper.getLocalizedExerciseType(
              ex.exerciseType,
              locale: locale,
            );

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
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
                  child: Text('$muscleText • $equipText • $typeText'),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (ex.isCustom) ...[
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: l10n.exerciseLibraryEditTooltip,
                        onPressed: () =>
                            context.push('/create-exercise', extra: ex),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.archive_outlined,
                          size: 20,
                          color: Colors.grey,
                        ),
                        tooltip: l10n.exerciseLibraryArchiveTooltip,
                        onPressed: () async {
                          final confirmed = await ConfirmDialog.show(
                            context,
                            title: l10n.exerciseLibraryArchiveDialogTitle,
                            message: l10n.exerciseLibraryArchiveDialogMessage(
                              ex.name,
                            ),
                            confirmText: l10n.commonArchive,
                            isDestructive: true,
                          );
                          if (confirmed) {
                            await repo.archiveExercise(ex.id);
                          }
                        },
                      ),
                    ] else
                      const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                onTap: () => ExerciseDetailScreen.show(context, ex),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.commonError(e.toString()))),
    );
  }

  Widget _buildArchivedList(
    ExerciseRepository repo,
    ThemeData theme,
    ExerciseCatalog? catalog,
    String locale,
    AppLocalizations l10n,
  ) {
    return FutureBuilder<List<ExerciseEntry>>(
      future: repo.getAllExercises(includeArchived: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final allExercises = snapshot.data ?? [];
        final archived = allExercises.where((e) => e.isArchived).toList();
        if (archived.isEmpty) {
          return Center(child: Text(l10n.exerciseLibraryNoArchived));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: archived.length,
          itemBuilder: (context, index) {
            final ex = archived[index];
            final displayName = ExerciseDisplayHelper.getName(
              ex,
              catalog: catalog,
              locale: locale,
            );
            final muscleText = ExerciseDisplayHelper.getLocalizedMuscle(
              ex.muscleGroup,
              locale: locale,
            );
            final equipText = ExerciseDisplayHelper.getLocalizedEquipment(
              ex.equipment,
              locale: locale,
            );

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        l10n.exerciseLibraryArchivedBadge,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  '$muscleText • $equipText',
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.unarchive_outlined,
                    size: 20,
                    color: Colors.green,
                  ),
                  tooltip: l10n.exerciseLibraryRestoreTooltip,
                  onPressed: () async {
                    final confirmed = await ConfirmDialog.show(
                      context,
                      title: l10n.exerciseLibraryRestoreDialogTitle,
                      message: l10n.exerciseLibraryRestoreDialogMessage(
                        ex.name,
                      ),
                      confirmText: l10n.commonRestore,
                      isDestructive: false,
                    );
                    if (confirmed) {
                      await repo.unarchiveExercise(ex.id);
                    }
                  },
                ),
                onTap: () => ExerciseDetailScreen.show(context, ex),
              ),
            );
          },
        );
      },
    );
  }
}
