import 'package:supabase_flutter/supabase_flutter.dart';

class AiSearchService {
  final SupabaseClient _supabaseClient;

  AiSearchService(this._supabaseClient);

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
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to process query: ${response.status} - ${response.data}');
      }
    } catch (e) {
      throw Exception('AiSearchService Error: $e');
    }
  }
}
