import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

enum SubscriptionTier { free, pro, business }

class SubscriptionPlan {
  const SubscriptionPlan({
    required this.tier,
    required this.name,
    required this.priceLabel,
    required this.monthlyPrice,
    required this.taskLimit,
    required this.aiDailyLimit,
    required this.features,
    required this.hasPriorityAi,
    required this.hasSmartNotifications,
    required this.hasAdvancedAnalytics,
    required this.hasBusinessTools,
  });

  final SubscriptionTier tier;
  final String name;
  final String priceLabel;
  final double monthlyPrice;
  final int taskLimit;
  final int aiDailyLimit;
  final List<String> features;
  final bool hasPriorityAi;
  final bool hasSmartNotifications;
  final bool hasAdvancedAnalytics;
  final bool hasBusinessTools;

  bool get isFree => tier == SubscriptionTier.free;
}

class PlanGateResult {
  const PlanGateResult({
    required this.allowed,
    required this.messageKey,
    this.namedArgs = const <String, String>{},
  });

  final bool allowed;
  final String messageKey;
  final Map<String, String> namedArgs;
}

class AiUsageSnapshot {
  const AiUsageSnapshot({
    required this.plan,
    required this.usedToday,
  });

  final SubscriptionPlan plan;
  final int usedToday;

  int get remainingToday {
    return (plan.aiDailyLimit - usedToday).clamp(0, plan.aiDailyLimit).toInt();
  }

  bool get canUseAi => remainingToday > 0;
}

class SubscriptionService {
  SubscriptionService._();

  static final SubscriptionService instance = SubscriptionService._();

  static const List<SubscriptionPlan> plans = [
    SubscriptionPlan(
      tier: SubscriptionTier.free,
      name: 'Free',
      priceLabel: '\$0',
      monthlyPrice: 0,
      taskLimit: 15,
      aiDailyLimit: 5,
      features: [
        '15 active tasks',
        '5 AI requests per day',
        'Basic analytics',
        'In-app reminders',
      ],
      hasPriorityAi: false,
      hasSmartNotifications: false,
      hasAdvancedAnalytics: false,
      hasBusinessTools: false,
    ),
    SubscriptionPlan(
      tier: SubscriptionTier.pro,
      name: 'Pro',
      priceLabel: '\$7.99',
      monthlyPrice: 7.99,
      taskLimit: 200,
      aiDailyLimit: 100,
      features: [
        '200 active tasks',
        '100 AI requests per day',
        'Priority analysis and task breakdown',
        'Smart AI notifications',
        'Advanced analytics',
      ],
      hasPriorityAi: true,
      hasSmartNotifications: true,
      hasAdvancedAnalytics: true,
      hasBusinessTools: false,
    ),
    SubscriptionPlan(
      tier: SubscriptionTier.business,
      name: 'Business',
      priceLabel: '\$19.99',
      monthlyPrice: 19.99,
      taskLimit: 1000,
      aiDailyLimit: 500,
      features: [
        '1000 active tasks',
        '500 AI requests per day',
        'Business-grade planning',
        'Team-ready reports',
        'Priority support',
      ],
      hasPriorityAi: true,
      hasSmartNotifications: true,
      hasAdvancedAnalytics: true,
      hasBusinessTools: true,
    ),
  ];

  SubscriptionPlan planForProfile(UserProfile? profile) {
    return planByName(profile?.planName ?? 'Free');
  }

  SubscriptionPlan planByName(String name) {
    return plans.firstWhere(
      (plan) => plan.name.toLowerCase() == name.toLowerCase(),
      orElse: () => plans.first,
    );
  }

  PlanGateResult canCreateTask(UserProfile? profile, int activeTaskCount) {
    final plan = planForProfile(profile);
    if (activeTaskCount < plan.taskLimit) {
      return const PlanGateResult(allowed: true, messageKey: '');
    }

    return PlanGateResult(
      allowed: false,
      messageKey:
          'Your {plan} plan allows up to {limit} active tasks. Upgrade to continue.',
      namedArgs: {
        'plan': plan.name,
        'limit': plan.taskLimit.toString(),
      },
    );
  }

  Future<AiUsageSnapshot> getAiUsage(UserProfile? profile) async {
    final plan = planForProfile(profile);
    final prefs = await SharedPreferences.getInstance();
    final key = _usageKey();
    final todayKey = _todayKey();
    final savedPeriod = prefs.getString('${key}_date');
    if (savedPeriod != todayKey) {
      await prefs.setString('${key}_date', todayKey);
      await prefs.setInt('${key}_count', 0);
      return AiUsageSnapshot(plan: plan, usedToday: 0);
    }

    return AiUsageSnapshot(
      plan: plan,
      usedToday: prefs.getInt('${key}_count') ?? 0,
    );
  }

  Future<PlanGateResult> consumeAiRequest(UserProfile? profile) async {
    final usage = await getAiUsage(profile);
    if (!usage.canUseAi) {
      return PlanGateResult(
        allowed: false,
        messageKey:
            'AI daily limit reached for {plan}. Upgrade or try again tomorrow.',
        namedArgs: {
          'plan': usage.plan.name,
        },
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final key = _usageKey();
    await prefs.setString('${key}_date', _todayKey());
    await prefs.setInt('${key}_count', usage.usedToday + 1);
    return const PlanGateResult(allowed: true, messageKey: '');
  }

  String _usageKey() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    return 'ai_usage_$uid';
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
