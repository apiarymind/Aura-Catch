import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/localization_provider.dart';
import '../../services/auth_service.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(subscriptionProvider);
    final isPro = plan == AccountPlan.pro;
    final user = ref.watch(authServiceProvider).currentUser;
    final requiresLogin = user == null || user.isAnonymous;
    final strings = ref.watch(localizationProvider);

    void handleUpgrade() {
      if (requiresLogin) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(strings.loginRequired),
            content: Text(strings.loginRegister),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(strings.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/login');
                },
                child: Text(strings.login),
              ),
            ],
          ),
        );
        return;
      }

      ref.read(subscriptionProvider.notifier).upgradeToPro();
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.premium)),
      body: isPro 
      ? Center(child: Text(strings.youArePro, style: const TextStyle(fontSize: 24)))
      : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(strings.unlockPro, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(strings.proFeatures, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: handleUpgrade,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: Text(strings.subscribeMonthly),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: handleUpgrade,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: Text(strings.subscribeYearly),
            ),
          ],
        ),
      ),
    );
  }
}
