import 'dart:convert';
import 'dart:ui' show Locale;

import '../../../data/database/app_database.dart';
import '../../../l10n/app_localizations.dart';
import 'exercise_catalog.dart';

class ExerciseDisplayHelper {
  static String getLocalizedMuscle(
    String muscle, {
    AppLocalizations? l10n,
    String? locale,
  }) {
    final effectiveL10n =
        l10n ?? lookupAppLocalizations(Locale(locale ?? 'en'));
    switch (muscle.trim().toLowerCase()) {
      case 'chest':
        return effectiveL10n.muscleChest;
      case 'back':
        return effectiveL10n.muscleBack;
      case 'shoulder':
      case 'shoulders':
        return effectiveL10n.muscleShoulders;
      case 'leg':
      case 'legs':
        return effectiveL10n.muscleLegs;
      case 'bicep':
      case 'biceps':
        return effectiveL10n.muscleBiceps;
      case 'tricep':
      case 'triceps':
        return effectiveL10n.muscleTriceps;
      case 'core':
      case 'abs':
      case 'abdominals':
        return effectiveL10n.muscleCore;
      case 'full body':
        return effectiveL10n.muscleFullBody;
      case 'cardio':
        return effectiveL10n.muscleCardio;
      case 'quads':
      case 'quadriceps':
        return effectiveL10n.muscleQuads;
      case 'hamstrings':
        return effectiveL10n.muscleHamstrings;
      case 'calves':
        return effectiveL10n.muscleCalves;
      case 'glutes':
        return effectiveL10n.muscleGlutes;
      case 'lats':
        return effectiveL10n.muscleLats;
      case 'traps':
        return effectiveL10n.muscleTraps;
      case 'forearms':
        return effectiveL10n.muscleForearms;
      default:
        return muscle;
    }
  }

  static String getLocalizedEquipment(
    String equipment, {
    AppLocalizations? l10n,
    String? locale,
  }) {
    final effectiveL10n =
        l10n ?? lookupAppLocalizations(Locale(locale ?? 'en'));
    switch (equipment.trim().toLowerCase()) {
      case 'barbell':
        return effectiveL10n.equipmentBarbell;
      case 'dumbbell':
        return effectiveL10n.equipmentDumbbell;
      case 'machine':
        return effectiveL10n.equipmentMachine;
      case 'cable':
        return effectiveL10n.equipmentCable;
      case 'bodyweight':
        return effectiveL10n.equipmentBodyweight;
      case 'kettlebell':
        return effectiveL10n.equipmentKettlebell;
      case 'other':
        return effectiveL10n.equipmentOther;
      default:
        return equipment;
    }
  }

  static String getLocalizedExerciseType(
    String type, {
    AppLocalizations? l10n,
    String? locale,
  }) {
    final effectiveL10n =
        l10n ?? lookupAppLocalizations(Locale(locale ?? 'en'));
    switch (type.trim().toLowerCase()) {
      case 'weight & reps':
        return effectiveL10n.typeWeightReps;
      case 'bodyweight reps':
        return effectiveL10n.typeBodyweightReps;
      case 'duration':
        return effectiveL10n.typeDuration;
      case 'cardio':
        return effectiveL10n.typeCardio;
      default:
        return type;
    }
  }

  /// Strips Vietnamese diacritics and converts to lowercase for accent-insensitive search.
  static String normalizeSearchText(String str) {
    var result = str.toLowerCase();
    const withDiacritics =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const withoutDiacritics =
        'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';

    for (var i = 0; i < withDiacritics.length; i++) {
      result = result.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }
    return result;
  }

  /// Resolves an exercise name (e.g. from history session or PR record) to localized name via catalog.
  static String resolveName(
    String exerciseName, {
    ExerciseCatalog? catalog,
    String locale = 'en',
  }) {
    if (catalog != null) {
      final match = catalog.findMatching(exerciseName);
      if (match != null) {
        return match.getName(locale: locale);
      }
    }
    return exerciseName;
  }

