import 'package:intl/intl.dart';

import 'calculator.dart';

class Formatters {
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _shortDateFormat = DateFormat('dd/MM');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dayOfWeekFormat = DateFormat('EEEE');

  static String formatDate(DateTime date) => _dateFormat.format(date);
  static String formatShortDate(DateTime date) => _shortDateFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);
  static String formatDayOfWeek(DateTime date) => _dayOfWeekFormat.format(date);

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

  /// Validate weight input
  static String? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter weight';
    }
    final num = parseDouble(value);
    if (num == null) return 'Invalid number';
    if (num < 0) return 'Must be >= 0';
    if (num > 1000) return 'Value too large';
    return null;
  }

  /// Validate reps input
  static String? validateReps(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter reps';
    }
    final num = parseInt(value);
    if (num == null) return 'Invalid number';
    if (num < 0) return 'Must be >= 0';
    if (num > 500) return 'Value too large';
    return null;
  }
}
