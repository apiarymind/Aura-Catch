import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tracked_item.dart';
import '../services/database_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService(Supabase.instance.client);
});

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final trackedItemsProvider = AsyncNotifierProvider<TrackedItemsNotifier, List<TrackedItem>>(() {
  return TrackedItemsNotifier();
});

class TrackedItemsNotifier extends AsyncNotifier<List<TrackedItem>> {
  @override
  Future<List<TrackedItem>> build() async {
    ref.watch(authStateChangesProvider);
    final dbService = ref.watch(databaseServiceProvider);
    return dbService.getTrackedItems();
  }

  Future<void> deleteItem(String itemId) async {
    state = const AsyncValue.loading();
    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.deleteTrackedItem(itemId);
      ref.invalidateSelf();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
