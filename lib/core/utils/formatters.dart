import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import 'calculator.dart';

enum InputValidationError { required, invalidNumber, negative, tooLarge }

class Formatters {
  static String formatDate(DateTime date, {String? locale}) =>
      DateFormat('dd MMM yyyy', locale).format(date);
  static String formatShortDate(DateTime date, {String? locale}) =>
      DateFormat('dd/MM', locale).format(date);
  static String formatTime(DateTime date, {String? locale}) =>
      DateFormat('HH:mm', locale).format(date);
  static String formatDayOfWeek(DateTime date, {String? locale}) =>
      DateFormat('EEEE', locale).format(date);

  /// Format seconds into mm:ss (e.g. 01:30)
  static String formatTimer(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    return '$mStr:$sStr';
  }

  /// Format duration for completed workout: e.g. 58 min, 1h 15m
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  /// Format weight from kg to display unit (kg or lb)
  /// DB always stores kg. This converts for display.
  static String formatWeight(double weightKg, {String unit = 'kg'}) {
    double displayWeight;
    if (unit == 'lb') {
      displayWeight = Calculator.kgToLb(weightKg);
    } else {
      displayWeight = weightKg;
    }
    // For lbs, show 1 decimal place; for kg, show integer if whole number
    final formatted = unit == 'lb'
        ? displayWeight.toStringAsFixed(1)
        : (displayWeight % 1 == 0
              ? displayWeight.toInt().toString()
              : displayWeight.toStringAsFixed(1));
    return '$formatted $unit';
  }

  /// Parse weight input in display unit and convert to kg for storage
  /// Returns weight in kg
  static double? parseWeight(String text, {String unit = 'kg'}) {
    final value = parseDouble(text);
    if (value == null) return null;
    if (unit == 'lb') {
      return Calculator.lbToKg(value);
    }
    return value;
  }

  /// Format volume from kg*reps to display unit
  /// Volume is weight * reps. If displaying in lbs, convert the weight component.
  static String formatVolume(double volumeKgReps, {String unit = 'kg'}) {
    double displayVolume;
    if (unit == 'lb') {
      displayVolume = volumeKgReps * Calculator.kgToLb(1.0); // Convert kg to lb
    } else {
      displayVolume = volumeKgReps;
    }
    final formatted = displayVolume % 1 == 0
        ? displayVolume.toInt().toString()
        : displayVolume.toStringAsFixed(1);
    return '$formatted $unit';
  }

  /// Parse double safely without throwing
  static double? parseDouble(String text) {
    final cleaned = text.trim().replaceAll(',', '.');
    return double.tryParse(cleaned);
  }

  /// Parse int safely without throwing
  static int? parseInt(String text) {
    return int.tryParse(text.trim());
  }

  /// Check weight input returning validation error code
  static InputValidationError? checkWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return InputValidationError.required;
    }
    final num = parseDouble(value);
    if (num == null) return InputValidationError.invalidNumber;
    if (num < 0) return InputValidationError.negative;
    if (num > 1000) return InputValidationError.tooLarge;
    return null;
  }

  /// Check reps input returning validation error code
  static InputValidationError? checkReps(String? value) {
    if (value == null || value.trim().isEmpty) {
      return InputValidationError.required;
    }
    final num = parseInt(value);
    if (num == null) return InputValidationError.invalidNumber;
    if (num < 0) return InputValidationError.negative;
    if (num > 500) return InputValidationError.tooLarge;
    return null;
  }

  /// Validate weight input
  static String? validateWeight(String? value, {AppLocalizations? l10n}) {
    final err = checkWeight(value);
    if (err == null) return null;
    if (l10n != null) {
      switch (err) {
        case InputValidationError.required:
          return l10n.validationErrorRequired;
        case InputValidationError.invalidNumber:
          return l10n.validationErrorInvalidNumber;
        case InputValidationError.negative:
          return l10n.validationErrorNegative;
        case InputValidationError.tooLarge:
          return l10n.validationErrorTooLarge;
      }
    }
    switch (err) {
      case InputValidationError.required:
        return 'Please enter weight';
      case InputValidationError.invalidNumber:
        return 'Invalid number';
      case InputValidationError.negative:
        return 'Must be >= 0';
      case InputValidationError.tooLarge:
        return 'Value too large';
    }
  }

  /// Validate reps input
  static String? validateReps(String? value, {AppLocalizations? l10n}) {
    final err = checkReps(value);
    if (err == null) return null;
    if (l10n != null) {
      switch (err) {
        case InputValidationError.required:
          return l10n.validationErrorRequired;
        case InputValidationError.invalidNumber:
          return l10n.validationErrorInvalidNumber;
        case InputValidationError.negative:
          return l10n.validationErrorNegative;
        case InputValidationError.tooLarge:
          return l10n.validationErrorTooLarge;
      }
    }
    switch (err) {
      case InputValidationError.required:
        return 'Please enter reps';
      case InputValidationError.invalidNumber:
        return 'Invalid number';
      case InputValidationError.negative:
        return 'Must be >= 0';
      case InputValidationError.tooLarge:
        return 'Value too large';
    }
  }
}
