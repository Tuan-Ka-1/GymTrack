import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';

class RestTimerBanner extends ConsumerWidget {
  const RestTimerBanner({super.key}) : _state = null;

  /// Creates a RestTimerBanner with a predefined state (useful for testing)
  const RestTimerBanner.fromState(this._state, {super.key});

  final RestTimerState? _state;

  RestTimerState _getState(WidgetRef ref) {
    if (_state != null) return _state;
    return ref.watch(restTimerProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = _getState(ref);
    if (!timerState.isRunning && timerState.remainingSeconds <= 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2638),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.timer_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n?.restTimerTitle.toUpperCase() ?? 'REST TIMER',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  Formatters.formatTimer(timerState.remainingSeconds),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(60, 36),
            ),
            onPressed: () {
              if (_state != null) return; // No-op in test mode
              ref.read(restTimerProvider.notifier).addSeconds(30);
            },
            child: const Text(
              '+30s',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white12,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              if (_state != null) return; // No-op in test mode
              ref.read(restTimerProvider.notifier).stopTimer();
            },
          ),
        ],
      ),
    );
  }
}
