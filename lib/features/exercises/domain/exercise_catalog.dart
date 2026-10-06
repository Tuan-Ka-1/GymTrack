class CatalogExercise {
  final String key;
  final List<String> aliases;
  final String muscleGroup;
  final List<String> secondaryMuscles;
  final String equipment;
  final String exerciseType;
  final Map<String, String> names;
  final Map<String, List<String>> instructions;
  final Map<String, List<String>> tips;
  final List<String> images;

  const CatalogExercise({
    required this.key,
    this.aliases = const [],
    required this.muscleGroup,
    this.secondaryMuscles = const [],
    required this.equipment,
    this.exerciseType = 'Weight & Reps',
    required this.names,
    this.instructions = const {},
    this.tips = const {},
    this.images = const [],
  });

  factory CatalogExercise.fromJson(Map<String, dynamic> json) {
    return CatalogExercise(
      key: json['key'] as String,
      aliases:
          (json['aliases'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      muscleGroup: json['muscleGroup'] as String,
      secondaryMuscles:
          (json['secondaryMuscles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      equipment: json['equipment'] as String,
      exerciseType: json['exerciseType'] as String? ?? 'Weight & Reps',
      names:
          (json['names'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          const {},
      instructions:
          (json['instructions'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(
              k,
              (v as List<dynamic>).map((e) => e.toString()).toList(),
            ),
          ) ??
          const {},
      tips:
          (json['tips'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(
              k,
              (v as List<dynamic>).map((e) => e.toString()).toList(),
            ),
          ) ??
          const {},
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  String getName({String locale = 'en'}) {
    return names[locale] ?? names['en'] ?? key;
  }

  List<String> getInstructions({String locale = 'en'}) {
    return instructions[locale] ?? instructions['en'] ?? const [];
  }

  List<String> getTips({String locale = 'en'}) {
    return tips[locale] ?? tips['en'] ?? const [];
  }
}

class ExerciseCatalog {
  final int version;
  final List<CatalogExercise> exercises;
  final Map<String, CatalogExercise> _byKey;

  ExerciseCatalog({required this.version, required this.exercises})
    : _byKey = {for (final e in exercises) e.key: e};

  factory ExerciseCatalog.fromJson(Map<String, dynamic> json) {
    final version = json['catalogVersion'] as int? ?? 1;
    final list =
        (json['exercises'] as List<dynamic>?)
            ?.map((e) => CatalogExercise.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];
    return ExerciseCatalog(version: version, exercises: list);
  }

  CatalogExercise? findByKey(String key) => _byKey[key];

  CatalogExercise? findMatching(String name) {
    final cleanName = name.trim().toLowerCase();
    for (final ex in exercises) {
      if (ex.getName(locale: 'en').trim().toLowerCase() == cleanName) {
        return ex;
      }
      for (final alias in ex.aliases) {
        if (alias.trim().toLowerCase() == cleanName) {
          return ex;
        }
      }
    }
    return null;
  }
}
