import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user_profile.dart';
import '../services/app_controller.dart';
import '../utils/translations.dart';
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
    final theme = Theme.of(context);

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
                              title: tr('AI FEATURES'),
                              accentColor: const Color(0xFF8B5CF6),
                              children: [
                                _SettingRow(
                                  icon: Icons.auto_awesome_rounded,
                                  label: tr('AI Auto-Planning'),
                                  subtitle: tr('Let Aria suggest your next move'),
                                  color: const Color(0xFF8B5CF6),
                                  value: profile?.aiAutoPlanning ?? true,
                                  onChanged: (value) => AppController.instance
                                      .updatePreferences(aiAutoPlanning: value),
                                ),
                                _SettingRow(
                                  icon: Icons.psychology_rounded,
                                  label: tr('Smart Prioritization'),
                                  subtitle: tr('Rank tasks by impact and urgency'),
                                  color: const Color(0xFF6366F1),
                                  value: profile?.smartPrioritization ?? true,
                                  onChanged: (value) => AppController.instance
                                      .updatePreferences(smartPrioritization: value),
                                ),
                                _SettingRow(
                                  icon: Icons.access_time_rounded,
                                  label: tr('Smart Reminders'),
                                  subtitle: tr('Keep nudges useful instead of noisy'),
                                  color: const Color(0xFFF59E0B),
                                  value: profile?.smartReminders ?? true,
                                  onChanged: (value) => AppController.instance
                                      .updatePreferences(smartReminders: value),
                                ),
                                _SettingRow(
                                  icon: Icons.center_focus_strong_rounded,
                                  label: tr('AI Focus Mode'),
                                  subtitle: tr('Protect deep work sessions'),
                                  color: const Color(0xFF10B981),
                                  value: profile?.focusMode ?? false,
                                  onChanged: (value) => AppController.instance
                                      .updatePreferences(focusMode: value),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _SettingsSection(
                              title: tr('NOTIFICATIONS'),
                              children: [
                                _SettingRow(
                                  icon: Icons.notifications_active_rounded,
                                  label: tr('Push Notifications'),
                                  subtitle: tr('Task reminders and quick updates'),
                                  color: const Color(0xFF60A5FA),
                                  value: profile?.pushNotifications ?? true,
                                  onChanged: (value) => AppController.instance
                                      .updatePreferences(pushNotifications: value),
                                ),
                                _SettingRow(
                                  icon: Icons.mail_outline_rounded,
                                  label: tr('Daily Digest'),
                                  subtitle: tr('Morning summary of your day'),
                                  color: const Color(0xFF8B5CF6),
                                  value: profile?.dailyDigest ?? true,
                                  onChanged: (value) => AppController.instance
                                      .updatePreferences(dailyDigest: value),
                                ),
                                _SettingRow(
                                  icon: Icons.pie_chart_outline_rounded,
                                  label: tr('Weekly Report'),
                                  subtitle: tr('Progress snapshot every week'),
                                  color: const Color(0xFF10B981),
                                  value: profile?.weeklyReport ?? true,
                                  onChanged: (value) => AppController.instance
                                      .updatePreferences(weeklyReport: value),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _SettingsSection(
                              title: tr('APPEARANCE'),
                              children: [
                                _SettingRow(
                                  icon: Icons.palette_rounded,
                                  label: tr('Theme'),
                                  subtitle: _themeLabel(profile?.themeModeName ?? 'light'),
                                  color: const Color(0xFF8B5CF6),
                                  onTap: _showThemePicker,
                                ),
                                _SettingRow(
                                  icon: Icons.language_rounded,
                                  label: tr('Language'),
                                  subtitle: _languageLabel(profile?.languageCode ?? 'en'),
                                  color: const Color(0xFF10B981),
                                  onTap: _showLanguagePicker,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _SettingsSection(
                              title: tr('ACCOUNT'),
                              children: [
                                _SettingRow(
                                  icon: Icons.person_outline_rounded,
                                  label: tr('Profile & Account'),
                                  subtitle: tr('Update your name, photo, and email'),
                                  color: const Color(0xFF64748B),
                                  onTap: () => _openProfileEditor(profile),
                                ),
                                _SettingRow(
                                  icon: Icons.shield_outlined,
                                  label: tr('Privacy & Security'),
                                  subtitle: tr('Password reset and account safety'),
                                  color: const Color(0xFF10B981),
                                  onTap: () => _showSecuritySheet(profile),
                                ),
                                _SettingRow(
                                  icon: Icons.workspace_premium_outlined,
                                  label: tr('Subscription'),
                                  subtitle: tr('${profile?.planName ?? 'Pro'} plan details'),
                                  color: const Color(0xFFF59E0B),
                                  onTap: _showSubscriptionSheet,
                                ),
                                _SettingRow(
                                  icon: Icons.help_outline_rounded,
                                  label: tr('Help & Support'),
                                  subtitle: tr('FAQ, support email, and feedback'),
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
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFFECACA),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.logout_rounded,
                                      color: Color(0xFFEF4444),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      tr('Sign Out'),
                                      style: const TextStyle(
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
                                  color: theme
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
      title: tr('Choose theme'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(tr('Light')),
            onTap: () => AppController.instance.updatePreferences(themeMode: 'light'),
          ),
          ListTile(
            title: Text(tr('Dark')),
            onTap: () => AppController.instance.updatePreferences(themeMode: 'dark'),
          ),
          ListTile(
            title: Text(tr('System')),
            onTap: () => AppController.instance.updatePreferences(themeMode: 'system'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguagePicker() async {
    await _showOptionsSheet(
      title: tr('Choose language'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(tr('English')),
            subtitle: Text(tr('Current UI language')),
            onTap: () => AppController.instance.updatePreferences(languageCode: 'en'),
          ),
          ListTile(
            title: Text(tr('Russian')),
            onTap: () => AppController.instance.updatePreferences(languageCode: 'ru'),
          ),
        ],
      ),
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
              Text(
                tr('Privacy & Security'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              Text(
                tr('Signed in as {}', namedArgs: {'email': profile?.email ?? FirebaseAuth.instance.currentUser?.email ?? tr('unknown email')}),
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
                    SnackBar(content: Text(tr('Password reset email sent to {}', namedArgs: {'email': email}))),
                  );
                },
                icon: const Icon(Icons.lock_reset_rounded),
                label: Text(tr('Send password reset email')),
              ),
              const SizedBox(height: 12),
              Text(
                tr('Your personal data and task collection are scoped to your account in Firestore.'),
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
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('Subscription'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              Text(
                tr('Aria Pro is currently represented as an in-app profile tier. Billing is not wired to a payment provider in this project yet, but the settings page now opens plan details instead of doing nothing.'),
                style: const TextStyle(height: 1.5),
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
              Text(
                tr('Help & Support'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              _SupportRow(
                title: tr('FAQ'),
                subtitle: tr('Tap profile photo to edit your account. Tap tasks to complete them.'),
              ),
              const SizedBox(height: 10),
              _SupportRow(
                title: tr('Support email'),
                subtitle: 'support@aria.app',
                actionLabel: tr('Copy'),
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
                    SnackBar(content: Text(tr('Support email copied.'))),
                  );
                },
              ),
              const SizedBox(height: 10),
              _SupportRow(
                title: tr('Feedback'),
                subtitle: tr('Use your task notes or profile editor to capture feedback for now.'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showOptionsSheet({
    required String title,
    required Widget content,
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
              content,
            ],
          ),
        );
      },
    );
  }

  String _themeLabel(String themeModeName) {
    switch (themeModeName) {
      case 'dark':
        return tr('Dark');
      case 'system':
        return tr('System');
      case 'light':
      default:
        return tr('Light');
    }
  }

  String _languageLabel(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return tr('Russian');
      case 'en':
      default:
        return tr('English');
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
              displayName: safeProfile?.displayName ?? tr('Aria User'),
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
                    safeProfile?.displayName ?? tr('Aria User'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    safeProfile?.email ?? tr('No email available'),
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
                      _ProfileBadge(label: tr('{} Plan', namedArgs: {'plan': safeProfile?.planName ?? 'Pro'})),
                      _ProfileBadge(label: tr('{}-day streak', namedArgs: {'days': '$streak'})),
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

