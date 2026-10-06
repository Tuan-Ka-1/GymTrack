import 'dart:convert';

import '../../../data/database/app_database.dart';
import 'exercise_catalog.dart';

class ExerciseDisplayHelper {
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
      } catch (_) {
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
