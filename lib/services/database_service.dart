import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/tracked_item.dart';
import '../utils/attributes_utils.dart';

class FreePlanLimitReachedException implements Exception {
  @override
  String toString() => 'FREE_PLAN_LIMIT_REACHED';
}

class DatabaseService {
  final SupabaseClient _client;
  static const int _freeMaxActiveItems = 3;
  static const int _freeTrackingDays = 7;

  DatabaseService(this._client);

  Future<User?> _ensureUser() async {
    var user = _client.auth.currentUser;
    if (user != null) return user;

    await _client.auth.signInAnonymously();
    return _client.auth.currentUser;
  }

  String _normalizeCondition(dynamic rawCondition) {
    final value = rawCondition?.toString().trim().toUpperCase() ?? '';
    if (value == 'USED' || value == 'OUTLET') return value;
    return 'NEW';
  }

  Map<String, dynamic> _normalizeAttributes(dynamic rawAttributes) {
    return sanitizeAttributesMap(rawAttributes);
  }

  Future<void> _ensureUserProfile(String userId) async {
    await _client.from('users').upsert({
      'id': userId,
    });
  }

  Future<String> _getActivePlan(String userId) async {
    final response = await _client
        .from('users')
        .select('active_plan')
        .eq('id', userId)
        .maybeSingle();

    final rawPlan = response?['active_plan']?.toString().toUpperCase();
    if (rawPlan == 'PRO') {
      return 'PRO';
    }
    return 'FREE';
  }

  Future<void> _enforceFreeLifecycleLocks(String userId) async {
    final cutoffIso = DateTime.now()
        .toUtc()
        .subtract(const Duration(days: _freeTrackingDays))
        .toIso8601String();

    await _client
        .from('tracked_items')
        .update({'current_status': 'LOCKED'})
        .eq('user_id', userId)
        .eq('current_status', 'ACTIVE')
        .lt('added_at', cutoffIso);
  }

  Future<void> _enforceLifecycleForPlan({
    required String userId,
    required String activePlan,
  }) async {
    if (activePlan == 'FREE') {
      await _enforceFreeLifecycleLocks(userId);
    }
  }

  Future<void> _enforceFreeTierActiveLimit(String userId) async {
    final rows = await _client
        .from('tracked_items')
        .select('id')
        .eq('user_id', userId)
        .eq('current_status', 'ACTIVE');

    final activeCount = (rows as List<dynamic>).length;
    debugPrint('Checking active item count for user $userId: $activeCount/$_freeMaxActiveItems');
    if (activeCount >= _freeMaxActiveItems) {
      throw FreePlanLimitReachedException();
    }
  }

  Future<void> handlePlanDowngrade(String userId) async {
    final rows = await _client
        .from('tracked_items')
        .select('id, added_at')
        .eq('user_id', userId)
        .order('added_at', ascending: true);

    final items = (rows as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();

    final oldestActiveIds = items
        .take(_freeMaxActiveItems)
        .map((row) => row['id']?.toString())
        .whereType<String>()
        .toList();

    await _client
        .from('tracked_items')
        .update({'current_status': 'LOCKED'})
        .eq('user_id', userId);

    if (oldestActiveIds.isNotEmpty) {
      await _client
          .from('tracked_items')
          .update({'current_status': 'ACTIVE'})
          .eq('user_id', userId)
          .inFilter('id', oldestActiveIds);
    }

    await _enforceFreeLifecycleLocks(userId);
  }

  Future<void> addTrackedItem(Map<String, dynamic> aiData) async {
    final user = await _ensureUser();
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    await _ensureUserProfile(user.id);
    final activePlan = await _getActivePlan(user.id);
    await _enforceLifecycleForPlan(userId: user.id, activePlan: activePlan);
    if (activePlan == 'FREE') {
      await _enforceFreeTierActiveLimit(user.id);
    }

    final dataToInsert = buildTrackedItemInsertPayload(
      userId: user.id,
      aiData: aiData,
    );

    await _client.from('tracked_items').insert(dataToInsert);
  }

  @visibleForTesting
  Map<String, dynamic> buildTrackedItemInsertPayload({
    required String userId,
    required Map<String, dynamic> aiData,
  }) {

    // Safely parse targetPrice
    final double? parsedTargetPrice = aiData['targetPrice'] is num
        ? (aiData['targetPrice'] as num).toDouble()
        : double.tryParse(aiData['targetPrice']?.toString() ?? '');

    if (parsedTargetPrice == null) {
      throw Exception('Missing or invalid targetPrice');
    }

    final mergedAttributes = _normalizeAttributes(aiData['attributes']);

    final category = aiData['category']?.toString();
    if (category != null && category.trim().isNotEmpty) {
      mergedAttributes['category'] = category;
    }

    final condition = _normalizeCondition(aiData['condition']);
    mergedAttributes['condition'] = condition;

    final volumeMl = aiData['volume_ml']?.toString().trim();
    if (volumeMl != null && volumeMl.isNotEmpty && !mergedAttributes.containsKey('volume_ml')) {
      mergedAttributes['volume_ml'] = volumeMl;
    }

    final dataToInsert = {
      'user_id': userId,
      'brand': aiData['brand'] ?? 'Unknown',
      'model': aiData['model'] ?? 'Unknown',
      'target_price': parsedTargetPrice,
      'current_status': 'ACTIVE',
      'attributes': mergedAttributes,
    };

    return dataToInsert;
  }

  @visibleForTesting
  List<TrackedItem> mapTrackedItemsResponse(dynamic response) {
    if (response is! List) {
      throw const FormatException('Invalid tracked_items response: expected a List');
    }

    try {
      return response
          .map((row) => TrackedItem.fromJson(Map<String, dynamic>.from(row as Map)))
          .toList();
    } catch (e) {
      throw FormatException('Failed to parse tracked_items payload: $e');
    }
  }

  Future<List<TrackedItem>> getTrackedItems() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      debugPrint('Tracked items fetch skipped: no authenticated user in session');
      return [];
    }

    try {
      await _ensureUserProfile(user.id);
      final activePlan = await _getActivePlan(user.id);
      await _enforceLifecycleForPlan(userId: user.id, activePlan: activePlan);

      final response = await _client
          .from('tracked_items')
          .select()
          .eq('user_id', user.id)
          .order('added_at', ascending: false);

      return mapTrackedItemsResponse(response);
    } on PostgrestException catch (e, stackTrace) {
      debugPrint('Supabase fetch error for tracked_items user=${user.id}: ${e.message} (${e.code})');
      debugPrintStack(stackTrace: stackTrace);
      throw Exception('Failed to fetch tracked items from Supabase: ${e.message}');
    } on FormatException catch (e, stackTrace) {
      debugPrint('Tracked items parsing error for user=${user.id}: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw Exception('Failed to parse tracked items payload: ${e.message}');
    } catch (e, stackTrace) {
      debugPrint('Unexpected tracked items fetch error for user=${user.id}: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw Exception('Unexpected tracked items fetch failure: $e');
    }
  }

  Future<void> deleteTrackedItem(String itemId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    await _client
        .from('tracked_items')
        .delete()
        .eq('id', itemId)
        .eq('user_id', user.id);
  }
}
