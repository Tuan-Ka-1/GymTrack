import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/database/app_database.dart';
import '../domain/exercise_catalog.dart';
import 'exercise_catalog_loader.dart';

class ExerciseCatalogSync {
  static const String keySyncedVersion = 'gymtrack_catalog_version';

  final AppDatabase _db;
  final SharedPreferences _prefs;

  ExerciseCatalogSync(this._db, this._prefs);

  /// Synchronizes exercise catalog from asset into the SQLite database.
  /// If [force] is true, executes even if syncedVersion >= catalog.version.
  Future<void> syncIfNeeded({
    ExerciseCatalog? catalog,
    bool force = false,
  }) async {
    final cat = catalog ?? await ExerciseCatalogLoader.loadFromAsset();
    final savedVersion = _prefs.getInt(keySyncedVersion) ?? 0;

    if (!force && savedVersion >= cat.version) {
      return;
    }

    await syncCatalog(cat);
    await _prefs.setInt(keySyncedVersion, cat.version);
  }

  /// Upserts all catalog exercises in a single transaction,
  /// backfills catalogKey for legacy seed exercises, and preserves custom exercises.
  Future<void> syncCatalog(ExerciseCatalog catalog) async {
    await _db.transaction(() async {
      // 1. Fetch all current exercises in DB
      final existing = await _db.getAllExercises(includeArchived: true);

      // Map existing by catalogKey
      final byCatalogKey = <String, ExerciseEntry>{};
      // Map non-custom exercises without catalogKey by lowercased name
      final legacyByName = <String, ExerciseEntry>{};

      for (final e in existing) {
        if (e.catalogKey != null) {
          byCatalogKey[e.catalogKey!] = e;
        } else if (!e.isCustom) {
          legacyByName[e.name.trim().toLowerCase()] = e;
        }
      }

      for (final item in catalog.exercises) {
        final enName = item.getName(locale: 'en');
        final secondaryJson = item.secondaryMuscles.isEmpty
            ? null
            : jsonEncode(item.secondaryMuscles);

        if (byCatalogKey.containsKey(item.key)) {
          // Entry already has this catalogKey -> update metadata without touching user-specific state
          final current = byCatalogKey[item.key]!;
          await (_db.update(
            _db.exercises,
          )..where((t) => t.id.equals(current.id))).write(
            ExercisesCompanion(
              name: Value(enName),
              muscleGroup: Value(item.muscleGroup),
              equipment: Value(item.equipment),
              exerciseType: Value(item.exerciseType),
              secondaryMuscles: Value(secondaryJson),
              updatedAt: Value(DateTime.now()),
            ),
          );
        } else {
          // Check if there is an existing legacy seed row matching name or any alias
          ExerciseEntry? matchedLegacy;

          // Check main name
          matchedLegacy = legacyByName[enName.trim().toLowerCase()];

          // Check aliases
          if (matchedLegacy == null) {
            for (final alias in item.aliases) {
              final found = legacyByName[alias.trim().toLowerCase()];
              if (found != null) {
                matchedLegacy = found;
                break;
              }
            }
          }

          if (matchedLegacy != null) {
            // Backfill catalogKey for this legacy row and update metadata, KEEPING id intact!
            await (_db.update(
              _db.exercises,
            )..where((t) => t.id.equals(matchedLegacy!.id))).write(
              ExercisesCompanion(
                name: Value(enName),
                catalogKey: Value(item.key),
                muscleGroup: Value(item.muscleGroup),
                equipment: Value(item.equipment),
                exerciseType: Value(item.exerciseType),
                secondaryMuscles: Value(secondaryJson),
                updatedAt: Value(DateTime.now()),
              ),
            );
            // Remove from legacyByName so another item doesn't claim it
            legacyByName.remove(matchedLegacy.name.trim().toLowerCase());
            for (final alias in item.aliases) {
              legacyByName.remove(alias.trim().toLowerCase());
            }
          } else {
            // Brand new catalog exercise -> insert
            await _db
                .into(_db.exercises)
                .insert(
                  ExercisesCompanion.insert(
                    name: enName,
                    muscleGroup: item.muscleGroup,
                    equipment: item.equipment,
                    exerciseType: Value(item.exerciseType),
                    catalogKey: Value(item.key),
                    secondaryMuscles: Value(secondaryJson),
                    isCustom: const Value(false),
                    isArchived: const Value(false),
                  ),
                );
          }
        }
      }
    });
  }
}
