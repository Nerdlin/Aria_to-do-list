import 'package:flutter/material.dart';
import '../services/task_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final TaskService _taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Analytics', style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 24, fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: StreamBuilder<List<TaskItem>>(
        stream: _taskService.getTasksStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF7B61FF)));
          }

          final tasks = snapshot.data!;
          final completedTasks = tasks.where((t) => t.isCompleted).length;
          final totalTasks = tasks.length;
          final score = totalTasks == 0 ? 0 : ((completedTasks / totalTasks) * 100).round();
          
          // Estimate Focus Hours based on 1 hour per completed task
          final focusHours = completedTasks;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildStatCard('Score', '$score%', 'Based on completed tasks'),
              const SizedBox(height: 16),
              _buildStatCard('Tasks Completed', '$completedTasks', 'Out of $totalTasks total tasks'),
              const SizedBox(height: 16),
              _buildStatCard('Focus Hours', '${focusHours}h', 'Avg. 1h per task'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF6B7280))),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
        ],
      ),
    );
  }
}
