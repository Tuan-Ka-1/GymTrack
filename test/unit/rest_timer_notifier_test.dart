import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/core/providers/app_providers.dart';
import 'package:gymtrack/services/notification_service.dart';

class _FakeNotificationService extends NotificationService {
  _FakeNotificationService() : super.test();

  int showRestTimerFinishedCalls = 0;
  int cancelCalls = 0;
  int scheduleRestTimerAtCalls = 0;
  int? lastScheduledEndAt;

  @override
  Future<void> showRestTimerFinished({
    required String title,
    required String body,
  }) async {
    showRestTimerFinishedCalls++;
  }

  @override
  Future<void> scheduleRestTimerAt({
    required int notificationId,
    required int endAtMillis,
    required String title,
    required String body,
  }) async {
    scheduleRestTimerAtCalls++;
    lastScheduledEndAt = endAtMillis;
  }

  @override
  Future<void> cancel(int id) async {
    cancelCalls++;
  }
}

void main() {
  group('RestTimerNotifier Unit Tests', () {
    late _FakeNotificationService fakeNotificationService;
    late ProviderContainer container;
    late DateTime currentTime;

    setUp(() {
      fakeNotificationService = _FakeNotificationService();
      currentTime = DateTime(2026, 1, 1, 12, 0, 0);

      container = ProviderContainer(
        overrides: [
          notificationServiceProvider.overrideWithValue(
            fakeNotificationService,
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('startTimer initializes timer and schedules notification', () {
      final notifier = container.read(restTimerProvider.notifier);
      notifier.setClock(() => currentTime);

      notifier.startTimer(seconds: 90, exerciseName: 'Bench Press');

      final state = container.read(restTimerProvider);
      expect(state.isRunning, isTrue);
      expect(state.remainingSeconds, equals(90));
      expect(state.totalSeconds, equals(90));
      expect(state.exerciseName, equals('Bench Press'));
      expect(
        state.endAtMillis,
        equals(currentTime.millisecondsSinceEpoch + 90000),
      );
      expect(fakeNotificationService.scheduleRestTimerAtCalls, equals(1));
      expect(
        fakeNotificationService.lastScheduledEndAt,
        equals(state.endAtMillis),
      );
    });

    test('addSeconds extends endAt and reschedules notification', () {
      final notifier = container.read(restTimerProvider.notifier);
      notifier.setClock(() => currentTime);

      notifier.startTimer(seconds: 60, exerciseName: 'Squat');
      final originalEndAt = container.read(restTimerProvider).endAtMillis;

      // Elapse 10 seconds
      currentTime = currentTime.add(const Duration(seconds: 10));
      notifier.addSeconds(30);

      final state = container.read(restTimerProvider);
      expect(state.isRunning, isTrue);
      // original was 60s, +30s = originalEndAt + 30000
      expect(state.endAtMillis, equals(originalEndAt + 30000));
      expect(state.remainingSeconds, equals(80)); // 50s left + 30s
      expect(state.totalSeconds, equals(90)); // 60 + 30
      expect(fakeNotificationService.cancelCalls, greaterThanOrEqualTo(1));
      expect(fakeNotificationService.scheduleRestTimerAtCalls, equals(2));
    });

    test('stopTimer cancels ticker, notification and resets state', () {
      final notifier = container.read(restTimerProvider.notifier);
      notifier.setClock(() => currentTime);

      notifier.startTimer(seconds: 60, exerciseName: 'Deadlift');
      expect(container.read(restTimerProvider).isRunning, isTrue);

      notifier.stopTimer();

      final state = container.read(restTimerProvider);
      expect(state.isRunning, isFalse);
      expect(state.remainingSeconds, equals(0));
      expect(state.endAtMillis, equals(0));
      expect(fakeNotificationService.cancelCalls, greaterThanOrEqualTo(1));
    });

    test('Timer finishes in foreground (instant alert triggered)', () {
      final notifier = container.read(restTimerProvider.notifier);
      notifier.setClock(() => currentTime);

      notifier.startTimer(seconds: 30, exerciseName: 'Overhead Press');
      expect(fakeNotificationService.showRestTimerFinishedCalls, equals(0));

      // Advance clock by 30 seconds (just finished)
      currentTime = currentTime.add(const Duration(seconds: 30));
      notifier.updateRemainingFromEndAt();

      final state = container.read(restTimerProvider);
      expect(state.isRunning, isFalse);
      expect(state.remainingSeconds, equals(0));
      // In foreground, finished just now (overdue <= 2.5s) -> fires instant notification
      expect(fakeNotificationService.showRestTimerFinishedCalls, equals(1));
    });

    test('Timer finishes while in background (no duplicate alert when returning)', () {
      final notifier = container.read(restTimerProvider.notifier);
      notifier.setClock(() => currentTime);

      notifier.startTimer(seconds: 30, exerciseName: 'Pull-up');
      expect(fakeNotificationService.showRestTimerFinishedCalls, equals(0));

      // Simulate app was in background: 2 minutes passed since timer ended
      currentTime = currentTime.add(const Duration(seconds: 150));
      notifier.updateRemainingFromEndAt();

      final state = container.read(restTimerProvider);
      expect(state.isRunning, isFalse);
      expect(state.remainingSeconds, equals(0));
      // Overdue by 120s -> Scheduled notification already fired in background;
      // Do NOT trigger duplicate alert on app resume!
      expect(fakeNotificationService.showRestTimerFinishedCalls, equals(0));
    });
  });
}
