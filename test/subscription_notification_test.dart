import 'package:aria_productivity_app/models/user_profile.dart';
import 'package:aria_productivity_app/services/notification_service.dart';
import 'package:aria_productivity_app/services/subscription_service.dart';
import 'package:aria_productivity_app/services/task_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubscriptionService', () {
    test('free plan blocks task creation at the active task limit', () {
      final result = SubscriptionService.instance.canCreateTask(
        _profile(planName: 'Free'),
        15,
      );

      expect(result.allowed, isFalse);
      expect(result.namedArgs['plan'], 'Free');
      expect(result.namedArgs['limit'], '15');
    });

    test('higher plans unlock larger limits and business tools', () {
      final proResult = SubscriptionService.instance.canCreateTask(
        _profile(planName: 'Pro'),
        15,
      );
      final business = SubscriptionService.instance
          .planForProfile(_profile(planName: 'Business'));

      expect(proResult.allowed, isTrue);
      expect(business.aiDailyLimit, 500);
      expect(business.hasBusinessTools, isTrue);
    });
  });

  group('AppNotificationService', () {
    test('smart AI notification is gated by subscription plan', () {
      final tasks = [_task(title: 'Launch plan', priority: 'High')];

      final freeNotifications = AppNotificationService.buildNotifications(
        tasks: tasks,
        profile: _profile(planName: 'Free'),
      );
      final proNotifications = AppNotificationService.buildNotifications(
        tasks: tasks,
        profile: _profile(planName: 'Pro'),
      );

      expect(
        freeNotifications.any(
          (notification) => notification.type == AppNotificationType.ai,
        ),
        isFalse,
      );
      expect(
        proNotifications.any(
          (notification) => notification.type == AppNotificationType.ai,
        ),
        isTrue,
      );
    });
  });
}

UserProfile _profile({required String planName}) {
  return UserProfile(
    uid: 'test-user',
    displayName: 'Test User',
    email: 'test@example.com',
    themeModeName: 'dark',
    languageCode: 'en',
    aiAutoPlanning: true,
    smartPrioritization: true,
    smartReminders: true,
    focusMode: false,
    pushNotifications: true,
    dailyDigest: true,
    weeklyReport: true,
    planName: planName,
    avatarSeed: 1,
    subscriptionStatus: planName == 'Free' ? 'free' : 'active',
  );
}

TaskItem _task({
  required String title,
  required String priority,
}) {
  final now = DateTime.now().add(const Duration(hours: 1));
  return TaskItem(
    id: title,
    title: title,
    priority: priority,
    category: 'Work',
    date: now,
    durationMinutes: 45,
    isCompleted: false,
    isAiPick: false,
    createdAt: now,
  );
}
