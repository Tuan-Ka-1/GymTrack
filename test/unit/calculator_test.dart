import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/core/utils/calculator.dart';

void main() {
  group('Calculator Tests', () {
    test('1RM calculation using Epley formula', () {
      // 1 rep should return exactly the weight
      expect(Calculator.calculate1RM(100.0, 1), equals(100.0));

      // 10 reps at 60kg: 60 * (1 + 10/30) = 60 * (4/3) = 80kg
      expect(Calculator.calculate1RM(60.0, 10), closeTo(80.0, 0.001));

      // 5 reps at 100kg: 100 * (1 + 5/30) = 100 * (7/6) = 116.666...
      expect(Calculator.calculate1RM(100.0, 5), closeTo(116.666, 0.01));

      // Zero or negative values should return 0.0
      expect(Calculator.calculate1RM(0.0, 10), equals(0.0));
      expect(Calculator.calculate1RM(-50.0, 5), equals(0.0));
      expect(Calculator.calculate1RM(100.0, 0), equals(0.0));
      expect(Calculator.calculate1RM(100.0, -2), equals(0.0));
    });

    test('Volume calculation', () {
      final sets = [
        (weight: 60.0, reps: 10, completed: true), // 600
        (weight: 70.0, reps: 8, completed: true), // 560
        (weight: 80.0, reps: 5, completed: false), // 400 (not completed)
        (weight: 0.0, reps: 10, completed: true), // 0
      ];

      // With onlyCompleted = true (default) -> 600 + 560 = 1160
      final completedVol = Calculator.calculateVolume(
        sets,
        onlyCompleted: true,
      );
      expect(completedVol, equals(1160.0));

      // With onlyCompleted = false -> 600 + 560 + 400 = 1560
      final allVol = Calculator.calculateVolume(sets, onlyCompleted: false);
      expect(allVol, equals(1560.0));
    });

    test('Workout duration calculation', () {
      final start = DateTime(2026, 9, 30, 10, 0, 0);
      final finish58 = DateTime(2026, 9, 30, 10, 58, 30);
      final finish90 = DateTime(2026, 9, 30, 11, 30, 0);

      expect(Calculator.calculateDurationMinutes(start, finish58), equals(58));
      expect(Calculator.calculateDurationMinutes(start, finish90), equals(90));
    });

    test('Unit conversions between kg and lb', () {
      expect(Calculator.kgToLb(100.0), closeTo(220.462, 0.001));
      expect(Calculator.lbToKg(220.462), closeTo(100.0, 0.001));
    });
  });
}
