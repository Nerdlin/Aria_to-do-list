import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/user_profile.dart';
import '../utils/translations.dart';
import 'subscription_service.dart';
import 'task_metrics.dart';
import 'task_service.dart';

enum AppNotificationType { reminder, ai, warning, report }

class AppNotification {
  const AppNotification({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    required this.type,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final AppNotificationType type;
}

class AppNotificationService {
  AppNotificationService._();

  static List<AppNotification> buildNotifications({
    required List<TaskItem> tasks,
    required UserProfile? profile,
  }) {
    final now = DateTime.now();
    final plan = SubscriptionService.instance.planForProfile(profile);
    final todayTasks =
        tasks.where((task) => TaskMetrics.isSameDay(task.date, now)).toList();
    final pendingTasks = tasks.where((task) => !task.isCompleted).toList()
      ..sort((first, second) {
        final priorityCompare = TaskMetrics.priorityWeight(
          second.priority,
        ).compareTo(TaskMetrics.priorityWeight(first.priority));
        if (priorityCompare != 0) {
          return priorityCompare;
        }
        return first.date.compareTo(second.date);
      });
    final overdueTasks =
        pendingTasks.where((task) => task.date.isBefore(now)).toList();
    final upcomingTasks = pendingTasks
        .where(
          (task) =>
              task.date.isAfter(now) &&
              task.date.difference(now).inMinutes <= 120,
        )
        .toList();

    final notifications = <AppNotification>[];

    if ((profile?.smartReminders ?? true) && overdueTasks.isNotEmpty) {
      notifications.add(
        AppNotification(
          title: tr('Overdue tasks'),
          body: tr(
            '{count} task(s) need attention now.',
            namedArgs: {'count': overdueTasks.length.toString()},
          ),
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFEF4444),
          type: AppNotificationType.warning,
        ),
      );
    }

    if ((profile?.pushNotifications ?? true) && upcomingTasks.isNotEmpty) {
      final next = upcomingTasks.first;
      notifications.add(
        AppNotification(
          title: tr('Upcoming focus block'),
          body: tr(
            '{title} starts at {time}.',
            namedArgs: {
              'title': next.title,
              'time': DateFormat('HH:mm').format(next.date),
            },
          ),
          icon: Icons.notifications_active_outlined,
          color: const Color(0xFF8B5CF6),
          type: AppNotificationType.reminder,
        ),
      );
    }

    if ((profile?.dailyDigest ?? true) && todayTasks.isNotEmpty) {
      final completed = todayTasks.where((task) => task.isCompleted).length;
      notifications.add(
        AppNotification(
          title: tr('Daily digest'),
          body: tr(
            '{completed}/{total} tasks completed today.',
            namedArgs: {
              'completed': completed.toString(),
              'total': todayTasks.length.toString(),
            },
          ),
          icon: Icons.today_outlined,
          color: const Color(0xFF10B981),
          type: AppNotificationType.report,
        ),
      );
    }

    if (plan.hasSmartNotifications &&
        (profile?.aiAutoPlanning ?? true) &&
        pendingTasks.isNotEmpty) {
      notifications.add(
        AppNotification(
          title: tr('AI next move'),
          body: tr(
            'Start with "{title}" because it has the highest impact.',
            namedArgs: {'title': pendingTasks.first.title},
          ),
          icon: Icons.auto_awesome_rounded,
          color: const Color(0xFF7C3AED),
          type: AppNotificationType.ai,
        ),
      );
    }

    if (notifications.isEmpty) {
      notifications.add(
        AppNotification(
          title: tr('No alerts right now'),
          body: tr('Your inbox is clear.'),
          icon: Icons.done_all_rounded,
          color: const Color(0xFF10B981),
          type: AppNotificationType.report,
        ),
      );
    }

    return notifications;
  }
}
