import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gymtrack/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('GymTrack App Flow Integration Tests', () {
    testWidgets(
      'Complete flow: Create plan → Start workout → Add exercise → Add sets → Finish → Check history',
      (WidgetTester tester) async {
        // Start the app
        app.main();
        await tester.pumpAndSettle();

        // Wait for app to load
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Navigate to Workout Plans tab (index 1)
        await tester.tap(find.byIcon(Icons.fitness_center).last);
        await tester.pumpAndSettle();

        // Verify we're on Workout Plans screen
        expect(find.text('Workout Plans'), findsOneWidget);

        // Tap on the PPL plan to open it
        await tester.tap(find.text('Push Pull Legs (PPL)'));
        await tester.pumpAndSettle();

        // Verify plan detail screen opens
        expect(find.text('Push Pull Legs (PPL)'), findsOneWidget);

        // Go back to Home tab
        await tester.tap(find.byIcon(Icons.home).first);
        await tester.pumpAndSettle();

        // Tap START WORKOUT on home screen
        await tester.tap(find.text('START WORKOUT'));
        await tester.pumpAndSettle();

        // Verify we're on Active Workout screen
        expect(find.text('Active Workout'), findsOneWidget);

        // Add an exercise
        await tester.tap(find.text('+ ADD EXERCISE'));
        await tester.pumpAndSettle();

        // Select Bench Press from exercise picker
        await tester.tap(find.text('Bench Press').first);
        await tester.pumpAndSettle();

        // Verify exercise was added
        expect(find.text('Bench Press'), findsOneWidget);

        // Enter weight and reps for first set
        final weightFields = find.byType(TextField);
        expect(weightFields, findsAtLeastNWidgets(2));

        await tester.enterText(weightFields.first, '60');
        await tester.enterText(weightFields.at(1), '10');
        await tester.pumpAndSettle();

        // Mark set as completed
        await tester.tap(find.byIcon(Icons.check_circle_outline).first);
        await tester.pumpAndSettle();

        // Add another set
        await tester.tap(find.text('+ ADD SET'));
        await tester.pumpAndSettle();

        // Enter weight and reps for second set
        await tester.enterText(weightFields.at(2), '70');
        await tester.enterText(weightFields.at(3), '8');
        await tester.pumpAndSettle();

        // Mark second set as completed
        await tester.tap(find.byIcon(Icons.check_circle_outline).at(1));
        await tester.pumpAndSettle();

        // Finish workout
        await tester.tap(find.text('FINISH'));
        await tester.pumpAndSettle();

        // Enter notes
        await tester.enterText(find.byType(TextField).last, 'Great workout!');
        await tester.pumpAndSettle();

        await tester.tap(find.text('SAVE').last);
        await tester.pumpAndSettle();

        // Verify workout summary screen
        expect(find.text('Workout Completed!'), findsOneWidget);

        // Go back to Home
        await tester.tap(find.text('BACK TO HOME'));
        await tester.pumpAndSettle();

        // Navigate to History tab (index 2)
        await tester.tap(find.byIcon(Icons.history).last);
        await tester.pumpAndSettle();

        // Verify history screen shows the completed workout
        expect(find.text('History'), findsOneWidget);
        expect(find.textContaining('Push'), findsOneWidget);
      },
    );

    testWidgets('Exercise Library: Create custom exercise and archive it', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Exercises tab (index 4 - or via home screen action)
      // From home screen, tap exercise library icon
      await tester.tap(find.byIcon(Icons.fitness_center).first);
      await tester.pumpAndSettle();

      // Verify exercise library screen
      expect(find.text('Exercise Library'), findsOneWidget);

      // Add custom exercise
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      // Fill in exercise details
      await tester.enterText(
        find.byType(TextField).first,
        'Custom Test Exercise',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('SAVE EXERCISE'));
      await tester.pumpAndSettle();

      // Verify custom exercise appears with CUSTOM badge
      expect(find.text('Custom Test Exercise'), findsOneWidget);
      expect(find.text('CUSTOM'), findsOneWidget);

      // Archive the exercise
      await tester.tap(find.byIcon(Icons.archive_outlined).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Archive').last);
      await tester.pumpAndSettle();

      // Verify exercise is archived (not in main active list)
      expect(find.text('Custom Test Exercise'), findsNothing);

      // Switch to Archived list (toggle via AppBar icon)
      await tester.tap(find.byTooltip('Show Archived'));
      await tester.pumpAndSettle();

      // Verify it appears in archived list with ARCHIVED badge
      expect(find.text('Custom Test Exercise'), findsOneWidget);
      expect(find.text('ARCHIVED'), findsOneWidget);
    });

    testWidgets('Body Tracking: Log body weight', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap body weight icon on home screen
      await tester.tap(find.byIcon(Icons.scale_rounded).first);
      await tester.pumpAndSettle();

      // Add measurement
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      // Enter weight
      await tester.enterText(find.byType(TextField).first, '75.5');
      await tester.pumpAndSettle();

      await tester.tap(find.text('SAVE').last);
      await tester.pumpAndSettle();

      // Verify measurement appears
      expect(find.textContaining('75.5'), findsOneWidget);
    });

    testWidgets('Settings: Toggle dark mode and weight unit', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Settings tab (index 4)
      await tester.tap(find.byIcon(Icons.settings).last);
      await tester.pumpAndSettle();

      // Verify settings screen
      expect(find.text('Settings'), findsOneWidget);

      // Toggle dark mode
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      // Change weight unit to lb
      await tester.tap(find.text('LB').last);
      await tester.pumpAndSettle();

      // Verify unit changed
      expect(find.text('LB'), findsOneWidget);
    });
  });
}
