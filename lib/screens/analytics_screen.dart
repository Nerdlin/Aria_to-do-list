import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import '../utils/app_colors.dart';
import '../services/subscription_service.dart';
import '../services/task_metrics.dart';
import '../services/task_service.dart';
import '../utils/translations.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  final TaskService _taskService = TaskService();

  late final AnimationController _animationController;
  late final Animation<double> _scoreAnimation;

  AnalyticsRange _selectedRange = AnalyticsRange.week;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _scoreAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: StreamBuilder<List<TaskItem>>(
          stream: _taskService.getTasksStream(),
          builder: (context, snapshot) {
            final allTasks = snapshot.data ?? const <TaskItem>[];
            final rangeTasks =
                TaskMetrics.tasksForRange(allTasks, _selectedRange);
            final previousRangeTasks = TaskMetrics.previousRangeTasks(
              allTasks,
              _selectedRange,
            );
            final score = TaskMetrics.productivityScore(rangeTasks).round();
            final previousScore =
                TaskMetrics.productivityScore(previousRangeTasks).round();
            final completed = TaskMetrics.completedCount(rangeTasks);
            final focusHours = TaskMetrics.focusMinutes(rangeTasks) / 60;
            final streak = TaskMetrics.calculateStreak(allTasks);
            final buckets =
                TaskMetrics.buildBuckets(rangeTasks, _selectedRange);
            final categories = TaskMetrics.categoryCounts(rangeTasks);
            final achievements = _buildAchievements(
              rangeTasks: rangeTasks,
              focusHours: focusHours,
              streak: streak,
            );
            final plan = SubscriptionService.instance.planForProfile(
              AppController.instance.profile,
            );

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr('Analytics'),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tr(TaskMetrics.rangeLabel(_selectedRange)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.64),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _RangeChip(
                              label: 'W',
                              selected: _selectedRange == AnalyticsRange.week,
                              onTap: () => _setRange(AnalyticsRange.week),
                            ),
                            _RangeChip(
                              label: 'M',
                              selected: _selectedRange == AnalyticsRange.month,
                              onTap: () => _setRange(AnalyticsRange.month),
                            ),
                            _RangeChip(
                              label: '3M',
                              selected:
                                  _selectedRange == AnalyticsRange.quarter,
                              onTap: () => _setRange(AnalyticsRange.quarter),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        _ScoreCard(
                          animation: _scoreAnimation,
                          score: score,
                          change: score - previousScore,
                          label: _scoreLabel(score),
                        ),
                        const SizedBox(height: 12),
                        _StatsGrid(
                          score: score,
                          completed: completed,
                          total: rangeTasks.length,
                          focusHours: focusHours,
                          streak: streak,
                        ),
                        const SizedBox(height: 12),
                        _TrendCard(
                          title: _selectedRange == AnalyticsRange.week
                              ? tr('Productivity Trend')
                              : tr('Completion Trend'),
                          subtitle: tr(TaskMetrics.rangeLabel(_selectedRange)),
                          buckets: buckets,
                        ),
                        const SizedBox(height: 12),
                        if (plan.hasAdvancedAnalytics) ...[
                          _CategoryBreakdownCard(
                            total: rangeTasks.length,
                            categories: categories,
                          ),
                          const SizedBox(height: 12),
                          _AchievementsCard(achievements: achievements),
                        ] else
                          const _UpgradeAnalyticsCard(),
                        if (rangeTasks.isEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF111827)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            child: Text(
                              tr('Analytics will fill up automatically as you add and complete tasks in this period.'),
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.72),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _setRange(AnalyticsRange range) {
    setState(() => _selectedRange = range);
    _animationController.forward(from: 0);
  }

  String _scoreLabel(int score) {
    if (score >= 80) {
      return tr('Excellent');
    }
    if (score >= 60) {
      return tr('Strong');
    }
    if (score >= 40) {
      return tr('Building momentum');
    }
    return tr('Needs attention');
  }

  List<_AchievementData> _buildAchievements({
    required List<TaskItem> rangeTasks,
    required double focusHours,
    required int streak,
  }) {
    final aiCount = rangeTasks.where((task) => task.isAiPick).length;
    final completionRate = TaskMetrics.productivityScore(rangeTasks);

    return [
      _AchievementData(
        emoji: 'Streak',
        label: '$streak-day\nrun',
        unlocked: streak >= 3,
      ),
      _AchievementData(
        emoji: 'Focus',
        label: '${focusHours.toStringAsFixed(1)}h\nfocused',
        unlocked: focusHours >= 2,
      ),
      _AchievementData(
        emoji: 'Closer',
        label: '${completionRate.round()}%\ncomplete',
        unlocked: completionRate >= 70,
      ),
      _AchievementData(
        emoji: 'AI',
        label: '$aiCount AI\npicks',
        unlocked: aiCount >= 2,
      ),
    ];
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 30,
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  )
                : null,
            color: selected ? null : Theme.of(context).dividerColor,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: selected
                  ? Colors.white
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.animation,
    required this.score,
    required this.change,
    required this.label,
  });

  final Animation<double> animation;
  final int score;
  final int change;
  final String label;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 330 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.2;
        final ring = SizedBox(
          width: 82,
          height: 82,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              return CustomPaint(
                painter: _ScoreRingPainter((score / 100) * animation.value),
                child: Center(
                  child: Text(
                    '$score%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              );
            },
          ),
        );
        final content = Column(
          crossAxisAlignment:
              compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(
              tr('PERFORMANCE SCORE'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: compact ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.66),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: compact ? TextAlign.center : TextAlign.start,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxWidth: 230),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                tr(
                  '{sign}{change}% vs previous period',
                  namedArgs: {
                    'sign': change >= 0 ? '+' : '',
                    'change': change.abs().toString(),
                  },
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: compact ? TextAlign.center : TextAlign.start,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFC4B5FD),
                ),
              ),
            ),
          ],
        );

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1E1B4B),
                Color(0xFF312E81),
                Color(0xFF4C1D95),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: compact
              ? Column(
                  children: [
                    ring,
                    const SizedBox(height: 14),
                    content,
                  ],
                )
              : Row(
                  children: [
                    ring,
                    const SizedBox(width: 20),
                    Expanded(child: content),
                  ],
                ),
        );
      },
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.score,
    required this.completed,
    required this.total,
    required this.focusHours,
    required this.streak,
  });

  final int score;
  final int completed;
  final int total;
  final double focusHours;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatTileData(
        label: tr('Productivity'),
        value: '$score%',
        change: '${score >= 60 ? '+' : ''}$score',
        positive: score >= 60,
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF8B5CF6),
      ),
      _StatTileData(
        label: tr('Completed'),
        value: '$completed / $total',
        change: '${completed >= math.max(1, total ~/ 2) ? '+' : ''}$completed',
        positive: completed >= math.max(1, total ~/ 2),
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF10B981),
      ),
      _StatTileData(
        label: tr('Focus Hours'),
        value: '${focusHours.toStringAsFixed(1)}h',
        change: focusHours >= 2 ? '+Focus' : 'Low',
        positive: focusHours >= 2,
        icon: Icons.access_time_rounded,
        color: const Color(0xFF60A5FA),
      ),
      _StatTileData(
        label: tr('Streak'),
        value: '$streak',
        change: streak >= 3 ? '+Hot' : 'Warm up',
        positive: streak >= 3,
        icon: Icons.local_fire_department_rounded,
        color: const Color(0xFFF59E0B),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final compact = constraints.maxWidth < 360 || textScale > 1.15;
        final aspectRatio = compact ? 0.92 : 1.05;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, index) {
            final stat = stats[index];
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              padding: EdgeInsets.all(compact ? 12 : 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: compact ? 32 : 34,
                    height: compact ? 32 : 34,
                    decoration: BoxDecoration(
                      color: stat.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(stat.icon, color: stat.color, size: 18),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        stat.value,
                        style: TextStyle(
                          fontSize: compact ? 21 : 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    stat.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 13 : 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.64),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat.change,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: stat.positive
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.title,
    required this.subtitle,
    required this.buckets,
  });

  final String title;
  final String subtitle;
  final List<AnalyticsBucket> buckets;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 96,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: buckets
                  .map(
                    (bucket) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: bucket.total == 0
                                      ? 0.1
                                      : bucket.ratio.clamp(0.08, 1.0),
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
                                            : [
                                                const Color(0xFF8B5CF6)
                                                    .withValues(alpha: 0.75),
                                                const Color(0xFF8B5CF6)
                                                    .withValues(alpha: 0.22),
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              bucket.label,
                              style: TextStyle(
                                fontWeight: bucket.isCurrent
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: bucket.isCurrent
                                    ? const Color(0xFF8B5CF6)
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.56),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdownCard extends StatelessWidget {
  const _CategoryBreakdownCard({
    required this.total,
    required this.categories,
  });

  final int total;
  final Map<String, int> categories;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = categories.entries.isEmpty
        ? <MapEntry<String, int>>[
            MapEntry<String, int>(tr('No tasks yet'), 0),
          ]
        : (categories.entries.toList()
          ..sort((first, second) => second.value.compareTo(first.value)));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Task Categories'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          ...items.map((entry) {
            final color = AppColors.categoryColor(entry.key);
            final percentage =
                total == 0 ? 0 : ((entry.value / total) * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tr(entry.key),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 6,
                      backgroundColor: Theme.of(context).dividerColor,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AchievementsCard extends StatelessWidget {
  const _AchievementsCard({
    required this.achievements,
  });

  final List<_AchievementData> achievements;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF111827), Color(0xFF1E1B4B)]
              : const [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Achievements'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 8) / 2;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: achievements
                    .map(
                      (achievement) => SizedBox(
                        width: itemWidth,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 84),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: achievement.unlocked
                                ? (isDark
                                    ? const Color(0xFF172033)
                                    : Colors.white)
                                : (isDark
                                    ? const Color(0xFF0F172A)
                                        .withValues(alpha: 0.82)
                                    : Colors.white.withValues(alpha: 0.55)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                achievement.emoji,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                achievement.label,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  height: 1.35,
                                  fontWeight: FontWeight.w700,
                                  color: achievement.unlocked
                                      ? (isDark
                                          ? const Color(0xFFE2E8F0)
                                          : const Color(0xFF475569))
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _UpgradeAnalyticsCard extends StatelessWidget {
  const _UpgradeAnalyticsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('Advanced analytics'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  tr('Upgrade to Pro to unlock categories, achievements, and deeper reports.'),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.64),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/subscription'),
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              tr('Upgrade'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTileData {
  const _StatTileData({
    required this.label,
    required this.value,
    required this.change,
    required this.positive,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String change;
  final bool positive;
  final IconData icon;
  final Color color;
}

class _AchievementData {
  const _AchievementData({
    required this.emoji,
    required this.label,
    required this.unlocked,
  });

  final String emoji;
  final String label;
  final bool unlocked;
}

class _ScoreRingPainter extends CustomPainter {
  const _ScoreRingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 7;

    final backgroundPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;

    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFA78BFA), Color(0xFF60A5FA)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      (2 * math.pi) * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
