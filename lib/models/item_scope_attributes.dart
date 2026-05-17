// Modele do parsowania JSONB z pola `attributes.scopes` w tabeli tracked_items.
// Struktura bazy:
// attributes: {
//   scopes: {
//     local:  { link, store_url, store_name, original_price, original_currency, converted_price }
//     eu:     { ... }
//     global: { ... }
//   }
// }

class ScopeEntry {
  final String link;
  final String storeUrl;
  final String storeName;
  final double? originalPrice;
  final String originalCurrency;
  final double? convertedPrice;

  const ScopeEntry({
    required this.link,
    required this.storeUrl,
    required this.storeName,
    this.originalPrice,
    required this.originalCurrency,
    this.convertedPrice,
  });

  factory ScopeEntry.fromJson(Map<String, dynamic> json) {
    return ScopeEntry(
      link: json['link']?.toString() ?? '',
      storeUrl: json['store_url']?.toString() ?? '',
      storeName: json['store_name']?.toString() ?? '',
      originalPrice: _asDouble(json['original_price']),
      originalCurrency: json['original_currency']?.toString() ?? '',
      convertedPrice: _asDouble(json['converted_price']),
    );
  }

  bool get hasUsableLink => link.isNotEmpty || storeUrl.isNotEmpty;

  /// Returns the best available direct URL:
  /// Prefers storeUrl (direct retailer), falls back to link (may be google shopping).
  String get bestUrl => storeUrl.isNotEmpty ? storeUrl : link;

  /// True when the best URL is a Google Shopping URL (cannot be wrapped in CJ affiliate).
  bool get isGoogleShoppingUrl {
    final url = bestUrl;
    return url.contains('google.com/search') && url.contains('ibp=oshop');
  }

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value == null) return null;
    return double.tryParse(value.toString());
  }
}

class ItemScopeAttributes {
  final ScopeEntry? local;
  final ScopeEntry? eu;
  final ScopeEntry? global;

  const ItemScopeAttributes({this.local, this.eu, this.global});

  factory ItemScopeAttributes.fromAttributesMap(Map<String, dynamic> attributes) {
    final rawScopes = attributes['scopes'];
    if (rawScopes == null || rawScopes is! Map) {
      return const ItemScopeAttributes();
    }
    final scopes = Map<String, dynamic>.from(rawScopes);

    ScopeEntry? parseScope(String key) {
      final raw = scopes[key];
      if (raw == null || raw is! Map) return null;
      return ScopeEntry.fromJson(Map<String, dynamic>.from(raw));
    }

    return ItemScopeAttributes(
      local: parseScope('local'),
      eu: parseScope('eu'),
      global: parseScope('global'),
    );
  }

  /// Returns the best link to open for the "Buy Now" button.
  /// Priority: local.link → eu.link → global.link (google shopping fallback).
  /// Returns null if no link is available anywhere.
  String? resolveBestBuyUrl() {
    for (final scope in [local, eu, global]) {
      if (scope == null) continue;
      final url = scope.bestUrl;
      if (url.isNotEmpty) return url;
    }
    return null;
  }

  /// True when the best available URL is a Google Shopping link.
  /// In this case, skip CJ affiliate wrapping and open directly.
  bool bestUrlIsGoogleShopping() {
    final url = resolveBestBuyUrl();
    if (url == null) return false;
    return url.contains('google.com/search') && url.contains('ibp=oshop');
  }

  /// Collects all scopes that have meaningful data for display in the UI.
  List<({String label, ScopeEntry entry})> get displayableScopes {
    final result = <({String label, ScopeEntry entry})>[];
    if (local != null && local!.hasUsableLink) {
      result.add((label: 'local', entry: local!));
    }
    if (eu != null && eu!.hasUsableLink) {
      result.add((label: 'eu', entry: eu!));
    }
    if (global != null && global!.hasUsableLink) {
      result.add((label: 'global', entry: global!));
    }
    return result;
  }

  bool get isEmpty => local == null && eu == null && global == null;
}
