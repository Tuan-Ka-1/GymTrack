import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/utils/calculator.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/database/app_database.dart';
import '../../../l10n/app_localizations.dart';

class BodyTrackingScreen extends ConsumerStatefulWidget {
  const BodyTrackingScreen({super.key});

  @override
  ConsumerState<BodyTrackingScreen> createState() => _BodyTrackingScreenState();
}

class _BodyTrackingScreenState extends ConsumerState<BodyTrackingScreen> {
  Future<void> _addMeasurement(BuildContext context) async {
    final weightUnit = ref.read(weightUnitProvider);
    final l10n = AppLocalizations.of(context)!;
    final weightController = TextEditingController();
    final bodyFatController = TextEditingController();
    final chestController = TextEditingController();
    final waistController = TextEditingController();
    final armController = TextEditingController();
    final thighController = TextEditingController();
    final notesController = TextEditingController();

    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.bodyTrackingDialogTitle,
                style: Theme.of(ctx).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.bodyTrackingWeightLabel(weightUnit),
                  hintText: weightUnit == 'lb'
                      ? l10n.bodyTrackingWeightHintLb
                      : l10n.bodyTrackingWeightHintKg,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: bodyFatController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.bodyTrackingBodyFatLabel,
                        hintText: '15.0',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: waistController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.bodyTrackingWaistLabel,
                        hintText: '80',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: chestController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.bodyTrackingChestLabel,
                        hintText: '100',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: armController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.bodyTrackingArmLabel,
                        hintText: '36',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: thighController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.bodyTrackingThighLabel,
                        hintText: '58',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: l10n.bodyTrackingNotesLabel,
                  hintText: l10n.bodyTrackingNotesHint,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    final weight = Formatters.parseDouble(
                      weightController.text,
                    );
                    if (weight != null && weight > 0) {
                      Navigator.of(ctx).pop(true);
                    }
                  },
                  child: Text(
                    l10n.bodyTrackingSaveButton,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (added == true) {
      final repo = ref.read(bodyRepositoryProvider);
      final weight = Formatters.parseWeight(
        weightController.text,
        unit: weightUnit,
      )!;
      await repo.addBodyMeasurement(
        date: DateTime.now(),
        bodyWeight: weight,
        bodyFat: Formatters.parseDouble(bodyFatController.text),
        chest: Formatters.parseDouble(chestController.text),
        waist: Formatters.parseDouble(waistController.text),
        arm: Formatters.parseDouble(armController.text),
        thigh: Formatters.parseDouble(thighController.text),
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final measurementsAsync = ref.watch(bodyMeasurementsStreamProvider);
    final repo = ref.watch(bodyRepositoryProvider);
    final weightUnit = ref.watch(weightUnitProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bodyTrackingTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.bodyTrackingLogTooltip,
            onPressed: () => _addMeasurement(context),
          ),
        ],
      ),
      body: measurementsAsync.when(
        data: (measurements) {
          if (measurements.isEmpty) {
            return EmptyState(
              icon: Icons.monitor_weight_outlined,
              title: l10n.bodyTrackingEmptyTitle,
              subtitle: l10n.bodyTrackingEmptySubtitle,
              action: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(l10n.bodyTrackingLogWeightButton),
                onPressed: () => _addMeasurement(context),
              ),
            );
          }

          // Build weight spots for line chart
          final sortedAsc = List<BodyMeasurementEntry>.from(measurements)
            ..sort((a, b) => a.date.compareTo(b.date));

          final spots = <FlSpot>[];
          final displayWeights = sortedAsc.map((m) {
            return weightUnit == 'lb'
                ? Calculator.kgToLb(m.bodyWeight)
                : m.bodyWeight;
          }).toList();

          for (int i = 0; i < displayWeights.length; i++) {
            spots.add(
              FlSpot(
                i.toDouble(),
                double.parse(displayWeights[i].toStringAsFixed(1)),
              ),
            );
          }

          final minWeight = displayWeights.reduce((a, b) => a < b ? a : b);
          final maxWeight = displayWeights.reduce((a, b) => a > b ? a : b);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Weight Chart Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            l10n.bodyTrackingWeightTrend,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            l10n.bodyTrackingLatestPrefix(
                              Formatters.formatWeight(
                                measurements.first.bodyWeight,
                                unit: weightUnit,
                              ),
                            ),
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 180,
                        child: LineChart(
                          LineChartData(
                            minY: (minWeight - 2).clamp(0, 500),
                            maxY: maxWeight + 2,
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
                              getDrawingHorizontalLine: (val) =>
                                  FlLine(color: Colors.white10, strokeWidth: 1),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 36,
                                  getTitlesWidget: (val, _) => Text(
                                    val.toStringAsFixed(0),
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
                                  getTitlesWidget: (val, _) {
                                    final idx = val.toInt();
                                    if (idx >= 0 && idx < sortedAsc.length) {
                                      return Text(
                                        Formatters.formatShortDate(
                                          sortedAsc[idx].date,
                                          locale: locale,
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
                                color: theme.colorScheme.secondary,
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: theme.colorScheme.secondary.withValues(
                                    alpha: 0.15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.bodyTrackingHistoryTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...measurements.map(
                (m) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      Formatters.formatWeight(m.bodyWeight, unit: weightUnit),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      [
                        Formatters.formatDate(m.date, locale: locale),
                        if (m.bodyFat != null)
                          l10n.bodyTrackingSubtitleFat(
                            m.bodyFat!.toStringAsFixed(1),
                          ),
                        if (m.waist != null)
                          l10n.bodyTrackingSubtitleWaist(
                            m.waist!.toStringAsFixed(1),
                          ),
                      ].join(' • '),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.grey,
                      ),
                      onPressed: () async {
                        final confirmed = await ConfirmDialog.show(
                          context,
                          title: l10n.bodyTrackingDeleteDialogTitle,
                          message: l10n.bodyTrackingDeleteDialogMessage,
                          isDestructive: true,
                        );
                        if (confirmed) {
                          await repo.deleteBodyMeasurement(m.id);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
