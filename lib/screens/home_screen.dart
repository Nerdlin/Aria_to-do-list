import 'package:flutter/material.dart';
import '../services/task_service.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskService taskService = TaskService();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Transform.translate(
              offset: const Offset(0, -60),
              child: Column(
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 32),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today's Schedule",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E), letterSpacing: -0.5),
                        ),
                        Text(
                          'View all >',
                          style: TextStyle(color: Color(0xFF7B61FF), fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildScheduleList(taskService),
                  const SizedBox(height: 80), // Padding for nav
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 90),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6F32FF), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Good morning', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
                      SizedBox(width: 4),
                      Icon(Icons.auto_awesome_rounded, color: Colors.white70, size: 16),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text('Alex Johnson', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
                        Positioned(top: 10, right: 12, child: CircleAvatar(backgroundColor: Color(0xFFFB923C), radius: 4))
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: const Color(0xFFF97316), borderRadius: BorderRadius.circular(16)),
                    alignment: Alignment.center,
                    child: const Text('A', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI INSIGHT', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      const Text(
                        "You're in your peak focus window. Start with the client deck — highest impact task today.",
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, height: 1.4),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatCard('Tasks Done', '7', '/12', const Color(0xFF7B61FF)),
          _buildStatCard('Focus Time', '4.2', 'h', const Color(0xFF3B82F6)),
          _buildStatCard('Streak', '14', 'd', const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String unit, Color highlightColor) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: highlightColor)),
              Text(unit, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _buildScheduleList(TaskService taskService) {
    return StreamBuilder<List<TaskItem>>(
      stream: taskService.getTasksStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          // Fallback UI to match Figma if no real tasks
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                _buildScheduleItem('9:00', '2h', 'Deep Work — Product', 'Work', const Color(0xFF7B61FF), true, Icons.check_rounded),
                const SizedBox(height: 16),
                _buildScheduleItem('11:00', '1h', 'Team Standup + Reviews', 'Work', const Color(0xFF3B82F6), false, Icons.play_arrow_rounded),
              ],
            ),
          );
        }

        final tasks = snapshot.data!.take(5).toList();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: tasks.map((task) {
              final formatter = DateFormat('HH:mm');
              final timeStr = formatter.format(task.date);

              Color color = const Color(0xFF3B82F6);
              if (task.category == 'Work') color = const Color(0xFF7B61FF);
              if (task.category == 'Personal') color = const Color(0xFFF59E0B);
              if (task.category == 'Health') color = const Color(0xFF10B981);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildScheduleItem(
                  timeStr,
                  '1h', // Placeholder
                  task.title,
                  task.category,
                  color,
                  task.isCompleted,
                  task.isCompleted ? Icons.check_rounded : Icons.bolt_rounded,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildScheduleItem(String time, String duration, String title, String tag, Color color, bool completed, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: completed ? const Color(0xFFF9FAFB) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: completed ? Border.all(color: const Color(0xFFF3F4F6)) : Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: completed ? [] : [BoxShadow(color: color.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: completed ? const Color(0xFF9CA3AF) : const Color(0xFF1A1A2E))),
                const SizedBox(height: 4),
                Text(duration, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
          Container(width: 3, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: completed ? const Color(0xFF9CA3AF) : const Color(0xFF1A1A2E), decoration: completed ? TextDecoration.lineThrough : null)),
                const SizedBox(height: 6),
                Text(tag, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: completed ? color.withOpacity(0.1) : Colors.white, border: completed ? null : Border.all(color: const Color(0xFFF3F4F6)), shape: BoxShape.circle),
            child: Icon(icon, color: completed ? color : color.withOpacity(0.8), size: 20),
          )
        ],
      ),
    );
  }
}
