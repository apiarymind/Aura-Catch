import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AccountPlan { free, pro }

class SubscriptionNotifier extends Notifier<AccountPlan> {
  static const String _defaultEntitlementId = 'pro';
  bool _isConfigured = false;
  bool _isRevenueCatEnabled = false;

  @override
  AccountPlan build() {
    Future.microtask(syncFromRevenueCat);
    return AccountPlan.free;
  }

  String _resolveEntitlementId() {
    final envValue = dotenv.env['REVENUECAT_ENTITLEMENT_ID']?.trim();
    if (envValue != null && envValue.isNotEmpty) {
      return envValue;
    }
    return _defaultEntitlementId;
  }

  String? _resolveRevenueCatApiKey() {
    if (kIsWeb) {
      return null;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return dotenv.env['REVENUECAT_IOS_API_KEY'];
      case TargetPlatform.android:
        return dotenv.env['REVENUECAT_ANDROID_API_KEY'];
      default:
        return null;
    }
  }

  Future<void> _ensureConfigured() async {
    if (_isConfigured) {
      return;
    }

    final apiKey = _resolveRevenueCatApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('RevenueCat not configured: missing platform API key');
      _isConfigured = true;
      _isRevenueCatEnabled = false;
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    final config = PurchasesConfiguration(apiKey)
      ..appUserID = userId;

    await Purchases.configure(config);
    _isConfigured = true;
    _isRevenueCatEnabled = true;
  }

  AccountPlan _planFromCustomerInfo(CustomerInfo info) {
    final entitlementId = _resolveEntitlementId();
    final entitlement = info.entitlements.active[entitlementId];
    return entitlement == null ? AccountPlan.free : AccountPlan.pro;
  }

  Future<void> _syncPlanToSupabase(AccountPlan plan) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      return;
    }

    final activePlan = plan == AccountPlan.pro ? 'PRO' : 'FREE';
    await Supabase.instance.client.from('users').upsert({
      'id': userId,
      'active_plan': activePlan,
    });
  }

  Future<void> syncFromRevenueCat() async {
    await _ensureConfigured();
    if (!_isRevenueCatEnabled || kIsWeb) {
      state = AccountPlan.free;
      return;
    }

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final resolved = _planFromCustomerInfo(customerInfo);
      if (state != resolved) {
        state = resolved;
      }
      await _syncPlanToSupabase(resolved);
    } catch (e) {
      debugPrint('Failed to sync RevenueCat entitlement: $e');
      state = AccountPlan.free;
    }
  }

  Future<Offering?> getCurrentOffering() async {
    await _ensureConfigured();
    if (!_isRevenueCatEnabled || kIsWeb) {
      return null;
    }

    final offerings = await Purchases.getOfferings();
    return offerings.current;
  }

  Package? monthlyPackageFromOffering(Offering? offering) {
    if (offering == null) {
      return null;
    }

    final packages = offering.availablePackages;
    for (final pkg in packages) {
      final id = pkg.identifier.toLowerCase();
      final productId = pkg.storeProduct.identifier.toLowerCase();
      if (id.contains('month') || id.contains('monthly') || productId.contains('month')) {
        return pkg;
      }
    }

    return packages.isNotEmpty ? packages.first : null;
  }

  Package? yearlyPackageFromOffering(Offering? offering) {
    if (offering == null) {
      return null;
    }

    final packages = offering.availablePackages;
    for (final pkg in packages) {
      final id = pkg.identifier.toLowerCase();
      final productId = pkg.storeProduct.identifier.toLowerCase();
      if (id.contains('year') || id.contains('annual') || productId.contains('year')) {
        return pkg;
      }
    }

    if (packages.length > 1) {
      return packages[1];
    }
    return null;
  }

  Future<CustomerInfo?> purchasePackage(Package package) async {
    await _ensureConfigured();
    if (!_isRevenueCatEnabled || kIsWeb) {
      return null;
    }

    final info = await Purchases.purchasePackage(package);
    final resolved = _planFromCustomerInfo(info);
    state = resolved;
    await _syncPlanToSupabase(resolved);
    return info;
  }

  Future<CustomerInfo?> restorePurchases() async {
    await _ensureConfigured();
    if (!_isRevenueCatEnabled || kIsWeb) {
      return null;
    }

    final info = await Purchases.restorePurchases();
    final resolved = _planFromCustomerInfo(info);
    state = resolved;
    await _syncPlanToSupabase(resolved);
    return info;
  }

  bool get isPro => state == AccountPlan.pro;
  
  // Free account limits
  int get maxTrackedItems => isPro ? 9999 : 3;
  int get searchExpirationDays => isPro ? 365 : 7;
}

final subscriptionProvider = NotifierProvider<SubscriptionNotifier, AccountPlan>(() {
  return SubscriptionNotifier();
});
