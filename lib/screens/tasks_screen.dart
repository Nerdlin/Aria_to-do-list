import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../services/task_metrics.dart';
import '../services/task_service.dart';
import '../utils/app_colors.dart';
import '../utils/translations.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskService _taskService = TaskService();

  String _searchQuery = '';
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF111827) : Colors.white;
    final subdued = isDark ? const Color(0xFF172033) : const Color(0xFFF8F7FF);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: StreamBuilder<List<TaskItem>>(
          stream: _taskService.getTasksStream(),
          builder: (context, snapshot) {
            final allTasks = snapshot.data ?? const <TaskItem>[];
            final filteredTasks = _filterTasks(allTasks);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('My Tasks'),
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tr(
                            '{completed} completed, {pending} still in motion',
                            namedArgs: {
                              'completed': TaskMetrics.completedCount(allTasks)
                                  .toString(),
                              'pending': allTasks
                                  .where((task) => !task.isCompleted)
                                  .length
                                  .toString(),
                            },
                          ),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.68),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF8B5CF6),
                                      Color(0xFF6366F1)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tr('Smart queue'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tr('Tap a task to mark it done. Delete the ones you no longer need.'),
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.68),
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    child: TextField(
                      onChanged: (value) {
                        setState(() => _searchQuery = value.toLowerCase());
                      },
                      decoration: InputDecoration(
                        hintText: tr('Search tasks...'),
                        prefixIcon: const Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildFilterChip('All'),
                        _buildFilterChip('Today'),
                        _buildFilterChip('High Priority'),
                        _buildFilterChip('AI Pick'),
                        _buildFilterChip('Completed'),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 14)),
                if (snapshot.connectionState == ConnectionState.waiting &&
                    allTasks.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (filteredTasks.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                color: subdued,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: const Icon(
                                Icons.inbox_outlined,
                                size: 38,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              tr('No tasks match the selected filter.'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tr('Try another filter or create a new task from the center button.'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.68),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Dismissible(
                            key: ValueKey(task.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) => _confirmDismiss(task),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.error,
                                size: 28,
                              ),
                            ),
                            child: _buildTaskCard(context, task),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _activeFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(tr(filter)),
        selected: isSelected,
        onSelected: (_) => setState(() => _activeFilter = filter),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskItem task) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final priorityColor = AppColors.priorityColor(task.priority);
    final isOverdue = !task.isCompleted && task.date.isBefore(DateTime.now());

    return InkWell(
      onTap: () => _toggleTask(task),
      onLongPress: () => _editTask(task),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
                border: task.isCompleted
                    ? null
                    : Border.all(color: theme.colorScheme.outline, width: 2),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 19)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: task.isCompleted
                                ? theme.colorScheme.onSurface
                                    .withValues(alpha: 0.45)
                                : theme.colorScheme.onSurface,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      if (task.isAiPick)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 12,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'AI',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (task.note.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      task.note.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        height: 1.4,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMetaPill(
                        context,
                        label: task.priority,
                        color: priorityColor,
                      ),
                      _buildMetaPill(
                        context,
                        label: task.category,
                        color: AppColors.categoryColor(task.category),
                      ),
                      _buildMetaPill(
                        context,
                        label: DateFormat('EEE, h:mm a').format(task.date),
                        color: AppColors.info,
                      ),
                      _buildMetaPill(
                        context,
                        label: tr(
                          '{min} min',
                          namedArgs: {'min': task.durationMinutes.toString()},
                        ),
                        color: AppColors.success,
                      ),
                      if (isOverdue)
                        _buildMetaPill(
                          context,
                          label: tr('Overdue'),
                          color: AppColors.error,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => _confirmAndDelete(task),
              icon: const Icon(Icons.delete_outline_rounded),
              color: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaPill(
    BuildContext context, {
    required String label,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.15)
            : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        tr(label),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  List<TaskItem> _filterTasks(List<TaskItem> tasks) {
    final now = DateTime.now();
    final normalizedQuery = _searchQuery.trim();

    return tasks.where((task) {
      if (normalizedQuery.isNotEmpty &&
          !task.title.toLowerCase().contains(normalizedQuery) &&
          !task.note.toLowerCase().contains(normalizedQuery)) {
        return false;
      }

      switch (_activeFilter) {
        case 'Today':
          return TaskMetrics.isSameDay(task.date, now);
        case 'High Priority':
          return task.priority == 'High';
        case 'AI Pick':
          return task.isAiPick;
        case 'Completed':
          return task.isCompleted;
        case 'All':
        default:
          return true;
      }
    }).toList();
  }

  Future<void> _toggleTask(TaskItem task) async {
    HapticFeedback.lightImpact();
    try {
      await _taskService.toggleTask(task.id, task.isCompleted);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Unable to update task.'))),
      );
    }
  }

  void _editTask(TaskItem task) {
    HapticFeedback.selectionClick();
    Navigator.pushNamed(context, '/add-task', arguments: task);
  }

  Future<bool> _confirmDismiss(TaskItem task) async {
    HapticFeedback.mediumImpact();
    await _taskService.deleteTask(task.id);
    if (!mounted) {
      return true;
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('Task deleted.')),
        action: SnackBarAction(
          label: tr('Undo'),
          onPressed: () => _restoreTask(task),
        ),
      ),
    );
    return true;
  }

  Future<void> _confirmAndDelete(TaskItem task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('Delete task?')),
        content: Text(
          tr('"{title}" will be permanently removed.',
              namedArgs: {'title': task.title}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr('Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(tr('Delete')),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    HapticFeedback.mediumImpact();
    try {
      await _taskService.deleteTask(task.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('Task deleted.')),
          action: SnackBarAction(
            label: tr('Undo'),
            onPressed: () => _restoreTask(task),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Unable to delete task.'))),
      );
    }
  }

  Future<void> _restoreTask(TaskItem task) async {
    try {
      await _taskService.addTask(
        title: task.title,
        priority: task.priority,
        category: task.category,
        date: task.date,
        durationMinutes: task.durationMinutes,
        note: task.note,
        isAiPick: task.isAiPick,
      );
    } catch (_) {
      // Silently fail — task was already deleted, best-effort restore.
    }
  }
}
