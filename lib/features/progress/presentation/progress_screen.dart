import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/utils/calculator.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/database/app_database.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  int? _selectedExerciseId;
  int _selectedMetricIndex = 0; // 0: 1RM, 1: Max Weight, 2: Volume

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesStreamProvider);
    final historyAsync = ref.watch(workoutHistoryStreamProvider);
    final repo = ref.watch(workoutRepositoryProvider);
    final weightUnit = ref.watch(weightUnitProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress & Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Top Summary Cards
          historyAsync.when(
            data: (sessions) {
              final totalWorkouts = sessions.length;
              final totalVolume = sessions.fold<double>(
                0.0,
                (sum, s) => sum + s.totalVolume,
              );
              return Row(
                children: [
                  _buildStatCard(
                    'Total Workouts',
                    '$totalWorkouts',
                    Icons.fitness_center_rounded,
                    theme,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Total Volume',
                    Formatters.formatVolume(totalVolume, unit: weightUnit),
                    Icons.bar_chart_rounded,
                    theme,
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),

          // Exercise Progress Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Exercise Analytics',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _selectedMetricIndex == 2
                            ? 'Volume ($weightUnit)'
                            : _selectedMetricIndex == 1
                            ? 'Max Wt ($weightUnit)'
                            : 'Epley 1RM ($weightUnit)',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Dropdown to pick exercise
                  exercisesAsync.when(
                    data: (exercises) {
                      if (exercises.isEmpty) return const SizedBox.shrink();
                      _selectedExerciseId ??= exercises.first.id;

                      return DropdownButtonFormField<int>(
                        value: _selectedExerciseId,
                        decoration: const InputDecoration(
                          labelText: 'Select Exercise',
                        ),
                        items: exercises
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedExerciseId = val);
                          }
                        },
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 12),
                  // Metric toggle: 1RM vs Max Weight vs Volume
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('1RM')),
                      ButtonSegment(value: 1, label: Text('Max Wt')),
                      ButtonSegment(value: 2, label: Text('Volume')),
                    ],
                    selected: {_selectedMetricIndex},
                    onSelectionChanged: (val) {
                      setState(() => _selectedMetricIndex = val.first);
                    },
                  ),
                  const SizedBox(height: 24),
                  // Chart using fl_chart with real SQLite data
                  if (_selectedExerciseId != null)
                    FutureBuilder<List<ExerciseProgressPoint>>(
                      future: repo.getExerciseProgressHistory(
                        _selectedExerciseId!,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final points = snapshot.data ?? [];
                        if (points.isEmpty) {
                          return const SizedBox(
                            height: 180,
                            child: Center(
                              child: Text(
                                'No completed sets recorded for this exercise yet.\nComplete workouts to see your progress curve!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }

                        // Build spots based on selected metric
                        final spots = <FlSpot>[];
                        for (int i = 0; i < points.length; i++) {
                          final p = points[i];
                          double val = 0.0;
                          if (_selectedMetricIndex == 0) {
                            val = weightUnit == 'lb'
                                ? Calculator.kgToLb(p.estimated1RM)
                                : p.estimated1RM;
                          } else if (_selectedMetricIndex == 1) {
                            val = weightUnit == 'lb'
                                ? Calculator.kgToLb(p.maxWeight)
                                : p.maxWeight;
                          } else {
                            val = weightUnit == 'lb'
                                ? Calculator.kgToLb(p.totalVolume)
                                : p.totalVolume;
                          }
                          spots.add(
                            FlSpot(
                              i.toDouble(),
                              double.parse(val.toStringAsFixed(1)),
                            ),
                          );
                        }

                        final maxY =
                            spots
                                .map((s) => s.y)
                                .reduce((a, b) => a > b ? a : b) *
                            1.15;
                        final minY = 0.0;

                        return SizedBox(
                          height: 220,
                          child: LineChart(
                            LineChartData(
                              minY: minY,
                              maxY: maxY > 0 ? maxY : 100,
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipItems: (touchedSpots) {
                                    return touchedSpots.map((spot) {
                                      return LineTooltipItem(
                                        '${spot.y.toStringAsFixed(1)} $weightUnit',
                                        TextStyle(
                                          color: theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: Colors.white10,
                                  strokeWidth: 1,
                                ),
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 42,
                                    getTitlesWidget: (val, meta) => Text(
                                      val.toInt().toString(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (val, meta) {
                                      final idx = val.toInt();
                                      if (idx >= 0 && idx < points.length) {
                                        return Text(
                                          Formatters.formatShortDate(
                                            points[idx].date,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: true,
                                  color: theme.colorScheme.primary,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Personal Records Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.military_tech_rounded,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Personal Records (PR)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  FutureBuilder<List<PersonalRecordItem>>(
                    future: repo.getAllTimePRs(),
                    builder: (context, prSnapshot) {
                      final prs = prSnapshot.data ?? [];
                      if (prs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                            'Complete workout sets to establish your PRs!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return Column(
                        children: prs
                            .map(
                              (pr) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6.0,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        pr.exerciseName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${Formatters.formatWeight(pr.maxWeight, unit: weightUnit)} (Est 1RM: ${Formatters.formatWeight(pr.estimated1RM, unit: weightUnit)})',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
