import 'package:flutter/material.dart';

import '../services/ai_service.dart';
import '../services/app_controller.dart';
import '../services/subscription_service.dart';
import '../services/task_service.dart';
import '../utils/translations.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final AiService _aiService = AiService();
  final TaskService _taskService = TaskService();
  final TextEditingController _inputController = TextEditingController();

  bool _isLoading = false;
  String? _response;
  String _selectedMode = 'insights';

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('AI Assistant'),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr('Get smart insights and recommendations'),
                    style: TextStyle(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.64),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ModeSelector(
                selectedMode: _selectedMode,
                onChanged: (mode) => setState(() => _selectedMode = mode),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(
                  children: [
                    _buildAiStatusCard(isDark, theme),
                    const SizedBox(height: 16),
                    if (_response != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  tr('AI Recommendation'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _response!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_response != null) const SizedBox(height: 16),
                    _buildQuickActions(isDark, theme),
                    const SizedBox(height: 16),
                    _buildFeatureCards(isDark, theme),
                  ],
                ),
              ),
            ),
            if (_selectedMode == 'breakdown')
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111827) : Colors.white,
                  border: Border(
                    top: BorderSide(color: theme.dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        decoration: InputDecoration(
                          hintText: tr('Enter task title...'),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _isLoading ? null : _handleBreakdown,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Quick Actions'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _ActionButton(
            icon: Icons.insights,
            label: tr('Analyze My Productivity'),
            onTap: _isLoading ? null : _handleInsights,
            isLoading: _isLoading && _selectedMode == 'insights',
          ),
          const SizedBox(height: 8),
          _ActionButton(
            icon: Icons.schedule,
            label: tr('Suggest Optimal Schedule'),
            onTap: _isLoading ? null : _handleSchedule,
            isLoading: _isLoading && _selectedMode == 'schedule',
          ),
        ],
      ),
    );
  }

  Widget _buildAiStatusCard(bool isDark, ThemeData theme) {
    final profile = AppController.instance.profile;
    final plan = SubscriptionService.instance.planForProfile(profile);

    return FutureBuilder<AiUsageSnapshot>(
      future: SubscriptionService.instance.getAiUsage(profile),
      builder: (context, snapshot) {
        final usage = snapshot.data;
        final remaining = usage?.remainingToday ?? plan.aiDailyLimit;
        final configured = _aiService.isConfigured;
        final statusColor =
            configured ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111827) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  configured
                      ? Icons.cloud_done_outlined
                      : Icons.offline_bolt_outlined,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      configured ? tr('AI online') : tr('AI fallback mode'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr(
                        '{plan}: {left}/{limit} AI requests left today',
                        namedArgs: {
                          'plan': plan.name,
                          'left': remaining.toString(),
                          'limit': plan.aiDailyLimit.toString(),
                        },
                      ),
                      style: TextStyle(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.64),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureCards(bool isDark, ThemeData theme) {
    return Column(
      children: [
        _FeatureCard(
          icon: Icons.psychology,
          title: tr('Smart Prioritization'),
          description: tr(
              'AI analyzes your tasks and provides personalized recommendations.'),
          color: const Color(0xFF8B5CF6),
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.auto_graph,
          title: tr('Productivity Insights'),
          description:
              tr('Get personalized recommendations based on your patterns.'),
          color: const Color(0xFF10B981),
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.task_alt,
          title: tr('Task Breakdown'),
          description: tr('Break complex tasks into actionable steps.'),
          color: const Color(0xFF60A5FA),
          isDark: isDark,
        ),
      ],
    );
  }

  Future<void> _handleInsights() async {
    setState(() {
      _isLoading = true;
      _selectedMode = 'insights';
      _response = null;
    });

    try {
      final tasks = await _taskService.getTasksStream().first;
      final insights = await _aiService.generateProductivityInsights(tasks);
      if (!mounted) return;
      setState(() => _response = insights);
    } catch (e) {
      _showError(tr('Failed to generate insights'));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSchedule() async {
    setState(() {
      _isLoading = true;
      _selectedMode = 'schedule';
      _response = null;
    });

    try {
      final tasks = await _taskService.getTasksStream().first;
      final pending = tasks.where((t) => !t.isCompleted).toList();
      final schedule = await _aiService.suggestOptimalSchedule(pending);
      if (!mounted) return;
      setState(() => _response = schedule);
    } catch (e) {
      _showError(tr('Failed to generate schedule'));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBreakdown() async {
    final title = _inputController.text.trim();
    if (title.isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = null;
    });

    try {
      final breakdown = await _aiService.suggestTaskBreakdown(title);
      if (!mounted) return;
      setState(() => _response = breakdown);
      _inputController.clear();
    } catch (e) {
      _showError(tr('Failed to break down task'));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.selectedMode,
    required this.onChanged,
  });

  final String selectedMode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          _ModeButton(
            label: tr('Insights'),
            icon: Icons.lightbulb_outline,
            selected: selectedMode == 'insights',
            onTap: () => onChanged('insights'),
          ),
          _ModeButton(
            label: tr('Plan'),
            icon: Icons.calendar_today,
            selected: selectedMode == 'schedule',
            onTap: () => onChanged('schedule'),
          ),
          _ModeButton(
            label: tr('Steps'),
            icon: Icons.list_alt,
            selected: selectedMode == 'breakdown',
            onTap: () => onChanged('breakdown'),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.68);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 46,
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  )
                : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isLoading,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.64),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
