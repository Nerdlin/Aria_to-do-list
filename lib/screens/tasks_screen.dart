import 'package:flutter/material.dart';
import '../services/task_service.dart';
import 'package:intl/intl.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskService _taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('My Tasks', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Color(0xFF1A1A2E))),
                        const SizedBox(height: 6),
                        const Text('Keep moving forward', style: TextStyle(color: Color(0xFF6B7280), fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 16),
                        Container(width: 80, height: 4, decoration: BoxDecoration(color: const Color(0xFF7B61FF), borderRadius: BorderRadius.circular(2))),
                      ],
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(color: const Color(0xFF7B61FF), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: const Color(0xFF7B61FF).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))]),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
                    )
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFF3F4F6), width: 1.5)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF7B61FF), width: 1.5)),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildFilterChip('All', true),
                    _buildFilterChip('Today', false),
                    _buildFilterChip('High Priority', false),
                    _buildFilterChip('✦ AI Pick', false, isAi: true),
                  ],
                ),
              ),
            ),
            StreamBuilder<List<TaskItem>>(
              stream: _taskService.getTasksStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text('No tasks today. Add some!', style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  );
                }

                final tasks = snapshot.data!;
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == tasks.length) return const SizedBox(height: 100); // padding for bottom nav
                      final task = tasks[index];
                      final formatter = DateFormat('hh:mm a');
                      return _buildTaskItem(task.title, task.priority, task.category, formatter.format(task.date), task.isCompleted, task.isAiPick, task.id);
                    },
                    childCount: tasks.length + 1,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive, {bool isAi = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF7B61FF) : (isAi ? Colors.white : const Color(0xFFF9FAFB)),
        borderRadius: BorderRadius.circular(99),
        border: isActive ? null : Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isActive ? Colors.white : (isAi ? const Color(0xFF7B61FF) : const Color(0xFF4B5563)))),
    );
  }

  Widget _buildTaskItem(String title, String priority, String category, String time, bool isCompleted, bool isAi, String taskId) {
    Color priorityColor;
    if (priority == 'High') priorityColor = const Color(0xFFEF4444);
    else if (priority == 'Medium') priorityColor = const Color(0xFFF59E0B);
    else priorityColor = const Color(0xFF10B981);

    return InkWell(
      onTap: () => _taskService.toggleTask(taskId, isCompleted),
      child: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
          boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(color: isCompleted ? const Color(0xFF7B61FF) : Colors.white, borderRadius: BorderRadius.circular(8), border: isCompleted ? null : Border.all(color: const Color(0xFFD1D5DB), width: 2)),
              child: isCompleted ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isCompleted ? const Color(0xFF9CA3AF) : const Color(0xFF1A1A2E), decoration: isCompleted ? TextDecoration.lineThrough : null)),
                      ),
                      if (isAi)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFF7B61FF).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Row(children: [Icon(Icons.auto_awesome_rounded, color: Color(0xFF7B61FF), size: 12), SizedBox(width: 4), Text('AI', style: TextStyle(color: Color(0xFF7B61FF), fontSize: 10, fontWeight: FontWeight.w800))]),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Row(children: [Icon(Icons.circle, size: 8, color: priorityColor), const SizedBox(width: 6), Text(priority, style: TextStyle(color: priorityColor, fontSize: 12, fontWeight: FontWeight.w800))]),
                      Container(width: 1, height: 12, color: const Color(0xFFE5E7EB), margin: const EdgeInsets.symmetric(horizontal: 8)),
                      Text(category, style: const TextStyle(color: Color(0xFF7B61FF), fontSize: 12, fontWeight: FontWeight.w700)),
                      Container(width: 1, height: 12, color: const Color(0xFFE5E7EB), margin: const EdgeInsets.symmetric(horizontal: 8)),
                      Text(time, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => _taskService.deleteTask(taskId),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
              ),
            )
          ],
        ),
      ),
    );
  }
}
