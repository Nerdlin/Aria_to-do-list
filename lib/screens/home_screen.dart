import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/user_profile.dart';
import '../services/app_controller.dart';
import '../services/task_metrics.dart';
import '../services/task_service.dart';
import '../widgets/profile_avatar.dart';
import 'edit_profile_screen.dart';
import 'tasks_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskService = TaskService();

    return ListenableBuilder(
      listenable: AppController.instance,
      builder: (context, _) {
        final profile = AppController.instance.profile;

        return StreamBuilder<List<TaskItem>>(
          stream: taskService.getTasksStream(),
          builder: (context, snapshot) {
            final tasks = snapshot.data ?? const <TaskItem>[];
            final todayTasks = tasks
                .where((task) => TaskMetrics.isSameDay(task.date, DateTime.now()))
                .toList()
              ..sort((first, second) => first.date.compareTo(second.date));
            final pendingTasks = tasks.where((task) => !task.isCompleted).toList()
              ..sort(_prioritySort);
            final priorityTasks = pendingTasks.take(3).toList();
            final completedToday = todayTasks.where((task) => task.isCompleted).length;
            final focusMinutesToday = TaskMetrics.focusMinutes(
              todayTasks,
              completedOnly: true,
            );
            final streak = TaskMetrics.calculateStreak(tasks);
            final weekTasks = TaskMetrics.tasksForRange(tasks, AnalyticsRange.week);
            final previousWeekTasks = TaskMetrics.previousRangeTasks(
              tasks,
              AnalyticsRange.week,
            );
            final weeklyScore = TaskMetrics.productivityScore(weekTasks).round();
            final previousWeeklyScore =
                TaskMetrics.productivityScore(previousWeekTasks).round();
            final weeklyBuckets = TaskMetrics.buildBuckets(
              weekTasks,
              AnalyticsRange.week,
            );
            final insight = (profile?.aiAutoPlanning ?? true)
                ? TaskMetrics.buildInsight(todayTasks.isNotEmpty ? todayTasks : pendingTasks)
                : 'Turn on AI Auto-Planning in Settings to get live suggestions for your day.';

            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _HomeHeader(
                          profile: profile,
                          insight: insight,
                          onNotificationsTap: () => _showNotificationsSheet(
                            context,
                            todayTasks: todayTasks,
                            pendingTasks: pendingTasks,
                          ),
                          onProfileTap: () => _openProfileEditor(context, profile),
                        ),
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: -54,
                          child: _StatsRow(
                            totalToday: todayTasks.length,
                            completedToday: completedToday,
                            focusMinutesToday: focusMinutesToday,
                            streak: streak,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 74),
                    _SectionHeader(
                      title: "Today's Schedule",
                      actionLabel: 'View all',
                      onActionTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TasksScreen()),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: todayTasks.isEmpty
                          ? _EmptyCard(
                              title: 'No tasks planned for today',
                              subtitle: 'Use the + button to add your first task and your Home screen will start updating automatically.',
                              actionLabel: 'Create task',
                              onTap: () => Navigator.pushNamed(context, '/add-task'),
                            )
                          : Column(
                              children: todayTasks
                                  .map(
                                    (task) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _ScheduleCard(
                                        task: task,
                                        onTap: () => taskService.toggleTask(
                                          task.id,
                                          task.isCompleted,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                    const SizedBox(height: 18),
                    _SectionHeader(
                      title: 'Priority Tasks',
                      actionLabel: 'See all',
                      onActionTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TasksScreen()),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: priorityTasks.isEmpty
                          ? _EmptyCard(
                              title: 'Everything is complete',
                              subtitle: 'You have no pending tasks right now. Add a new one to keep your momentum.',
                              actionLabel: 'Add task',
                              onTap: () => Navigator.pushNamed(context, '/add-task'),
                            )
                          : Column(
                              children: [
                                ...priorityTasks.map(
                                  (task) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _PriorityTaskCard(
                                      task: task,
                                      onTap: () => taskService.toggleTask(
                                        task.id,
                                        task.isCompleted,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => Navigator.pushNamed(context, '/add-task'),
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.auto_awesome_rounded,
                                          color: Color(0xFF7C3AED),
                                          size: 18,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Add another task',
                                          style: TextStyle(
                                            color: Color(0xFF7C3AED),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _WeeklyProgressCard(
                        score: weeklyScore,
                        change: weeklyScore - previousWeeklyScore,
                        buckets: weeklyBuckets,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _FocusModeCard(
                        enabled: profile?.focusMode ?? false,
                        nextTask: priorityTasks.isEmpty ? null : priorityTasks.first,
                        onTap: () async {
                          final nextValue = !(profile?.focusMode ?? false);
                          await AppController.instance.updatePreferences(
                            focusMode: nextValue,
                          );
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                nextValue
                                    ? 'Focus mode enabled.'
                                    : 'Focus mode turned off.',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 94),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static int _prioritySort(TaskItem first, TaskItem second) {
    final priorityCompare =
        TaskMetrics.priorityWeight(second.priority).compareTo(
      TaskMetrics.priorityWeight(first.priority),
    );
    if (priorityCompare != 0) {
      return priorityCompare;
    }
    return first.date.compareTo(second.date);
  }

  static Future<void> _openProfileEditor(
    BuildContext context,
    UserProfile? profile,
  ) async {
    if (profile == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(profile: profile),
      ),
    );
  }

  static void _showNotificationsSheet(
    BuildContext context, {
    required List<TaskItem> todayTasks,
    required List<TaskItem> pendingTasks,
  }) {
    final upcomingToday = todayTasks.where((task) => !task.isCompleted).toList();
    final notifications = <String>[
      if (upcomingToday.isNotEmpty)
        'You still have ${upcomingToday.length} task(s) planned for today.',
      if (pendingTasks.isNotEmpty)
        'Highest priority: ${pendingTasks.first.title}.',
      if (todayTasks.where((task) => task.isCompleted).isNotEmpty)
        'Nice work, you already completed ${todayTasks.where((task) => task.isCompleted).length} today.',
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final items = notifications.isEmpty
            ? const <String>['No alerts right now. Your inbox is clear.']
            : notifications;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF172033)
                          : const Color(0xFFF8F7FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notifications_active_outlined,
                          color: Color(0xFF7C3AED),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(item)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.profile,
    required this.insight,
    required this.onNotificationsTap,
    required this.onProfileTap,
  });

  final UserProfile? profile;
  final String insight;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final name = profile?.displayName ?? 'Aria User';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 106),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6F32FF), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _greeting(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  InkWell(
                    onTap: onNotificationsTap,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: onProfileTap,
                    borderRadius: BorderRadius.circular(18),
                    child: ProfileAvatar(
                      displayName: name,
                      avatarSeed: profile?.avatarSeed ?? 0,
                      imagePath: profile?.localAvatarPath,
                      size: 46,
                      fontSize: 20,
                      borderRadius: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: onNotificationsTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI INSIGHT',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          insight,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 18) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.totalToday,
    required this.completedToday,
    required this.focusMinutesToday,
    required this.streak,
  });

  final int totalToday;
  final int completedToday;
  final int focusMinutesToday;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StatCard(
          label: 'Tasks Done',
          value: '$completedToday',
          unit: '/$totalToday',
          color: const Color(0xFF7C3AED),
        ),
        _StatCard(
          label: 'Focus Time',
          value: (focusMinutesToday / 60).toStringAsFixed(
            focusMinutesToday >= 60 ? 1 : 0,
          ),
          unit: 'h',
          color: const Color(0xFF3B82F6),
        ),
        _StatCard(
          label: 'Streak',
          value: '$streak',
          unit: 'd',
          color: const Color(0xFF10B981),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.66),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          TextButton(
            onPressed: onActionTap,
            child: Text(
              actionLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.task,
    required this.onTap,
  });

  final TaskItem task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = _categoryColor(task.category);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF111827)
              : (task.isCompleted ? const Color(0xFFF9FAFB) : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('h:mm').format(task.date),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface.withValues(alpha: 
                        task.isCompleted ? 0.46 : 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${task.durationMinutes} min',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface.withValues(alpha: 
                        task.isCompleted ? 0.46 : 1,
                      ),
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    task.category,
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? accentColor.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: task.isCompleted
                    ? null
                    : Border.all(color: theme.dividerColor),
              ),
              child: Icon(
                task.isCompleted ? Icons.check_rounded : Icons.play_arrow_rounded,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Personal':
        return const Color(0xFF3B82F6);
      case 'Health':
        return const Color(0xFF10B981);
      case 'Learning':
        return const Color(0xFFF59E0B);
      case 'Finance':
        return const Color(0xFFEF4444);
      case 'Creative':
        return const Color(0xFFEC4899);
      case 'Work':
      default:
        return const Color(0xFF7C3AED);
    }
  }
}

class _PriorityTaskCard extends StatelessWidget {
  const _PriorityTaskCard({
    required this.task,
    required this.onTap,
  });

  final TaskItem task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final priorityColor = _priorityColor(task.priority);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: task.isCompleted
                    ? const Color(0xFF7C3AED)
                    : Colors.transparent,
                border: task.isCompleted
                    ? null
                    : Border.all(color: theme.colorScheme.outline, width: 2),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 
                    task.isCompleted ? 0.45 : 1,
                  ),
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: priorityColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return const Color(0xFF10B981);
      case 'Medium':
        return const Color(0xFFF59E0B);
      case 'High':
      default:
        return const Color(0xFFEF4444);
    }
  }
}

class _WeeklyProgressCard extends StatelessWidget {
  const _WeeklyProgressCard({
    required this.score,
    required this.change,
    required this.buckets,
  });

  final int score;
  final int change;
  final List<AnalyticsBucket> buckets;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WEEKLY SCORE',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.68),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$score%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${change >= 0 ? '+' : ''}$change% vs last week',
                  style: const TextStyle(
                    color: Color(0xFFC4B5FD),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: buckets
                .map(
                  (bucket) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        children: [
                          Container(
                            height: 54,
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: bucket.total == 0
                                  ? 0.12
                                  : (bucket.ratio.clamp(0.08, 1.0)),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: bucket.isCurrent
                                        ? const [
                                            Color(0xFF8B5CF6),
                                            Color(0xFFA78BFA),
                                          ]
                                        : const [
                                            Color(0x805D5FEF),
                                            Color(0x408B5CF6),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            bucket.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  bucket.isCurrent ? FontWeight.w700 : FontWeight.w500,
                              color: bucket.isCurrent
                                  ? const Color(0xFFC4B5FD)
                                  : Colors.white.withValues(alpha: 0.42),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _FocusModeCard extends StatelessWidget {
  const _FocusModeCard({
    required this.enabled,
    required this.nextTask,
    required this.onTap,
  });

  final bool enabled;
  final TaskItem? nextTask;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: enabled
                ? const [Color(0xFF10B981), Color(0xFF059669)]
                : const [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                enabled ? Icons.timer_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    enabled ? 'Focus mode is active' : 'Start focus mode',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextTask == null
                        ? 'Use a 25-minute session to protect your best work.'
                        : 'Next target: ${nextTask!.title}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              height: 1.45,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onTap,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

