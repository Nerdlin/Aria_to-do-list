import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/task_service.dart';
import '../utils/app_colors.dart';
import '../utils/translations.dart';

/// A beautiful Pomodoro-style focus timer presented as a bottom sheet.
///
/// If a [task] is provided, its [durationMinutes] is used; otherwise the
/// timer defaults to the classic 25-minute Pomodoro session.
class FocusTimerSheet extends StatefulWidget {
  const FocusTimerSheet({super.key, this.task});

  final TaskItem? task;

  static Future<void> show(BuildContext context, {TaskItem? task}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FocusTimerSheet(task: task),
    );
  }

  @override
  State<FocusTimerSheet> createState() => _FocusTimerSheetState();
}

class _FocusTimerSheetState extends State<FocusTimerSheet>
    with SingleTickerProviderStateMixin {
  late final int _totalSeconds;
  late final AnimationController _controller;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    final minutes = widget.task?.durationMinutes ?? 25;
    _totalSeconds = minutes * 60;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _totalSeconds),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        HapticFeedback.heavyImpact();
        setState(() => _isRunning = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_isRunning) {
        _controller.stop();
      } else {
        if (_controller.value == 1.0) {
          _controller.reset();
        }
        _controller.forward(from: _controller.value);
      }
      _isRunning = !_isRunning;
    });
  }

  void _resetTimer() {
    HapticFeedback.mediumImpact();
    setState(() {
      _controller.reset();
      _isRunning = false;
    });
  }

  String _formatTime(int totalSecondsRemaining) {
    final minutes = (totalSecondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSecondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF1E1B4B), Color(0xFF0F172A)]
              : const [Color(0xFFF5F3FF), Colors.white],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle ──
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ── Title ──
              Text(
                tr('Focus Timer'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color:
                      isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              if (widget.task != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.task!.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? const Color(0xFFC4B5FD)
                        : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 36),

              // ── Timer Ring ──
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final remaining =
                      (_totalSeconds * (1 - _controller.value)).ceil();
                  final progress = _controller.value;

                  return Column(
                    children: [
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: CustomPaint(
                          painter: _TimerRingPainter(
                            progress: progress,
                            isDark: isDark,
                            isComplete: _controller.value == 1.0,
                          ),
                          child: Center(
                            child: Text(
                              _controller.value == 1.0
                                  ? tr('Done!')
                                  : _formatTime(remaining),
                              style: TextStyle(
                                fontSize: _controller.value == 1.0 ? 32 : 48,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1A2E),
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tr('{min} min session', namedArgs: {
                          'min': (_totalSeconds ~/ 60).toString(),
                        }),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.55)
                              : AppColors.textBody,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),

              // ── Controls ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset
                  _ControlButton(
                    icon: Icons.refresh_rounded,
                    label: tr('Reset'),
                    onTap: _resetTimer,
                    isDark: isDark,
                    isPrimary: false,
                  ),
                  const SizedBox(width: 24),
                  // Play / Pause
                  _ControlButton(
                    icon: _isRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    label: _isRunning ? tr('Pause') : tr('Start'),
                    onTap: _toggleTimer,
                    isDark: isDark,
                    isPrimary: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Control Button ──────────────────────────────────────────────────────

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    required this.isPrimary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(99),
          child: Container(
            width: isPrimary ? 72 : 56,
            height: isPrimary ? 72 : 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPrimary
                  ? AppColors.primary
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.lightBackground),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: isPrimary ? 32 : 24,
              color: isPrimary
                  ? Colors.white
                  : (isDark ? Colors.white : AppColors.textDark),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? Colors.white.withValues(alpha: 0.65)
                : AppColors.textBody,
          ),
        ),
      ],
    );
  }
}

// ── Ring Painter ─────────────────────────────────────────────────────────

class _TimerRingPainter extends CustomPainter {
  _TimerRingPainter({
    required this.progress,
    required this.isDark,
    required this.isComplete,
  });

  final double progress;
  final bool isDark;
  final bool isComplete;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 8.0;

    // Track
    final trackPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : AppColors.primary.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: isComplete
              ? const [AppColors.success, AppColors.success]
              : const [AppColors.accent, AppColors.primary],
        ).createShader(
          Rect.fromCircle(center: center, radius: radius),
        );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }

    // Dot at progress tip
    if (progress > 0 && progress < 1.0) {
      final angle = -math.pi / 2 + 2 * math.pi * progress;
      final dotCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final dotPaint = Paint()..color = AppColors.primary;
      canvas.drawCircle(dotCenter, 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isComplete != isComplete;
  }
}
