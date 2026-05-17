import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AccountPlan { free, pro }

class SubscriptionState {
  final AccountPlan plan;
  final DateTime? subscriptionExpiresAt;

  const SubscriptionState({
    required this.plan,
    required this.subscriptionExpiresAt,
  });

  const SubscriptionState.free()
      : plan = AccountPlan.free,
        subscriptionExpiresAt = null;

  bool get isPro => plan == AccountPlan.pro;

  SubscriptionState copyWith({
    AccountPlan? plan,
    DateTime? subscriptionExpiresAt,
    bool clearExpiration = false,
  }) {
    return SubscriptionState(
      plan: plan ?? this.plan,
      subscriptionExpiresAt: clearExpiration
          ? null
          : subscriptionExpiresAt ?? this.subscriptionExpiresAt,
    );
  }
}

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  static const String _defaultEntitlementId = 'pro';
  bool _isConfigured = false;
  bool _isRevenueCatEnabled = false;
  StreamSubscription<AuthState>? _authSubscription;
  RealtimeChannel? _usersRealtimeChannel;

  @override
  SubscriptionState build() {
    ref.onDispose(_dispose);
    Future.microtask(_initialize);
    return const SubscriptionState.free();
  }

  Future<void> _initialize() async {
    await _syncFromSupabaseProfile();
    await _subscribeToUserRealtime();
    _listenToAuthChanges();
    unawaited(syncFromRevenueCat());
  }

  void _dispose() {
    _authSubscription?.cancel();
    _usersRealtimeChannel?.unsubscribe();
  }

  void _listenToAuthChanges() {
    _authSubscription?.cancel();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      unawaited(_syncFromSupabaseProfile());
      unawaited(_subscribeToUserRealtime());
    });
  }

  Future<void> _syncFromSupabaseProfile() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      state = const SubscriptionState.free();
      return;
    }

    await Supabase.instance.client.from('users').upsert({'id': userId});

    final row = await Supabase.instance.client
        .from('users')
        .select('active_plan, subscription_expires_at')
        .eq('id', userId)
        .maybeSingle();

    final nextState = _stateFromRow(row);
    if (state.plan != nextState.plan ||
        state.subscriptionExpiresAt != nextState.subscriptionExpiresAt) {
      state = nextState;
    }
  }

  SubscriptionState _stateFromRow(Map<String, dynamic>? row) {
    final rawPlan = row?['active_plan']?.toString().toUpperCase() ?? 'FREE';
    final plan = rawPlan == 'PRO' ? AccountPlan.pro : AccountPlan.free;

    DateTime? subscriptionExpiresAt;
    final rawExpiresAt = row?['subscription_expires_at']?.toString();
    if (rawExpiresAt != null && rawExpiresAt.isNotEmpty) {
      subscriptionExpiresAt = DateTime.tryParse(rawExpiresAt)?.toUtc();
    }

    return SubscriptionState(
      plan: plan,
      subscriptionExpiresAt: subscriptionExpiresAt,
    );
  }

  Future<void> _subscribeToUserRealtime() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;

    _usersRealtimeChannel?.unsubscribe();
    _usersRealtimeChannel = null;

    if (userId == null) return;

    final channel = client.channel('users-subscription-$userId');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'users',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: userId,
      ),
      callback: (payload) {
        final nextState = _stateFromRow(payload.newRecord);
        if (state.plan != nextState.plan ||
            state.subscriptionExpiresAt != nextState.subscriptionExpiresAt) {
          state = nextState;
        }
      },
    );

    channel.subscribe();
    _usersRealtimeChannel = channel;
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

  DateTime? _expirationFromCustomerInfo(CustomerInfo info) {
    final entitlementId = _resolveEntitlementId();
    final entitlement = info.entitlements.active[entitlementId];
    final rawDate = entitlement?.expirationDate;
    if (rawDate == null || rawDate.isEmpty) {
      return null;
    }
    return DateTime.tryParse(rawDate)?.toUtc();
  }

  Future<void> _syncPlanToSupabase(AccountPlan plan, {DateTime? subscriptionExpiresAt}) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      return;
    }

    final activePlan = plan == AccountPlan.pro ? 'PRO' : 'FREE';
    await Supabase.instance.client.from('users').upsert({
      'id': userId,
      'active_plan': activePlan,
      'subscription_expires_at': plan == AccountPlan.pro
          ? subscriptionExpiresAt?.toIso8601String()
          : null,
    });
  }

  Future<void> syncFromRevenueCat() async {
    await _ensureConfigured();
    if (!_isRevenueCatEnabled || kIsWeb) {
      return;
    }

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final resolved = _planFromCustomerInfo(customerInfo);
      final expiresAt = _expirationFromCustomerInfo(customerInfo);
      state = state.copyWith(
        plan: resolved,
        subscriptionExpiresAt: expiresAt,
        clearExpiration: resolved == AccountPlan.free,
      );
      await _syncPlanToSupabase(resolved, subscriptionExpiresAt: expiresAt);
    } catch (e) {
      debugPrint('Failed to sync RevenueCat entitlement: $e');
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
    final expiresAt = _expirationFromCustomerInfo(info);
    state = state.copyWith(
      plan: resolved,
      subscriptionExpiresAt: expiresAt,
      clearExpiration: resolved == AccountPlan.free,
    );
    await _syncPlanToSupabase(resolved, subscriptionExpiresAt: expiresAt);
    return info;
  }

  Future<CustomerInfo?> restorePurchases() async {
    await _ensureConfigured();
    if (!_isRevenueCatEnabled || kIsWeb) {
      return null;
    }

    final info = await Purchases.restorePurchases();
    final resolved = _planFromCustomerInfo(info);
    final expiresAt = _expirationFromCustomerInfo(info);
    state = state.copyWith(
      plan: resolved,
      subscriptionExpiresAt: expiresAt,
      clearExpiration: resolved == AccountPlan.free,
    );
    await _syncPlanToSupabase(resolved, subscriptionExpiresAt: expiresAt);
    return info;
  }

  bool get isPro => state.isPro;
  
  // Free account limits
  int get maxTrackedItems => isPro ? 9999 : 3;
  int get searchExpirationDays => isPro ? 365 : 7;
}

final subscriptionProvider = NotifierProvider<SubscriptionNotifier, SubscriptionState>(() {
  return SubscriptionNotifier();
});
