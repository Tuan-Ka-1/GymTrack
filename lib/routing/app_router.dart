import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/database/app_database.dart';
import '../l10n/app_localizations.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/workout/presentation/workout_plans_screen.dart';
import '../features/workout/presentation/plan_detail_screen.dart';
import '../features/workout/presentation/active_workout_screen.dart';
import '../features/workout/presentation/workout_summary_screen.dart';
import '../features/exercises/presentation/exercise_library_screen.dart';
import '../features/exercises/presentation/create_exercise_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/history/presentation/workout_history_detail_screen.dart';
import '../features/progress/presentation/progress_screen.dart';
import '../features/body/presentation/body_tracking_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Bottom Navigation Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Home
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          ],
        ),
        // Tab 2: Workout Plans
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/workout',
              builder: (context, state) => const WorkoutPlansScreen(),
            ),
          ],
        ),
        // Tab 3: History
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
        // Tab 4: Progress
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/progress',
              builder: (context, state) => const ProgressScreen(),
            ),
          ],
        ),
        // Tab 5: Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),

    // Sub-screens outside bottom nav shell
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/plan-detail/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return PlanDetailScreen(planId: id);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/active-workout/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ActiveWorkoutScreen(sessionId: id);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/workout-summary/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return WorkoutSummaryScreen(sessionId: id);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/history-detail/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return WorkoutHistoryDetailScreen(sessionId: id);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/exercises',
      builder: (context, state) => const ExerciseLibraryScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/create-exercise',
      builder: (context, state) =>
          CreateExerciseScreen(exerciseToEdit: state.extra as ExerciseEntry?),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/body-tracking',
      builder: (context, state) => const BodyTrackingScreen(),
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: AppLocalizations.of(context)?.navHome ?? 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.fitness_center_outlined),
            selectedIcon: const Icon(Icons.fitness_center_rounded),
            label: AppLocalizations.of(context)?.navWorkout ?? 'Workout',
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history_rounded),
            label: AppLocalizations.of(context)?.navHistory ?? 'History',
          ),
          NavigationDestination(
            icon: const Icon(Icons.show_chart_outlined),
            selectedIcon: const Icon(Icons.show_chart_rounded),
            label: AppLocalizations.of(context)?.navProgress ?? 'Progress',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: AppLocalizations.of(context)?.navSettings ?? 'Settings',
          ),
        ],
      ),
    );
  }
}
