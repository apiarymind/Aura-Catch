import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:aura_catch/models/tracked_item.dart';
import 'package:aura_catch/providers/tracking_provider.dart';
import 'package:aura_catch/services/database_service.dart';

void main() {
  group('TrackedItemsNotifier auth change rebuild', () {
    test('reacts to login/logout events and refetches tracked items', () async {
      final authController = StreamController<AuthState>.broadcast();
      final mockDb = MockDatabaseService();

      final container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(mockDb),
          authStateChangesProvider.overrideWith((ref) => authController.stream),
        ],
      );

      final observedStates = <AsyncValue<List<TrackedItem>>>[];
      final listener = container.listen<AsyncValue<List<TrackedItem>>>(
        trackedItemsProvider,
        (_, next) => observedStates.add(next),
        fireImmediately: true,
      );
      addTearDown(() async {
        listener.close();
        container.dispose();
        await authController.close();
      });

      authController.add(AuthState(AuthChangeEvent.initialSession, null));
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(mockDb.getTrackedItemsCalls, greaterThanOrEqualTo(1));

      final baselineCalls = mockDb.getTrackedItemsCalls;
      observedStates.clear();
      mockDb.nextResult = <TrackedItem>[sampleItem('item-login', 'Apple', 'iPhone 15 Pro')];
      authController.add(AuthState(AuthChangeEvent.signedIn, null));
      await Future<void>.delayed(const Duration(milliseconds: 150));

      expect(mockDb.getTrackedItemsCalls, greaterThan(baselineCalls));
      expect(observedStates.any((state) => state.isLoading), isTrue);
      expect((container.read(trackedItemsProvider).value ?? <TrackedItem>[]).isNotEmpty, isTrue);
      expect(container.read(trackedItemsProvider).value?.first.brand, 'Apple');

      final afterLoginCalls = mockDb.getTrackedItemsCalls;
      observedStates.clear();
      mockDb.nextResult = <TrackedItem>[];
      authController.add(AuthState(AuthChangeEvent.signedOut, null));
      await Future<void>.delayed(const Duration(milliseconds: 150));

      expect(mockDb.getTrackedItemsCalls, greaterThan(afterLoginCalls));
      expect(observedStates.any((state) => state.isLoading), isTrue);
      expect((container.read(trackedItemsProvider).value ?? <TrackedItem>[]).isEmpty, isTrue);
    });
  });
}

class MockDatabaseService extends DatabaseService {
  List<TrackedItem> nextResult = <TrackedItem>[];
  int getTrackedItemsCalls = 0;

  MockDatabaseService() : super(FakeSupabaseClient());

  @override
  Future<List<TrackedItem>> getTrackedItems() async {
    getTrackedItemsCalls += 1;
    await Future<void>.delayed(const Duration(milliseconds: 30));
    return List<TrackedItem>.from(nextResult);
  }
}

TrackedItem sampleItem(String id, String brand, String model) {
  return TrackedItem(
    id: id,
    brand: brand,
    model: model,
    addedAt: DateTime.utc(2026, 5, 9),
    targetPrice: 1000,
    currentPrice: 900,
    lowestPrice180d: 850,
    status: 'ACTIVE',
    storeName: 'Mock Store',
    attributes: const {'wariant': '256GB, Black', 'condition': 'NEW'},
    conditionType: 'NEW',
    scopeRegion: 'GLOBAL',
    storeReputation: 'GREEN_SHIELD',
  );
}

class FakeSupabaseClient implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
