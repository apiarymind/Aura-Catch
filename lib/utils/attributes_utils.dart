Map<String, dynamic> sanitizeAttributesMap(dynamic rawAttributes) {
  if (rawAttributes is! Map) {
    return <String, dynamic>{};
  }

  final sanitized = <String, dynamic>{};
  rawAttributes.forEach((key, value) {
    final normalizedKey = key.toString().trim();
    if (normalizedKey.isEmpty || value == null) {
      return;
    }

    final normalizedValue = value is String ? value.trim() : value;
    if (normalizedValue is String && normalizedValue.isEmpty) {
      return;
    }

    sanitized[normalizedKey] = normalizedValue;
  });

  return sanitized;
}
