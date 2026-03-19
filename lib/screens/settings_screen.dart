import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 24, fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0EFFF),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('A', style: TextStyle(color: Color(0xFF7B61FF), fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Alex Johnson', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 4),
                  Text('${user?.email ?? 'alex@example.com'} · Pro Plan', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF6B7280))),
                ],
              )
            ],
          ),
          const SizedBox(height: 32),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 16),
          _buildToggle('AI Auto-Planning', 'Let AI schedule your day', true),
          _buildToggle('Push Notifications', null, true),
          _buildToggle('Smart Reminders', null, true),
          _buildToggle('Dark Mode', null, false),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/auth');
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                children: [
                  Icon(Icons.output_rounded, color: Color(0xFFEF4444)),
                  SizedBox(width: 16),
                  Text('Sign Out', style: TextStyle(color: Color(0xFFEF4444), fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildToggle(String title, String? subtitle, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF6B7280))),
              ]
            ],
          ),
          Switch(
            value: value,
            onChanged: (val) {},
            activeColor: const Color(0xFF7B61FF),
            activeTrackColor: const Color(0xFF7B61FF).withOpacity(0.2),
            inactiveThumbColor: const Color(0xFF9CA3AF),
            inactiveTrackColor: const Color(0xFFF3F4F6),
          )
        ],
      ),
    );
  }
}
