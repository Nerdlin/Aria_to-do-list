import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

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
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildStatCard('Weekly Score', '87%', '+12% vs last week'),
          const SizedBox(height: 16),
          _buildStatCard('Tasks Completed', '65', '+8 this week'),
          const SizedBox(height: 16),
          _buildStatCard('Focus Hours', '29h', 'Peak: 9:00–11:00'),
        ],
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
