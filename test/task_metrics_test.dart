import 'package:aria_productivity_app/services/task_metrics.dart';
import 'package:aria_productivity_app/services/task_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaskMetrics', () {
    test('productivity score uses priority weights', () {
      final now = DateTime.now();
      final tasks = [
        _task(id: 'high', priority: 'High', date: now, isCompleted: true),
        _task(id: 'medium', priority: 'Medium', date: now),
        _task(id: 'low', priority: 'Low', date: now, isCompleted: true),
      ];

      expect(TaskMetrics.productivityScore(tasks).round(), 67);
    });

    test('streak counts consecutive completed days', () {
      final today = _day(DateTime.now());
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      final tasks = [
        _task(
          id: 'today',
          date: today,
          isCompleted: true,
          completedAt: today,
        ),
        _task(
          id: 'yesterday',
          date: yesterday,
          isCompleted: true,
          completedAt: yesterday,
        ),
        _task(
          id: 'two-days-ago',
          date: twoDaysAgo,
          isCompleted: true,
          completedAt: twoDaysAgo,
        ),
      ];

      expect(TaskMetrics.calculateStreak(tasks), 3);
    });

    test('weekly buckets always include seven days and mark current day', () {
      final buckets = TaskMetrics.buildBuckets(
        const <TaskItem>[],
        AnalyticsRange.week,
      );

      expect(buckets, hasLength(7));
      expect(buckets.where((bucket) => bucket.isCurrent), hasLength(1));
    });
  });
}

TaskItem _task({
  required String id,
  required DateTime date,
  String priority = 'Medium',
  bool isCompleted = false,
  DateTime? completedAt,
}) {
  return TaskItem(
    id: id,
    title: id,
    priority: priority,
    category: 'Work',
    date: date,
    durationMinutes: 30,
    isCompleted: isCompleted,
    isAiPick: false,
    createdAt: date,
    completedAt: completedAt,
  );
}

DateTime _day(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
