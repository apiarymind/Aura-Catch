import 'package:supabase_flutter/supabase_flutter.dart';

class AiSearchService {
  final SupabaseClient _supabaseClient;
  static const Set<String> _allowedConditions = {'NEW', 'USED', 'OUTLET'};
  static const Set<String> _allowedScopes = {'LOCAL', 'EU', 'GLOBAL'};

  AiSearchService(this._supabaseClient);

  String _normalizeString(dynamic value, {String fallback = ''}) {
    final normalized = value?.toString().trim() ?? '';
    return normalized.isEmpty ? fallback : normalized;
  }

  String _normalizeCondition(dynamic value) {
    final normalized = _normalizeString(value).toUpperCase();
    if (_allowedConditions.contains(normalized)) {
      return normalized;
    }
    return 'NEW';
  }

  String _normalizeScope(dynamic value) {
    final normalized = _normalizeString(value).toUpperCase();
    if (_allowedScopes.contains(normalized)) {
      return normalized;
    }
    return 'GLOBAL';
  }

  Map<String, dynamic> _normalizeAttributes(dynamic rawAttributes) {
    if (rawAttributes is! Map) {
      return <String, dynamic>{};
    }

    final mapped = Map<String, dynamic>.from(rawAttributes);
    mapped.removeWhere((key, value) {
      final keyText = key.toString().trim();
      final valueText = value?.toString().trim() ?? '';
      return keyText.isEmpty || valueText.isEmpty;
    });
    return mapped;
  }

  Map<String, dynamic> _normalizeStrictPayload(Map<String, dynamic> payload) {
    return {
      'category': _normalizeString(payload['category']),
      'brand': _normalizeString(payload['brand'], fallback: 'Unknown'),
      'model': _normalizeString(payload['model']),
      'attributes': _normalizeAttributes(payload['attributes']),
      'condition': _normalizeCondition(payload['condition']),
      'scope': _normalizeScope(payload['scope']),
    };
  }

  Future<Map<String, dynamic>> analyzeQuery({String? text, String? imageBase64}) async {
    try {
      final body = <String, dynamic>{};
      if (text != null && text.isNotEmpty) {
        body['query'] = text;
      }
      if (imageBase64 != null && imageBase64.isNotEmpty) {
        body['image'] = imageBase64;
      }

      if (body.isEmpty) {
        throw Exception('Must provide either text or image');
      }

      final response = await _supabaseClient.functions.invoke(
        'nlp_processor',
        body: body,
      );

      if (response.status == 200) {
        final data = Map<String, dynamic>.from(response.data as Map);
        return _normalizeStrictPayload(data);
      } else {
        throw Exception('Failed to process query: ${response.status} - ${response.data}');
      }
    } catch (e) {
      throw Exception('AiSearchService Error: $e');
    }
  }
}
