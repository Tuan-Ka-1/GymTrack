class Calculator {
  /// Calculates estimated 1RM using the Epley formula:
  /// 1RM = weight * (1 + reps / 30)
  /// For 1 rep, 1RM is exactly the weight lifted.
  /// Returns 0.0 for non-positive weight or reps.
  static double calculate1RM(double weight, int reps) {
    if (weight <= 0 || reps <= 0) return 0.0;
    if (reps == 1) return weight;
    return weight * (1.0 + (reps / 30.0));
  }

  /// Calculates total volume for a list of sets: sum of (weight * reps)
  /// Only completed sets are factored in if [onlyCompleted] is true.
  static double calculateVolume(
    List<({double weight, int reps, bool completed})> sets, {
    bool onlyCompleted = true,
  }) {
    double total = 0.0;
    for (final s in sets) {
      if (!onlyCompleted || s.completed) {
        if (s.weight > 0 && s.reps > 0) {
          total += (s.weight * s.reps);
        }
      }
    }
    return total;
  }

  /// Calculates workout duration in minutes between start and finish time
  static int calculateDurationMinutes(
    DateTime startedAt,
    DateTime? finishedAt,
  ) {
    final end = finishedAt ?? DateTime.now();
    final diff = end.difference(startedAt);
    return diff.inMinutes >= 0 ? diff.inMinutes : 0;
  }

  /// Converts kg to lbs
  static double kgToLb(double kg) => kg * 2.20462;

  /// Converts lbs to kg
  static double lbToKg(double lb) => lb / 2.20462;
}
