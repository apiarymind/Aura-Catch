import 'package:flutter_test/flutter_test.dart';

import 'package:aura_catch/models/tracked_item.dart';
import 'package:aura_catch/utils/attributes_utils.dart';

void main() {
  group('Attributes data flow', () {
    test('Electronics: Apple iPhone 15 Pro keeps wariant map through sanitize + model json', () {
      final uiMap = {
        'wariant': '256GB, Black',
        ' ': 'ignored',
        'empty': '   ',
      };

      final sanitized = sanitizeAttributesMap(uiMap);
      expect(sanitized, {'wariant': '256GB, Black'});

      final dbRow = {
        'id': '1',
        'brand': 'Apple',
        'model': 'iPhone 15 Pro',
        'target_price': 4000,
        'current_status': 'ACTIVE',
        'store_name': 'Media Expert',
        'added_at': '2026-01-01T10:00:00Z',
        'attributes': sanitized,
      };

      final item = TrackedItem.fromJson(dbRow);
      expect(item.attributes['wariant'], '256GB, Black');
      expect(item.toJson()['attributes'], {'wariant': '256GB, Black'});
    });

    test('Beauty: Chanel N°5 keeps wariant 35ml through pipeline', () {
      final uiMap = {'wariant': '35ml'};
      final sanitized = sanitizeAttributesMap(uiMap);
      expect(sanitized, {'wariant': '35ml'});

      final dbRow = {
        'id': '2',
        'brand': 'Chanel',
        'model': 'N°5 Eau de Parfum',
        'target_price': 380,
        'current_status': 'ACTIVE',
        'store_name': 'Sephora',
        'added_at': '2026-01-01T10:00:00Z',
        'attributes': sanitized,
      };

      final item = TrackedItem.fromJson(dbRow);
      expect(item.attributes['wariant'], '35ml');
      expect(item.toJson()['attributes'], {'wariant': '35ml'});
    });

    test('Clothing: Nike Air Force 1 keeps wariant Rozmiar 42 through pipeline', () {
      final uiMap = {'wariant': 'Rozmiar 42'};
      final sanitized = sanitizeAttributesMap(uiMap);
      expect(sanitized, {'wariant': 'Rozmiar 42'});

      final dbRow = {
        'id': '3',
        'brand': 'Nike',
        'model': 'Air Force 1',
        'target_price': 450,
        'current_status': 'ACTIVE',
        'store_name': 'Amazon',
        'added_at': '2026-01-01T10:00:00Z',
        'attributes': sanitized,
      };

      final item = TrackedItem.fromJson(dbRow);
      expect(item.attributes['wariant'], 'Rozmiar 42');
      expect(item.toJson()['attributes'], {'wariant': 'Rozmiar 42'});
    });
  });
}