  /// Returns localized exercise name. For catalog items, resolves name from catalog if key exists.
  /// Otherwise, falls back to the DB `name`.
  static String getName(
    ExerciseEntry exercise, {
    ExerciseCatalog? catalog,
    String locale = 'en',
  }) {
    if (exercise.catalogKey != null && catalog != null) {
      final catItem = catalog.findByKey(exercise.catalogKey!);
      if (catItem != null) {
        return catItem.getName(locale: locale);
      }
    }
    return exercise.name;
  }

  /// Returns localized instructions.
  /// For custom exercises, returns the custom instructions stored in DB.
  /// For catalog items, reads from catalog.
  static List<String> getInstructions(
    ExerciseEntry exercise, {
    ExerciseCatalog? catalog,
    String locale = 'en',
  }) {
    if (exercise.isCustom) {
      if (exercise.instructions != null &&
          exercise.instructions!.trim().isNotEmpty) {
        return exercise.instructions!
            .split('\n')
            .where((s) => s.trim().isNotEmpty)
            .toList();
      }
      return const [];
    }

    if (exercise.catalogKey != null && catalog != null) {
      final catItem = catalog.findByKey(exercise.catalogKey!);
      if (catItem != null) {
        return catItem.getInstructions(locale: locale);
      }
    }
    return const [];
  }

  /// Returns localized tips.
  /// For custom exercises, returns tips stored in DB.
  /// For catalog items, reads from catalog.
  static List<String> getTips(
    ExerciseEntry exercise, {
    ExerciseCatalog? catalog,
    String locale = 'en',
  }) {
    if (exercise.isCustom) {
      if (exercise.tips != null && exercise.tips!.trim().isNotEmpty) {
        return exercise.tips!
            .split('\n')
            .where((s) => s.trim().isNotEmpty)
            .toList();
      }
      return const [];
    }

    if (exercise.catalogKey != null && catalog != null) {
      final catItem = catalog.findByKey(exercise.catalogKey!);
      if (catItem != null) {
        return catItem.getTips(locale: locale);
      }
    }
    return const [];
  }

  /// Returns list of secondary muscle groups.
  static List<String> getSecondaryMuscles(
    ExerciseEntry exercise, {
    ExerciseCatalog? catalog,
  }) {
    if (exercise.secondaryMuscles != null &&
        exercise.secondaryMuscles!.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(exercise.secondaryMuscles!);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } on FormatException {
        // Fallback for legacy comma-separated values (e.g. "Triceps, Shoulders")
        return exercise.secondaryMuscles!
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    if (exercise.catalogKey != null && catalog != null) {
      final catItem = catalog.findByKey(exercise.catalogKey!);
      if (catItem != null) {
        return catItem.secondaryMuscles;
      }
    }

    return const [];
  }

  /// Matches exercise against search query comparing:
  /// - English DB name
  /// - Vietnamese/localized catalog name
  /// - Aliases
  /// - Muscle group
  /// - Equipment
  /// Accent & case insensitive!
  static bool matchesQuery(
    ExerciseEntry exercise,
    String query, {
    ExerciseCatalog? catalog,
  }) {
    if (query.trim().isEmpty) return true;
    final normalizedQuery = normalizeSearchText(query.trim());

    // Compare name
    if (normalizeSearchText(exercise.name).contains(normalizedQuery)) {
      return true;
    }

    // Compare muscleGroup & equipment
    if (normalizeSearchText(exercise.muscleGroup).contains(normalizedQuery) ||
        normalizeSearchText(exercise.equipment).contains(normalizedQuery)) {
      return true;
    }

    // Compare catalog vi name & aliases
    if (exercise.catalogKey != null && catalog != null) {
      final item = catalog.findByKey(exercise.catalogKey!);
      if (item != null) {
        for (final val in item.names.values) {
          if (normalizeSearchText(val).contains(normalizedQuery)) {
            return true;
          }
        }
        for (final alias in item.aliases) {
          if (normalizeSearchText(alias).contains(normalizedQuery)) {
            return true;
          }
        }
      }
    }

    return false;
  }
}
