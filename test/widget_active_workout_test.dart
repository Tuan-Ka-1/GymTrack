import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/core/providers/app_providers.dart';
import 'package:gymtrack/data/database/app_database.dart';
import 'package:gymtrack/data/repositories/workout_repository_impl.dart';
import 'package:gymtrack/features/workout/presentation/active_workout_screen.dart';
import 'package:gymtrack/features/workout/presentation/widgets/rest_timer_banner.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Rest Timer Banner Widget Tests', () {
    testWidgets('RestTimerBanner shows when timer is running', (
      WidgetTester tester,
    ) async {
      const testState = RestTimerState(
        remainingSeconds: 90,
        totalSeconds: 90,
        isRunning: true,
        exerciseName: 'Bench Press',
        endAtMillis: 0,
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: RestTimerBanner.fromState(testState))),
      );

      await tester.pumpAndSettle();

      expect(find.text('REST TIMER'), findsOneWidget);
      expect(find.text('01:30'), findsOneWidget);
      expect(find.text('+30s'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('RestTimerBanner hides when timer not running', (
      WidgetTester tester,
    ) async {
      const testState = RestTimerState(
        remainingSeconds: 0,
        totalSeconds: 90,
        isRunning: false,
        exerciseName: null,
        endAtMillis: 0,
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: RestTimerBanner.fromState(testState))),
      );

      await tester.pumpAndSettle();

      expect(find.text('REST TIMER'), findsNothing);
    });

    testWidgets('+30s button shows but does not change state in test mode', (
      WidgetTester tester,
    ) async {
      const testState = RestTimerState(
        remainingSeconds: 90,
        totalSeconds: 90,
        isRunning: true,
        exerciseName: 'Bench Press',
        endAtMillis: 0,
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: RestTimerBanner.fromState(testState))),
      );

      await tester.pumpAndSettle();

      // Tap +30s - in test mode it won't change state but button should be tappable
      await tester.tap(find.text('+30s'));
      await tester.pumpAndSettle();

      // State won't change in test mode but UI should still render
      expect(find.text('REST TIMER'), findsOneWidget);
    });

    testWidgets('Close button is present', (WidgetTester tester) async {
      const testState = RestTimerState(
        remainingSeconds: 90,
        totalSeconds: 90,
        isRunning: true,
        exerciseName: 'Bench Press',
        endAtMillis: 0,
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: RestTimerBanner.fromState(testState))),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });

  group('Active Workout Screen Widget Tests', () {
    late AppDatabase db;
    late WorkoutRepositoryImpl repo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repo = WorkoutRepositoryImpl(db);
      await db.seedDatabaseIfEmpty();
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets(
      'ActiveWorkoutScreen: Add Set, enter weight/reps, tick completed, and validate input',
      (WidgetTester tester) async {
        // 1. Prepare session in DB with Bench Press
        final sessionId = await repo.startWorkoutSession(dayName: 'Chest Day');
        final bench = (await db.select(db.exercises).get()).firstWhere(
          (e) => e.name == 'Bench Press',
        );
        final exSessionId = await repo.addExerciseToSession(
          sessionId,
          bench.id,
          bench.name,
        );

        // 2. Render ActiveWorkoutScreen
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              databaseProvider.overrideWithValue(db),
              workoutRepositoryProvider.overrideWithValue(repo),
            ],
            child: MaterialApp(home: ActiveWorkoutScreen(sessionId: sessionId)),
          ),
        );
        await tester.pumpAndSettle();

        // Verify exercise name and set 1 are visible
        expect(find.text('Bench Press'), findsOneWidget);
        expect(find.text('1'), findsOneWidget); // Set number 1

        // 3. Add Set
        final addSetBtn = find.text('+ ADD SET');
        expect(addSetBtn, findsOneWidget);
        await tester.ensureVisible(addSetBtn);
        await tester.tap(addSetBtn);
        await tester.pumpAndSettle();

        // Verify Set 2 is added
        expect(find.text('2'), findsOneWidget);

        // 4. Enter weight and reps for Set 1
        final textFields = find.byType(TextField);
        // Note: TextField 0 is weight for set 1, TextField 1 is reps for set 1
        await tester.enterText(textFields.at(0), '85.5');
        await tester.enterText(textFields.at(1), '10');
        await tester.pumpAndSettle();

        // 5. Tick completed for Set 1
        // The check button inside WorkoutSetRow
        final checkButtons = find.widgetWithIcon(IconButton, Icons.check);
        expect(checkButtons, findsAtLeastNWidgets(2));
        await tester.tap(checkButtons.first);
        await tester.pumpAndSettle();

        // Verify Set 1 is saved in DB as completed with 85.5 kg and 10 reps
        final savedSets = await repo.getSetsForExerciseSession(exSessionId);
        expect(savedSets.length, equals(2));
        expect(savedSets[0].completed, isTrue);
        expect(savedSets[0].weight, equals(85.5));
        expect(savedSets[0].reps, equals(10));

        // 6. Test input validation (invalid weight/reps does not crash and defaults gracefully)
        await tester.enterText(textFields.at(2), 'invalid_text');
        await tester.enterText(textFields.at(3), '-');
        await tester.pumpAndSettle();

        // Tick completed for Set 2 with invalid text
        await tester.tap(checkButtons.at(1));
        await tester.pumpAndSettle();

        final savedSetsAfter = await repo.getSetsForExerciseSession(
          exSessionId,
        );
        expect(savedSetsAfter[1].completed, isTrue);
        expect(savedSetsAfter[1].weight, equals(0.0)); // Fallback safely
        expect(savedSetsAfter[1].reps, equals(0));

        // 7. Clean up rest timer and pending drift stream timers
        final container = ProviderScope.containerOf(
          tester.element(find.byType(ActiveWorkoutScreen)),
        );
        container.read(restTimerProvider.notifier).stopTimer();
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
      },
    );
  });
}
