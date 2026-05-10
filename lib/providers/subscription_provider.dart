import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AccountPlan { free, pro }

class SubscriptionNotifier extends Notifier<AccountPlan> {
  @override
  AccountPlan build() {
    return AccountPlan.free;
  }

  void upgradeToPro() {
    state = AccountPlan.pro;
  }

  bool get isPro => state == AccountPlan.pro;
  
  // Free account limits
  int get maxTrackedItems => isPro ? 9999 : 3;
  int get searchExpirationDays => isPro ? 365 : 7;
}

final subscriptionProvider = NotifierProvider<SubscriptionNotifier, AccountPlan>(() {
  return SubscriptionNotifier();
});
