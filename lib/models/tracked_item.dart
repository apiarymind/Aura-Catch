class TrackedItem {
  final String id;
  final String brand;
  final String model;
  final String? productUrl;
  final DateTime addedAt;
  final double targetPrice;
  final double? currentPrice;
  final double? lowestPrice180d;
  final String status;
  final String storeName;
  final Map<String, dynamic> attributes;
  final String conditionType;
  final String scopeRegion;
  final String storeReputation; // GREEN_SHIELD, YELLOW_WARNING

  TrackedItem({
    required this.id,
    required this.brand,
    required this.model,
    this.productUrl,
    required this.addedAt,
    required this.targetPrice,
    this.currentPrice,
    this.lowestPrice180d,
    required this.status,
    required this.storeName,
    this.attributes = const {},
    required this.conditionType,
    required this.scopeRegion,
    required this.storeReputation,
  });

  factory TrackedItem.fromJson(Map<String, dynamic> json) {
    final rawAttributes = json['attributes'];
    final attributes = rawAttributes is Map ? Map<String, dynamic>.from(rawAttributes) : <String, dynamic>{};

    return TrackedItem(
      id: json['id']?.toString() ?? '',
      brand: json['brand']?.toString() ?? 'Unknown',
      model: json['model']?.toString() ?? 'Unknown',
      productUrl: json['product_url']?.toString(),
      addedAt: DateTime.tryParse(json['added_at']?.toString() ?? '') ?? DateTime.now().toUtc(),
      targetPrice: _asDouble(json['target_price']) ?? 0.0,
      currentPrice: _asDouble(json['current_price']),
      lowestPrice180d: _asDouble(json['lowest_price_180d']),
      status: json['current_status']?.toString() ?? 'ACTIVE',
      storeName: json['store_name']?.toString() ?? 'Pending...',
      attributes: attributes,
      conditionType: attributes['condition']?.toString() ?? 'NEW',
      scopeRegion: json['scope_region']?.toString() ?? 'GLOBAL',
      storeReputation: json['store_reputation']?.toString() ?? 'GREEN_SHIELD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'product_url': productUrl,
      'added_at': addedAt.toUtc().toIso8601String(),
      'target_price': targetPrice,
      'current_price': currentPrice,
      'lowest_price_180d': lowestPrice180d,
      'current_status': status,
      'store_name': storeName,
      'attributes': Map<String, dynamic>.from(attributes),
      'scope_region': scopeRegion,
      'store_reputation': storeReputation,
    };
  }

  static double? _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value == null) {
      return null;
    }
    return double.tryParse(value.toString());
  }
}
