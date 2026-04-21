import 'package:intl/intl.dart';

import 'task_service.dart';

enum AnalyticsRange { week, month, quarter }

class AnalyticsBucket {
  const AnalyticsBucket({
    required this.label,
    required this.completed,
    required this.total,
    this.isCurrent = false,
  });

  final String label;
  final int completed;
  final int total;
  final bool isCurrent;

  double get ratio {
    if (total == 0) {
      return 0;
    }
    return completed / total;
  }
}

class TaskMetrics {
  static bool isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  static int priorityWeight(String priority) {
    switch (priority) {
      case 'High':
        return 3;
      case 'Low':
        return 1;
      case 'Medium':
      default:
        return 2;
    }
  }

  static int calculateStreak(List<TaskItem> tasks) {
    final completedDays = tasks
        .where((task) => task.isCompleted)
        .map((task) => task.completedAt ?? task.date)
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (completedDays.isEmpty) {
      return 0;
    }

    var streak = 0;
    var expectedDate = DateTime.now();
    expectedDate = DateTime(expectedDate.year, expectedDate.month, expectedDate.day);

    final hasToday = completedDays.any((date) => isSameDay(date, expectedDate));
    final hasYesterday = completedDays.any(
      (date) => isSameDay(date, expectedDate.subtract(const Duration(days: 1))),
    );

    if (!hasToday && !hasYesterday) {
      return 0;
    }

    if (!hasToday) {
      expectedDate = expectedDate.subtract(const Duration(days: 1));
    }

    for (final completedDay in completedDays) {
      if (isSameDay(completedDay, expectedDate)) {
        streak += 1;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      }
    }

    return streak;
  }

  static double productivityScore(List<TaskItem> tasks) {
    if (tasks.isEmpty) {
      return 0;
    }

    var totalWeight = 0;
    var completedWeight = 0;

    for (final task in tasks) {
      final weight = priorityWeight(task.priority);
      totalWeight += weight;
      if (task.isCompleted) {
        completedWeight += weight;
      }
    }

    if (totalWeight == 0) {
      return 0;
    }

    return (completedWeight / totalWeight) * 100;
  }

  static int completedCount(List<TaskItem> tasks) {
    return tasks.where((task) => task.isCompleted).length;
  }

  static int focusMinutes(List<TaskItem> tasks, {bool completedOnly = true}) {
    final scopedTasks = completedOnly
        ? tasks.where((task) => task.isCompleted)
        : tasks;
    return scopedTasks.fold<int>(
      0,
      (sum, task) => sum + task.durationMinutes,
    );
  }

  static Map<String, int> categoryCounts(List<TaskItem> tasks) {
    final counts = <String, int>{};
    for (final task in tasks) {
      counts.update(task.category, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  static List<TaskItem> tasksForRange(List<TaskItem> tasks, AnalyticsRange range) {
    final now = DateTime.now();
    late final DateTime start;

    switch (range) {
      case AnalyticsRange.week:
        start = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        break;
      case AnalyticsRange.month:
        start = DateTime(now.year, now.month, 1);
        break;
      case AnalyticsRange.quarter:
        start = DateTime(now.year, now.month - 2, 1);
        break;
    }

    return tasks.where((task) => !task.date.isBefore(start)).toList();
  }

  static List<TaskItem> previousRangeTasks(
    List<TaskItem> tasks,
    AnalyticsRange range,
  ) {
    final now = DateTime.now();
    late DateTime currentStart;
    late DateTime previousStart;

    switch (range) {
      case AnalyticsRange.week:
        currentStart = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        previousStart = currentStart.subtract(const Duration(days: 7));
        break;
      case AnalyticsRange.month:
        currentStart = DateTime(now.year, now.month, 1);
        previousStart = DateTime(now.year, now.month - 1, 1);
        break;
      case AnalyticsRange.quarter:
        currentStart = DateTime(now.year, now.month - 2, 1);
        previousStart = DateTime(currentStart.year, currentStart.month - 3, 1);
        break;
    }

    return tasks
        .where(
          (task) =>
              !task.date.isBefore(previousStart) &&
              task.date.isBefore(currentStart),
        )
        .toList();
  }

  static List<AnalyticsBucket> buildBuckets(
    List<TaskItem> tasks,
    AnalyticsRange range,
  ) {
    final now = DateTime.now();

    switch (range) {
      case AnalyticsRange.week:
        final monday = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        return List<AnalyticsBucket>.generate(7, (index) {
          final day = monday.add(Duration(days: index));
          final dayTasks = tasks.where((task) => isSameDay(task.date, day)).toList();
          return AnalyticsBucket(
            label: DateFormat('E').format(day).substring(0, 1),
            completed: completedCount(dayTasks),
            total: dayTasks.length,
            isCurrent: isSameDay(day, now),
          );
        });
      case AnalyticsRange.month:
        final monthStart = DateTime(now.year, now.month, 1);
        return List<AnalyticsBucket>.generate(5, (index) {
          final start = monthStart.add(Duration(days: index * 7));
          final end = start.add(const Duration(days: 7));
          final bucketTasks = tasks
              .where(
                (task) => !task.date.isBefore(start) && task.date.isBefore(end),
              )
              .toList();
          return AnalyticsBucket(
            label: 'W${index + 1}',
            completed: completedCount(bucketTasks),
            total: bucketTasks.length,
            isCurrent: !now.isBefore(start) && now.isBefore(end),
          );
        });
      case AnalyticsRange.quarter:
        return List<AnalyticsBucket>.generate(3, (index) {
          final monthDate = DateTime(now.year, now.month - (2 - index), 1);
          final bucketTasks = tasks
              .where(
                (task) =>
                    task.date.year == monthDate.year &&
                    task.date.month == monthDate.month,
              )
              .toList();
          return AnalyticsBucket(
            label: DateFormat('MMM').format(monthDate),
            completed: completedCount(bucketTasks),
            total: bucketTasks.length,
            isCurrent:
                monthDate.year == now.year && monthDate.month == now.month,
          );
        });
    }
  }

  static String rangeLabel(AnalyticsRange range) {
    switch (range) {
      case AnalyticsRange.week:
        return 'This week';
      case AnalyticsRange.month:
        return 'This month';
      case AnalyticsRange.quarter:
        return 'Last 3 months';
    }
  }

  static String buildInsight(List<TaskItem> tasks) {
    final pending = tasks.where((task) => !task.isCompleted).toList()
      ..sort((first, second) {
        final weightCompare =
            priorityWeight(second.priority).compareTo(priorityWeight(first.priority));
        if (weightCompare != 0) {
          return weightCompare;
        }
        return first.date.compareTo(second.date);
      });

    if (pending.isEmpty) {
      return 'You are all caught up. Add a new task to keep the momentum going.';
    }

    final nextTask = pending.first;
    final dueLabel = DateFormat('h:mm a').format(nextTask.date);
    return 'Start with "${nextTask.title}". It is your highest impact task and is scheduled for $dueLabel.';
  }
}
