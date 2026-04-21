import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user_profile.dart';
import '../services/app_controller.dart';
import '../services/task_metrics.dart';
import '../services/task_service.dart';
import '../widgets/profile_avatar.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TaskService _taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppController.instance,
      builder: (context, _) {
        final profile = AppController.instance.profile;

        return StreamBuilder<List<TaskItem>>(
          stream: _taskService.getTasksStream(),
          builder: (context, snapshot) {
            final tasks = snapshot.data ?? const <TaskItem>[];
            final streak = TaskMetrics.calculateStreak(tasks);

            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                        child: Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            _ProfileCard(
                              profile: profile,
                              streak: streak,
                              onTap: () => _openProfileEditor(profile),
                            ),
                            const SizedBox(height: 12),
                            _SettingsSection(
                              title: 'AI FEATURES',
                              accentColor: const Color(0xFF8B5CF6),
                              children: [
                                _SettingRow(
                                  icon: Icons.auto_awesome_rounded,
                                  label: 'AI Auto-Planning',
                                  subtitle: 'Let Aria suggest your next move',
                                  color: const Color(0xFF8B5CF6),
                                  value: profile?.aiAutoPlanning ?? true,
                                  onChanged: (value) => AppController.instance
                                      .updatePreferences(aiAutoPlanning: value),
                                ),
                                _SettingRow(
                                  icon: Icons.bolt_rounded,
                                  label: 'Smart Prioritization',
                                  subtitle: 'Rank tasks by impact and urgency',
                                  color: const Color(0xFF6366F1),
                                  value: profile?.smartPrioritization ?? true,
                                  onChanged: (value) => AppController.instance
                                      .updatePreferences(smartPrioritization: value),
                                ),
                                _SettingRow(
                                  icon: Icons.access_time_rounded,
                                  label: 'Smart Reminders',
                                  subtitle: 'Keep nudges useful instead of noisy',
                                  color: const Color(0xFFF59E0B),
                                  value: profile?.smartReminders ?? true,
                                  onChanged: (value) => AppController.instance
                                      .updatePreferences(smartReminders: value),
                                ),
                                _SettingRow(
                                  icon: Icons.track_changes_rounded,
                                  label: 'AI Focus Mode',
                                  subtitle: 'Protect deep work sessions',
                                  color: const Color(0xFF10B981),
                                  value: profile?.focusMode ?? false,
                                  onChanged: (value) => AppController.instance
                                      .updatePreferences(focusMode: value),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _SettingsSection(
                              title: 'NOTIFICATIONS',
                              children: [
                                _SettingRow(
                                  icon: Icons.notifications_active_outlined,
                                  label: 'Push Notifications',
                                  subtitle: 'Task reminders and quick updates',
                                  color: const Color(0xFF60A5FA),
                                  value: profile?.pushNotifications ?? true,
                                  onChanged: (value) => AppController.instance
                                      .updatePreferences(pushNotifications: value),
                                ),
                                _SettingRow(
                                  icon: Icons.wb_sunny_outlined,
                                  label: 'Daily Digest',
                                  subtitle: 'Morning summary of your day',
                                  color: const Color(0xFF8B5CF6),
                                  value: profile?.dailyDigest ?? true,
                                  onChanged: (value) => AppController.instance
                                      .updatePreferences(dailyDigest: value),
                                ),
                                _SettingRow(
                                  icon: Icons.bar_chart_rounded,
                                  label: 'Weekly Report',
                                  subtitle: 'Progress snapshot every week',
                                  color: const Color(0xFF10B981),
                                  value: profile?.weeklyReport ?? true,
                                  onChanged: (value) => AppController.instance
                                      .updatePreferences(weeklyReport: value),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _SettingsSection(
                              title: 'APPEARANCE',
                              children: [
                                _SettingRow(
                                  icon: Icons.dark_mode_outlined,
                                  label: 'Dark Mode',
                                  subtitle: 'Switch instantly between light and dark',
                                  color: const Color(0xFF8B5CF6),
                                  value: AppController.instance.themeMode == ThemeMode.dark,
                                  onChanged: (value) => AppController.instance
                                      .updatePreferences(
                                    themeMode: value ? 'dark' : 'light',
                                  ),
                                ),
                                _SettingRow(
                                  icon: Icons.palette_outlined,
                                  label: 'App Theme',
                                  subtitle: _themeLabel(AppController.instance.themeMode),
                                  color: const Color(0xFF8B5CF6),
                                  onTap: _showThemePicker,
                                ),
                                _SettingRow(
                                  icon: Icons.language_rounded,
                                  label: 'Language',
                                  subtitle: _languageLabel(profile?.languageCode ?? 'en'),
                                  color: const Color(0xFF10B981),
                                  onTap: _showLanguagePicker,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _SettingsSection(
                              title: 'ACCOUNT',
                              children: [
                                _SettingRow(
                                  icon: Icons.person_outline_rounded,
                                  label: 'Profile & Account',
                                  subtitle: 'Update your name, photo, and email',
                                  color: const Color(0xFF64748B),
                                  onTap: () => _openProfileEditor(profile),
                                ),
                                _SettingRow(
                                  icon: Icons.shield_outlined,
                                  label: 'Privacy & Security',
                                  subtitle: 'Password reset and account safety',
                                  color: const Color(0xFF10B981),
                                  onTap: () => _showSecuritySheet(profile),
                                ),
                                _SettingRow(
                                  icon: Icons.workspace_premium_outlined,
                                  label: 'Subscription',
                                  subtitle: '${profile?.planName ?? 'Pro'} plan details',
                                  color: const Color(0xFFF59E0B),
                                  onTap: _showSubscriptionSheet,
                                ),
                                _SettingRow(
                                  icon: Icons.help_outline_rounded,
                                  label: 'Help & Support',
                                  subtitle: 'FAQ, support email, and feedback',
                                  color: const Color(0xFF60A5FA),
                                  onTap: _showHelpSheet,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () async {
                                await AppController.instance.signOut();
                                if (!context.mounted) {
                                  return;
                                }
                                Navigator.of(context).pushReplacementNamed('/auth');
                              },
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFFECACA),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.logout_rounded,
                                      color: Color(0xFFEF4444),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Sign Out',
                                      style: TextStyle(
                                        color: Color(0xFFEF4444),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                'Aria v2.4.1',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.45),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openProfileEditor(UserProfile? profile) async {
    if (profile == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(profile: profile),
      ),
    );
  }

  Future<void> _showThemePicker() async {
    await _showOptionsSheet(
      title: 'Choose theme',
      options: [
        _OptionItem(
          title: 'Light',
          subtitle: 'Bright interface for daytime work',
          onTap: () => AppController.instance.updatePreferences(themeMode: 'light'),
        ),
        _OptionItem(
          title: 'Dark',
          subtitle: 'Lower glare for late sessions',
          onTap: () => AppController.instance.updatePreferences(themeMode: 'dark'),
        ),
        _OptionItem(
          title: 'System',
          subtitle: 'Follow your device appearance',
          onTap: () => AppController.instance.updatePreferences(themeMode: 'system'),
        ),
      ],
    );
  }

  Future<void> _showLanguagePicker() async {
    await _showOptionsSheet(
      title: 'Choose language',
      options: [
        _OptionItem(
          title: 'English',
          subtitle: 'Current UI language',
          onTap: () => AppController.instance.updatePreferences(languageCode: 'en'),
        ),
        _OptionItem(
          title: 'Russian',
          subtitle: 'Store your preference for future localization',
          onTap: () => AppController.instance.updatePreferences(languageCode: 'ru'),
        ),
      ],
    );
  }

  Future<void> _showSecuritySheet(UserProfile? profile) async {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Privacy & Security',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              Text(
                'Signed in as ${profile?.email ?? FirebaseAuth.instance.currentUser?.email ?? 'unknown email'}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  final email = FirebaseAuth.instance.currentUser?.email;
                  if (email == null || email.isEmpty) {
                    return;
                  }
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(this.context);
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  if (!context.mounted) {
                    return;
                  }
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(content: Text('Password reset email sent to $email.')),
                  );
                },
                icon: const Icon(Icons.lock_reset_rounded),
                label: const Text('Send password reset email'),
              ),
              const SizedBox(height: 12),
              Text(
                'Your personal data and task collection are scoped to your account in Firestore.',
                style: TextStyle(
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.68),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSubscriptionSheet() async {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Subscription',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 14),
              Text(
                'Aria Pro is currently represented as an in-app profile tier. Billing is not wired to a payment provider in this project yet, but the settings page now opens plan details instead of doing nothing.',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showHelpSheet() async {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Help & Support',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              const _SupportRow(
                title: 'FAQ',
                subtitle: 'Tap profile photo to edit your account. Tap tasks to complete them.',
              ),
              const SizedBox(height: 10),
              _SupportRow(
                title: 'Support email',
                subtitle: 'support@aria.app',
                actionLabel: 'Copy',
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(this.context);
                  await Clipboard.setData(
                    const ClipboardData(text: 'support@aria.app'),
                  );
                  if (!context.mounted) {
                    return;
                  }
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Support email copied.')),
                  );
                },
              ),
              const SizedBox(height: 10),
              const _SupportRow(
                title: 'Feedback',
                subtitle: 'Use your task notes or profile editor to capture feedback for now.',
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showOptionsSheet({
    required String title,
    required List<_OptionItem> options,
  }) async {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              ...options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () async {
                      final navigator = Navigator.of(context);
                      await option.onTap();
                      if (!context.mounted) {
                        return;
                      }
                      navigator.pop();
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF172033)
                            : const Color(0xFFF8F7FF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(option.subtitle),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _themeLabel(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
    }
  }

  String _languageLabel(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return 'Russian';
      case 'en':
      default:
        return 'English';
    }
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.profile,
    required this.streak,
    required this.onTap,
  });

  final UserProfile? profile;
  final int streak;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final safeProfile = profile;

    return InkWell(
      onTap: safeProfile == null ? null : onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            ProfileAvatar(
              displayName: safeProfile?.displayName ?? 'Aria User',
              avatarSeed: safeProfile?.avatarSeed ?? 0,
              imagePath: safeProfile?.localAvatarPath,
              size: 58,
              fontSize: 24,
              borderRadius: 20,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    safeProfile?.displayName ?? 'Aria User',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    safeProfile?.email ?? 'No email available',
                    style: const TextStyle(
                      color: Color(0xD9FFFFFF),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ProfileBadge(label: '${safeProfile?.planName ?? 'Pro'} Plan'),
                      _ProfileBadge(label: '$streak-day streak'),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xB3FFFFFF)),
          ],
        ),
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
    this.accentColor,
  });

  final String title;
  final List<Widget> children;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.9,
                color: accentColor ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.value,
    this.onChanged,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (onChanged != null && value != null)
              Switch.adaptive(
                value: value!,
                activeTrackColor: const Color(0xFF7C3AED),
                onChanged: onChanged,
              )
            else
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}

class _SupportRow extends StatelessWidget {
  const _SupportRow({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF172033)
            : const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onTap, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class _OptionItem {
  const _OptionItem({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Future<void> Function() onTap;
}

