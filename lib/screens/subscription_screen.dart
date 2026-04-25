import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import '../services/subscription_service.dart';
import '../utils/translations.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: AppController.instance,
      builder: (context, _) {
        final profile = AppController.instance.profile;
        final currentPlan =
            SubscriptionService.instance.planForProfile(profile);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              tr('Subscription'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              _CurrentPlanBanner(
                plan: currentPlan,
                renewsAt: profile?.subscriptionRenewsAt,
                receiptId: profile?.subscriptionReceiptId,
              ),
              const SizedBox(height: 16),
              ...SubscriptionService.plans.map(
                (plan) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _PlanCard(
                    plan: plan,
                    currentPlan: currentPlan,
                    onSelect: () => _showCheckout(context, plan, currentPlan),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCheckout(
    BuildContext context,
    SubscriptionPlan plan,
    SubscriptionPlan currentPlan,
  ) async {
    if (plan.name == currentPlan.name) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('This plan is already active.'))),
      );
      return;
    }

    final confirmed = await showModalBottomSheet<bool>(
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
                plan.isFree ? tr('Switch plan') : tr('Checkout'),
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                plan.isFree
                    ? tr(
                        'Switching to Free will apply Free limits immediately.')
                    : tr(
                        'You are buying {plan} for {price}/month.',
                        namedArgs: {
                          'plan': plan.name,
                          'price': plan.priceLabel,
                        },
                      ),
                style: TextStyle(
                  height: 1.45,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF172033)
                      : const Color(0xFFF8F7FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  tr('MVP checkout: plan is saved to your Firebase profile and feature gates update immediately. Connect Stripe or Play Billing for real money capture.'),
                  style: const TextStyle(height: 1.45),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(tr('Cancel')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(plan.isFree ? tr('Switch') : tr('Buy')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await AppController.instance.updateSubscription(plan.name);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr(
            '{plan} is active now.',
            namedArgs: {'plan': plan.name},
          ),
        ),
      ),
    );
  }
}

class _CurrentPlanBanner extends StatelessWidget {
  const _CurrentPlanBanner({
    required this.plan,
    required this.renewsAt,
    required this.receiptId,
  });

  final SubscriptionPlan plan;
  final DateTime? renewsAt;
  final String? receiptId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Current plan'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plan.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            renewsAt == null
                ? tr('No paid renewal scheduled.')
                : tr(
                    'Renews on {date}.',
                    namedArgs: {
                      'date':
                          '${renewsAt!.year}-${renewsAt!.month.toString().padLeft(2, '0')}-${renewsAt!.day.toString().padLeft(2, '0')}',
                    },
                  ),
            style: const TextStyle(color: Colors.white, height: 1.4),
          ),
          if (receiptId != null) ...[
            const SizedBox(height: 8),
            Text(
              tr('Receipt: {id}', namedArgs: {'id': receiptId!}),
              style: TextStyle(
                color: isDark ? const Color(0xFFE0F2FE) : Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.currentPlan,
    required this.onSelect,
  });

  final SubscriptionPlan plan;
  final SubscriptionPlan currentPlan;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final active = plan.name == currentPlan.name;
    final accent = plan.tier == SubscriptionTier.business
        ? const Color(0xFF06B6D4)
        : const Color(0xFF7C3AED);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: active ? accent : theme.dividerColor,
          width: active ? 1.6 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (active)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tr('Active'),
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            plan.isFree
                ? tr('Forever')
                : tr('{price}/month', namedArgs: {'price': plan.priceLabel}),
            style: TextStyle(
              color: accent,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ...plan.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: accent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(tr(feature))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSelect,
              style: FilledButton.styleFrom(backgroundColor: accent),
              child: Text(
                active
                    ? tr('Current')
                    : plan.isFree
                        ? tr('Switch to Free')
                        : tr('Buy {plan}', namedArgs: {'plan': plan.name}),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
