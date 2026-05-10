import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/ai_search_service.dart';

final aiSearchServiceProvider = Provider<AiSearchService>((ref) {
  return AiSearchService(Supabase.instance.client);
});

final aiSearchStateProvider = NotifierProvider<AiSearchNotifier, AsyncValue<Map<String, dynamic>?>>(() {
  return AiSearchNotifier();
});

class AiSearchNotifier extends Notifier<AsyncValue<Map<String, dynamic>?>> {
  @override
  AsyncValue<Map<String, dynamic>?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> analyzeQuery({String? text, String? imageBase64}) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(aiSearchServiceProvider);
      final result = await service.analyzeQuery(text: text, imageBase64: imageBase64);
      state = AsyncValue.data(result);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
