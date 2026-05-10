import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:aura_catch/models/tracked_item.dart';
import 'package:aura_catch/services/database_service.dart';

void main() {
  group('DatabaseService mapTrackedItemsResponse', () {
    final service = DatabaseService(FakeSupabaseClient());

    test('parses SELECT payload with complex JSONB attributes into TrackedItem list', () {
      final selectPayload = [
        {
          'id': 'item-1',
          'brand': 'Apple',
          'model': 'iPhone 15 Pro',
          'product_url': 'https://example.com/iphone15pro',
          'added_at': '2026-05-09T08:00:00Z',
          'target_price': 4000,
          'current_price': 3899.99,
          'lowest_price_180d': 3599,
          'current_status': 'ACTIVE',
          'store_name': 'Media Expert',
          'scope_region': 'PL',
          'store_reputation': 'GREEN_SHIELD',
          'attributes': {
            'wariant': '256GB, Black',
            'category': 'electronics',
            'condition': 'NEW',
            'tags': ['apple', 'iphone', 'flagship'],
            'meta': {
              'source': 'ai',
              'confidence': 0.96,
            },
          },
        },
        {
          'id': 'item-2',
          'brand': 'Nike',
          'model': 'Air Force 1',
          'added_at': '2026-05-09T09:00:00Z',
          'target_price': '450',
          'current_status': 'ACTIVE',
          'store_name': 'Amazon',
          'attributes': {
            'wariant': 'Rozmiar 42',
            'category': 'clothing',
            'condition': 'NEW',
          },
        },
      ];

      final items = service.mapTrackedItemsResponse(selectPayload);

      expect(items, hasLength(2));
      expect(items.first, isA<TrackedItem>());
      expect(items.first.id, 'item-1');
      expect(items.first.attributes['wariant'], '256GB, Black');
      expect(items.first.attributes['tags'], ['apple', 'iphone', 'flagship']);
      expect((items.first.attributes['meta'] as Map)['source'], 'ai');
      expect(items.last.targetPrice, 450.0);
      expect(items.last.attributes['wariant'], 'Rozmiar 42');
    });

    test('throws FormatException when payload is not a list', () {
      expect(
        () => service.mapTrackedItemsResponse({'id': 'not-a-list'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when row structure is invalid', () {
      expect(
        () => service.mapTrackedItemsResponse([123]),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

class FakeSupabaseClient implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
