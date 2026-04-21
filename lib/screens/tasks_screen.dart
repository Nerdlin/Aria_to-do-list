import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/task_metrics.dart';
import '../services/task_service.dart';

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
                          'My Tasks',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${TaskMetrics.completedCount(allTasks)} completed, ${allTasks.where((task) => !task.isCompleted).length} still in motion',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
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
                                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
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
                                    const Text(
                                      'Smart queue',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tap a task to mark it done. Delete the ones you no longer need.',
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: TextField(
                      onChanged: (value) {
                        setState(() => _searchQuery = value.toLowerCase());
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search tasks',
                        prefixIcon: Icon(Icons.search_rounded),
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
                            const Text(
                              'No tasks match this filter.',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try another filter or create a new task from the center button.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
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
                          child: _buildTaskCard(context, task),
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

  Widget _buildFilterChip(String label) {
    final isActive = _activeFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: isActive,
        onSelected: (_) => setState(() => _activeFilter = label),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskItem task) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final priorityColor = _priorityColor(task.priority);
    final isOverdue = !task.isCompleted && task.date.isBefore(DateTime.now());

    return InkWell(
      onTap: () => _taskService.toggleTask(task.id, task.isCompleted),
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
                color: task.isCompleted ? const Color(0xFF7C3AED) : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
                border: task.isCompleted
                    ? null
                    : Border.all(color: theme.colorScheme.outline, width: 2),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 19)
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
                                ? theme.colorScheme.onSurface.withValues(alpha: 0.45)
                                : theme.colorScheme.onSurface,
                            decoration:
                                task.isCompleted ? TextDecoration.lineThrough : null,
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
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 12,
                                color: Color(0xFF7C3AED),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'AI',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF7C3AED),
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
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
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
                        color: _categoryColor(task.category),
                      ),
                      _buildMetaPill(
                        context,
                        label: DateFormat('EEE, h:mm a').format(task.date),
                        color: const Color(0xFF3B82F6),
                      ),
                      _buildMetaPill(
                        context,
                        label: '${task.durationMinutes} min',
                        color: const Color(0xFF10B981),
                      ),
                      if (isOverdue)
                        _buildMetaPill(
                          context,
                          label: 'Overdue',
                          color: const Color(0xFFEF4444),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => _taskService.deleteTask(task.id),
              icon: const Icon(Icons.delete_outline_rounded),
              color: const Color(0xFFEF4444),
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
        color: isDark ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
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

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFEF4444);
      case 'Low':
        return const Color(0xFF10B981);
      case 'Medium':
      default:
        return const Color(0xFFF59E0B);
    }
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

