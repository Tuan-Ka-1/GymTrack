import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/exercise_catalog.dart';

class ExerciseCatalogLoader {
  static const String assetPath = 'assets/data/exercise_catalog.json';
  static ExerciseCatalog? _cachedCatalog;

  /// Loads catalog from Flutter asset bundle (cached in memory)
  static Future<ExerciseCatalog> loadFromAsset([AssetBundle? bundle]) async {
    if (_cachedCatalog != null) return _cachedCatalog!;
    final assetBundle = bundle ?? rootBundle;
    final jsonStr = await assetBundle.loadString(assetPath);
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    _cachedCatalog = ExerciseCatalog.fromJson(map);
    return _cachedCatalog!;
  }

  /// Parses catalog directly from raw JSON string (useful for testing)
  static ExerciseCatalog loadFromString(String jsonStr) {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return ExerciseCatalog.fromJson(map);
  }

  static void setCache(ExerciseCatalog catalog) {
    _cachedCatalog = catalog;
  }

  static void clearCache() {
    _cachedCatalog = null;
  }
}
