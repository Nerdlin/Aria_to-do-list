import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/ai_service.dart';
import '../services/app_controller.dart';
import '../services/subscription_service.dart';
import '../services/task_service.dart';
import '../utils/translations.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key, this.existingTask});

  final TaskItem? existingTask;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  TaskItem? get _existingTask =>
      widget.existingTask ??
      (ModalRoute.of(context)?.settings.arguments as TaskItem?);

  bool get _isEditing => _existingTask != null;
  bool _didPrefill = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TaskService _taskService = TaskService();
  final AiService _aiService = AiService();

  final List<String> _allSuggestions = const [
    'Review project roadmap',
    'Prepare client presentation',
    'Plan tomorrow focus block',
    'Clean up task backlog',
    'Reply to priority emails',
    'Book workout session',
    'Read 20 pages of your course',
    'Update monthly budget',
    'Refine onboarding checklist',
  ];

  final List<Map<String, dynamic>> _categories = const [
    {'icon': Icons.work_rounded, 'label': 'Work', 'color': Color(0xFF7C3AED)},
    {
      'icon': Icons.person_rounded,
      'label': 'Personal',
      'color': Color(0xFF3B82F6)
    },
    {
      'icon': Icons.favorite_rounded,
      'label': 'Health',
      'color': Color(0xFF10B981)
    },
    {
      'icon': Icons.school_rounded,
      'label': 'Learning',
      'color': Color(0xFFF59E0B)
    },
    {
      'icon': Icons.payments_rounded,
      'label': 'Finance',
      'color': Color(0xFFEF4444)
    },
    {
      'icon': Icons.brush_rounded,
      'label': 'Creative',
      'color': Color(0xFFEC4899)
    },
  ];

  final List<int> _durationOptions = const [25, 45, 60, 90];

  late List<String> _suggestions;

  String _selectedCategory = 'Work';
  String _selectedPriority = 'High';
  int _selectedDuration = 45;
  bool _isAiPick = true;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));

  @override
  void initState() {
    super.initState();
    _suggestions = _buildSuggestions();
    _titleController.addListener(_handleTitleChanged);

    // Pre-fill if we received an existing task via the constructor.
    final task = widget.existingTask;
    if (task != null) {
      _prefillFrom(task);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-fill if we received an existing task via route arguments.
    if (!_didPrefill) {
      final routeTask =
          ModalRoute.of(context)?.settings.arguments as TaskItem?;
      if (routeTask != null && widget.existingTask == null) {
        _prefillFrom(routeTask);
      }
      _didPrefill = true;
    }
  }

  void _prefillFrom(TaskItem task) {
    _titleController.text = task.title;
    _noteController.text = task.note;
    _selectedCategory = task.category;
    _selectedPriority = task.priority;
    _selectedDuration = task.durationMinutes;
    _isAiPick = task.isAiPick;
    _selectedDate = task.date;
  }

  @override
  void dispose() {
    _titleController.removeListener(_handleTitleChanged);
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleTitleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF111827) : Colors.white;
    final subduedBackground =
        isDark ? const Color(0xFF172033) : const Color(0xFFF8F7FF);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditing ? tr('Edit Task') : tr('New Task'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTask,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    tr('Save'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(
              context,
              title: tr('Task Details'),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    onChanged: (_) => setState(() {}),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: tr('Task title'),
                      prefixIcon: const Icon(Icons.flag_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: tr('Notes (optional)'),
                      alignLabelWithHint: true,
                      prefixIcon: const Icon(Icons.notes_rounded),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: tr('AI Suggestions'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_titleController.text.isNotEmpty)
                    TextButton.icon(
                      onPressed: _isLoading ? null : _analyzeTaskPriority,
                      icon: const Icon(Icons.psychology, size: 18),
                      label: Text(tr('Analyze')),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF7C3AED),
                      ),
                    ),
                  IconButton(
                    onPressed: () {
                      setState(() => _suggestions = _buildSuggestions());
                    },
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              child: Column(
                children: _suggestions
                    .map(
                      (suggestion) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () {
                            _titleController.text = suggestion;
                            setState(() {});
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: subduedBackground,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 16,
                                  color: Color(0xFF7C3AED),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    tr(suggestion),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: tr('Category'),
              child: GridView.builder(
                itemCount: _categories.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category['label'];
                  return InkWell(
                    onTap: () {
                      setState(() =>
                          _selectedCategory = category['label'] as String);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (category['color'] as Color)
                                .withValues(alpha: 0.14)
                            : subduedBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? (category['color'] as Color)
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category['icon'] as IconData,
                            color: category['color'] as Color,
                            size: 26,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tr(category['label'] as String),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: tr('Priority & Focus'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ['Low', 'Medium', 'High']
                        .map(
                          (priority) => ChoiceChip(
                            label: Text(tr(priority)),
                            selected: _selectedPriority == priority,
                            onSelected: (_) {
                              setState(() => _selectedPriority = priority);
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    tr('Estimated focus time'),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _durationOptions
                        .map(
                          (duration) => ChoiceChip(
                            label: Text('$duration ${tr('min')}'),
                            selected: _selectedDuration == duration,
                            onSelected: (_) {
                              setState(() => _selectedDuration = duration);
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: _isAiPick,
                    onChanged: (value) => setState(() => _isAiPick = value),
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      tr('Mark as AI recommended'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      tr('Helps Home and Analytics highlight this task.'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: tr('Schedule'),
              child: InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: subduedBackground,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.calendar_today_rounded,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEE, MMM d').format(_selectedDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('h:mm a').format(_selectedDate),
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.edit_outlined),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (time == null) {
      return;
    }

    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Please enter a task title.'))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final existingTask = _existingTask;

      if (existingTask != null) {
        // ── Edit mode ──
        await _taskService.updateTask(
          existingTask.id,
          title: _titleController.text.trim(),
          priority: _selectedPriority,
          category: _selectedCategory,
          date: _selectedDate,
          durationMinutes: _selectedDuration,
          note: _noteController.text.trim(),
          isAiPick: _isAiPick,
        );
      } else {
        // ── Create mode — apply plan gate ──
        final tasks = await _taskService.getTasksOnce();
        final activeTaskCount =
            tasks.where((task) => !task.isCompleted).length;
        final gate = SubscriptionService.instance.canCreateTask(
          AppController.instance.profile,
          activeTaskCount,
        );
        if (!gate.allowed) {
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tr(gate.messageKey, namedArgs: gate.namedArgs)),
              action: SnackBarAction(
                label: tr('Upgrade'),
                onPressed: () =>
                    Navigator.pushNamed(context, '/subscription'),
              ),
            ),
          );
          return;
        }

        await _taskService.addTask(
          title: _titleController.text.trim(),
          priority: _selectedPriority,
          category: _selectedCategory,
          date: _selectedDate,
          durationMinutes: _selectedDuration,
          note: _noteController.text.trim(),
          isAiPick: _isAiPick,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${tr('Error saving task')}: $error")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _analyzeTaskPriority() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final analysis = await _aiService.analyzeTaskPriority(
        title: title,
        category: _selectedCategory,
        dueDate: _selectedDate,
        note: _noteController.text.trim(),
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF7C3AED)),
              const SizedBox(width: 8),
              Text(tr('AI Analysis')),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              analysis,
              style: const TextStyle(height: 1.6),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('Close')),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Failed to analyze task'))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<String> _buildSuggestions() {
    final random = Random();
    final shuffled = [..._allSuggestions]..shuffle(random);
    return shuffled.take(3).toList();
  }
}
