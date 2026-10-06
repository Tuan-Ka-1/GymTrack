import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/core/providers/app_providers.dart';
import 'package:gymtrack/data/database/app_database.dart';
import 'package:gymtrack/features/exercises/data/exercise_catalog_loader.dart';
import 'package:gymtrack/features/exercises/domain/exercise_catalog.dart';
import 'package:gymtrack/features/exercises/presentation/exercise_detail_screen.dart';
import 'package:gymtrack/features/exercises/presentation/exercise_library_screen.dart';
import 'package:gymtrack/features/workout/presentation/widgets/exercise_picker_dialog.dart';

void main() {
  late ExerciseCatalog catalog;

  setUpAll(() {
    final catalogFile = File('assets/data/exercise_catalog.json');
    catalog = ExerciseCatalogLoader.loadFromString(
      catalogFile.readAsStringSync(),
    );
    ExerciseCatalogLoader.setCache(catalog);
  });

  final testExercises = [
    ExerciseEntry(
      id: 1,
      name: 'Bench Press',
      muscleGroup: 'Chest',
      equipment: 'Barbell',
      exerciseType: 'Weight & Reps',
      catalogKey: 'bench_press',
      isCustom: false,
      isArchived: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ExerciseEntry(
      id: 2,
      name: 'Back Squat',
      muscleGroup: 'Legs',
      equipment: 'Barbell',
      exerciseType: 'Weight & Reps',
      catalogKey: 'squat',
      isCustom: false,
      isArchived: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ExerciseEntry(
      id: 3,
      name: 'Custom Curl',
      muscleGroup: 'Biceps',
      equipment: 'Dumbbell',
      exerciseType: 'Weight & Reps',
      isCustom: true,
      isArchived: false,
      instructions: 'Step 1: Curl up\nStep 2: Lower down',
      tips: 'Keep elbows tucked',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  Widget createTestWidget(Widget child) {
    return ProviderScope(
      overrides: [
        exercisesStreamProvider.overrideWith(
          (ref) => Stream.value(testExercises),
        ),
        exerciseCatalogProvider.overrideWith((ref) => Future.value(catalog)),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  group('Exercise UI Widget Tests', () {
    testWidgets(
      'ExerciseLibraryScreen displays search bar, filter chips, and exercise cards',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(const ExerciseLibraryScreen()),
        );
        await tester.pumpAndSettle();

        // Verify search field exists
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Exercise Library'), findsOneWidget);

        // Verify filter chips exist
        expect(find.text('All Muscles'), findsOneWidget);
        expect(find.text('Chest'), findsOneWidget);
        expect(find.text('Legs'), findsOneWidget);

        // Verify Bench Press is rendered in the list
        expect(find.text('Bench Press'), findsWidgets);

        // Test Search query filtering
        await tester.enterText(find.byType(TextField), 'Squat');
        await tester.pumpAndSettle();

        expect(find.text('Back Squat'), findsWidgets);
        expect(find.text('Bench Press'), findsNothing);

        // Clear search
        await tester.tap(find.byIcon(Icons.clear));
        await tester.pumpAndSettle();
        expect(find.text('Bench Press'), findsWidgets);
      },
    );

    testWidgets(
      'ExerciseDetailScreen renders instructions, tips, and metadata',
      (WidgetTester tester) async {
        final bench = testExercises.first;

        await tester.pumpWidget(
          createTestWidget(ExerciseDetailScreen(exercise: bench)),
        );
        await tester.pumpAndSettle();

        // Title & chips
        expect(find.text('Bench Press'), findsWidgets);
        expect(find.text('Primary: Chest'), findsOneWidget);
        expect(find.text('Barbell'), findsOneWidget);

        // Sections
        expect(find.text('Instructions'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Pro Tips & Cues'),
          100.0,
          scrollable: find.byType(Scrollable).last,
        );
        expect(find.text('Pro Tips & Cues'), findsOneWidget);
      },
    );

    testWidgets(
      'ExercisePickerDialog shows exercises, filters, and allows picking',
      (WidgetTester tester) async {
        ExerciseEntry? picked;

        await tester.pumpWidget(
          createTestWidget(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  picked = await ExercisePickerDialog.show(context);
                },
                child: const Text('Open Picker'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open picker
        await tester.tap(find.text('Open Picker'));
        await tester.pumpAndSettle();

        expect(find.text('Select Exercise'), findsOneWidget);
        expect(find.text('ADD'), findsWidgets);

        // Tap ADD on first visible exercise
        await tester.tap(find.text('ADD').first);
        await tester.pumpAndSettle();

        expect(picked, isNotNull);
        expect(picked!.name, equals('Bench Press'));
      },
    );
  });
}
