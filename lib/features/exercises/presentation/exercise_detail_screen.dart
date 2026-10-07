import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/exercise_display_helper.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  final ExerciseEntry exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  static void show(BuildContext context, ExerciseEntry exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseDetailScreen(exercise: exercise),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final catalogAsync = ref.watch(exerciseCatalogProvider);
    final catalog = catalogAsync.value;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    final displayName = ExerciseDisplayHelper.getName(
      exercise,
      catalog: catalog,
      locale: locale,
    );
    final instructions = ExerciseDisplayHelper.getInstructions(
      exercise,
      catalog: catalog,
      locale: locale,
    );
    final tips = ExerciseDisplayHelper.getTips(
      exercise,
      catalog: catalog,
      locale: locale,
    );
    final secondaryMuscles = ExerciseDisplayHelper.getSecondaryMuscles(
      exercise,
      catalog: catalog,
    );

    final muscleText = ExerciseDisplayHelper.getLocalizedMuscle(
      exercise.muscleGroup,
      locale: locale,
    );
    final equipText = ExerciseDisplayHelper.getLocalizedEquipment(
      exercise.equipment,
      locale: locale,
    );
    final typeText = ExerciseDisplayHelper.getLocalizedExerciseType(
      exercise.exerciseType,
      locale: locale,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.45,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
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

              // Header bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Image placeholder (Images will be introduced in Phase 3)
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fitness_center_rounded,
                            size: 48,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            displayName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$muscleText • $equipText',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Metadata chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.fitness_center, size: 16),
                          label: Text(
                            l10n.exerciseDetailPrimaryMuscle(muscleText),
                          ),
                        ),
                        Chip(
                          avatar: const Icon(Icons.build_outlined, size: 16),
                          label: Text(equipText),
                        ),
                        Chip(
                          avatar: const Icon(Icons.repeat, size: 16),
                          label: Text(typeText),
                        ),
                        if (exercise.isCustom)
                          Chip(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            label: Text(
                              l10n.exerciseDetailCustomBadge,
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                    if (secondaryMuscles.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        l10n.exerciseDetailSecondaryMuscles,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: secondaryMuscles
                            .map(
                              (m) => Chip(
                                label: Text(
                                  ExerciseDisplayHelper.getLocalizedMuscle(
                                    m,
                                    locale: locale,
                                  ),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            )
                            .toList(),
                      ),
                    ],

                    // Description
                    if (exercise.description != null &&
                        exercise.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        l10n.exerciseDetailDescription,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        exercise.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(
                            alpha: 0.85,
                          ),
                          height: 1.4,
                        ),
                      ),
                    ],

                    // Instructions
                    if (instructions.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        l10n.exerciseDetailInstructions,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...instructions.indexed.map((item) {
                        final (idx, step) = item;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: theme.colorScheme.primary
                                    .withValues(alpha: 0.15),
                                child: Text(
                                  '${idx + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  step,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    // Tips
                    if (tips.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        l10n.exerciseDetailTips,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...tips.map((tip) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                size: 18,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
