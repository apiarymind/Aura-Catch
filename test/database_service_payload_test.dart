import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:aura_catch/services/database_service.dart';

void main() {
  group('DatabaseService.buildTrackedItemInsertPayload', () {
    final service = DatabaseService(FakeSupabaseClient());

    test('keeps electronics wariant and sanitizes empty keys', () {
      final payload = service.buildTrackedItemInsertPayload(
        userId: 'user-1',
        activePlan: 'free',
        aiData: {
          'brand': 'Apple',
          'model': 'iPhone 15 Pro',
          'targetPrice': 4000,
          'condition': 'NEW',
          'category': 'electronics',
          'attributes': {
            'wariant': '256GB, Black',
            '': 'drop',
            'empty': '  ',
          },
        },
      );

      expect(payload['user_id'], 'user-1');
      expect(payload['brand'], 'Apple');
      expect(payload['model'], 'iPhone 15 Pro');
      expect(payload['target_price'], 4000.0);

      final attrs = Map<String, dynamic>.from(payload['attributes'] as Map);
      expect(attrs['wariant'], '256GB, Black');
      expect(attrs['condition'], 'NEW');
      expect(attrs['category'], 'electronics');
      expect(attrs.containsKey(''), false);
      expect(attrs.containsKey('empty'), false);
    });

    test('beauty payload keeps wariant and injects volume_ml when missing', () {
      final payload = service.buildTrackedItemInsertPayload(
        userId: 'user-2',
        activePlan: 'free',
        aiData: {
          'brand': 'Chanel',
          'model': 'N°5 Eau de Parfum',
          'targetPrice': 380,
          'condition': 'NEW',
          'category': 'beauty',
          'volume_ml': '35',
          'attributes': {
            'wariant': '35ml',
          },
        },
      );

      final attrs = Map<String, dynamic>.from(payload['attributes'] as Map);
      expect(attrs['wariant'], '35ml');
      expect(attrs['volume_ml'], '35');
      expect(attrs['condition'], 'NEW');
      expect(attrs['category'], 'beauty');
    });

    test('clothing payload keeps wariant and normalizes condition fallback', () {
      final payload = service.buildTrackedItemInsertPayload(
        userId: 'user-3',
        activePlan: 'free',
        aiData: {
          'brand': 'Nike',
          'model': 'Air Force 1',
          'targetPrice': '450',
          'condition': 'unsupported',
          'category': 'clothing',
          'attributes': {
            'wariant': 'Rozmiar 42',
          },
        },
      );

      final attrs = Map<String, dynamic>.from(payload['attributes'] as Map);
      expect(attrs['wariant'], 'Rozmiar 42');
      expect(attrs['condition'], 'NEW');
      expect(attrs['category'], 'clothing');
      expect(payload['target_price'], 450.0);
    });
  });
}

class FakeSupabaseClient implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
