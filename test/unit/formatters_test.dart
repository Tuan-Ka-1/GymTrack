import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/core/utils/formatters.dart';

void main() {
  group('Formatters Tests', () {
    group('formatWeight', () {
      test('formats kg without unit conversion', () {
        expect(Formatters.formatWeight(60.0, unit: 'kg'), equals('60 kg'));
        expect(Formatters.formatWeight(62.5, unit: 'kg'), equals('62.5 kg'));
        expect(Formatters.formatWeight(0.0, unit: 'kg'), equals('0 kg'));
      });

      test('formats lb with kg to lb conversion', () {
        // 60 kg = 132.2772 lb -> rounds to 132.3 lb
        expect(Formatters.formatWeight(60.0, unit: 'lb'), equals('132.3 lb'));
        // 100 kg = 220.462 lb -> 220.5 lb
        expect(Formatters.formatWeight(100.0, unit: 'lb'), equals('220.5 lb'));
        // 0 kg = 0 lb
        expect(Formatters.formatWeight(0.0, unit: 'lb'), equals('0.0 lb'));
      });
    });

    group('parseWeight', () {
      test('parses kg input as kg', () {
        expect(Formatters.parseWeight('60', unit: 'kg'), equals(60.0));
        expect(Formatters.parseWeight('62.5', unit: 'kg'), equals(62.5));
        expect(Formatters.parseWeight('0', unit: 'kg'), equals(0.0));
        expect(Formatters.parseWeight('invalid', unit: 'kg'), isNull);
      });

      test('parses lb input and converts to kg', () {
        // 132.3 lb -> ~60 kg
        final result1 = Formatters.parseWeight('132.3', unit: 'lb');
        expect(result1, isNotNull);
        expect(result1!, closeTo(60.0, 0.1));

        // 220.5 lb -> ~100 kg
        final result2 = Formatters.parseWeight('220.5', unit: 'lb');
        expect(result2, isNotNull);
        expect(result2!, closeTo(100.0, 0.1));

        // 0 lb -> 0 kg
        expect(Formatters.parseWeight('0', unit: 'lb'), equals(0.0));
        expect(Formatters.parseWeight('invalid', unit: 'lb'), isNull);
      });
    });

    group('formatVolume', () {
      test('formats volume in kg*reps', () {
        // 1160 kg*reps
        expect(Formatters.formatVolume(1160.0, unit: 'kg'), equals('1160 kg'));
        // 1160.5 kg*reps
        expect(
          Formatters.formatVolume(1160.5, unit: 'kg'),
          equals('1160.5 kg'),
        );
      });

      test('formats volume in lb*reps (converts from kg*reps)', () {
        // 1160 kg*reps * 2.20462 = 2557.4 lb*reps
        expect(
          Formatters.formatVolume(1160.0, unit: 'lb'),
          equals('2557.4 lb'),
        );
        // 1000 kg*reps = 2204.6 lb*reps
        expect(
          Formatters.formatVolume(1000.0, unit: 'lb'),
          equals('2204.6 lb'),
        );
      });
    });

    group('Round-trip kg -> lb -> kg', () {
      test('weight round-trip preserves value', () {
        // Start with 60 kg
        const originalKg = 60.0;
        // Format to lb display
        final displayLb = Formatters.formatWeight(originalKg, unit: 'lb');
        // Parse back from lb input to kg
        final parsedKg = Formatters.parseWeight(
          displayLb.replaceAll(' lb', ''),
          unit: 'lb',
        );
        expect(parsedKg, isNotNull);
        expect(
          parsedKg!,
          closeTo(originalKg, 0.1),
        ); // Within 0.1 kg due to rounding
      });

      test('weight round-trip 100 kg', () {
        const originalKg = 100.0;
        final displayLb = Formatters.formatWeight(originalKg, unit: 'lb');
        final parsedKg = Formatters.parseWeight(
          displayLb.replaceAll(' lb', ''),
          unit: 'lb',
        );
        expect(parsedKg, isNotNull);
        expect(parsedKg!, closeTo(originalKg, 0.1));
      });

      test('weight round-trip 45.36 kg (100 lb)', () {
        // 100 lb = 45.3592 kg
        const originalKg = 45.3592;
        final displayLb = Formatters.formatWeight(originalKg, unit: 'lb');
        final parsedKg = Formatters.parseWeight(
          displayLb.replaceAll(' lb', ''),
          unit: 'lb',
        );
        expect(parsedKg, isNotNull);
        expect(parsedKg!, closeTo(originalKg, 0.1));
      });
    });
  });
}
