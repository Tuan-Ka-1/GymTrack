import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/core/providers/app_providers.dart';
import 'package:gymtrack/core/widgets/confirm_dialog.dart';
import 'package:gymtrack/core/widgets/empty_state.dart';
import 'package:gymtrack/data/database/app_database.dart';
import 'package:gymtrack/features/home/presentation/home_screen.dart';
import 'package:gymtrack/features/workout/presentation/workout_plans_screen.dart';
import 'package:gymtrack/features/history/presentation/history_screen.dart';
import 'package:gymtrack/features/progress/presentation/progress_screen.dart';
import 'package:gymtrack/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  group('Widget Tests', () {
    testWidgets('EmptyState widget displays icon, title and action correctly', (
      tester,
    ) async {
      bool buttonClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.fitness_center,
              title: 'No Workouts',
              subtitle: 'Start your first routine',
              action: ElevatedButton(
                onPressed: () => buttonClicked = true,
                child: const Text('Start Now'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('No Workouts'), findsOneWidget);
      expect(find.text('Start your first routine'), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);

      await tester.tap(find.text('Start Now'));
      expect(buttonClicked, isTrue);
    });

    testWidgets('ConfirmDialog displays title, message and triggers actions', (
      tester,
    ) async {
      bool? confirmed;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  confirmed = await ConfirmDialog.show(
                    ctx,
                    title: 'Delete Item?',
                    message: 'Cannot be undone',
                    confirmText: 'Delete',
                    isDestructive: true,
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Item?'), findsOneWidget);
      expect(find.text('Cannot be undone'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Confirm
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    });

    testWidgets('HomeScreen renders with mocked providers', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutHistoryStreamProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
            allTimePRsProvider.overrideWith((ref) => Future.value([])),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('GymTrack'), findsOneWidget);
      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('START WORKOUT'), findsOneWidget);
    });

    testWidgets('WorkoutPlansScreen renders with mocked plans stream', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutPlansStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(home: WorkoutPlansScreen()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Workout Plans'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsAtLeastNWidgets(1));
    });

    testWidgets('HistoryScreen renders with mocked history stream', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutHistoryStreamProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
          child: const MaterialApp(home: HistoryScreen()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Workout History'), findsOneWidget);
    });

    testWidgets('Full GymTrackApp starts and renders root shell', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            workoutHistoryStreamProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
            workoutPlansStreamProvider.overrideWith((ref) => Stream.value([])),
            allTimePRsProvider.overrideWith((ref) => Future.value([])),
          ],
          child: const GymTrackApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('GymTrack'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Workout'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('ProgressScreen displays converted total volume in lb', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weightUnitProvider.overrideWith(_TestLbWeightUnitNotifier.new),
            workoutHistoryStreamProvider.overrideWith(
              (ref) => Stream.value([
                WorkoutSessionEntry(
                  id: 1,
                  dayName: 'Chest Day',
                  startedAt: DateTime(2026, 1, 1),
                  finishedAt: DateTime(2026, 1, 1, 2),
                  durationMinutes: 60,
                  totalVolume: 1000.0, // 1000 kg stored in DB
                ),
              ]),
            ),
            exercisesStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(home: ProgressScreen()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // 1000 kg * 2.20462 = 2204.6 lb
      expect(find.text('2204.6 lb'), findsOneWidget);
      expect(find.text('Total Volume'), findsOneWidget);
    });
  });
}

class _TestLbWeightUnitNotifier extends WeightUnitNotifier {
  @override
  String build() => 'lb';
}
