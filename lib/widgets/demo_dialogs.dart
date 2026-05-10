import 'package:flutter/material.dart';

Future<void> showWebDemoDialog(BuildContext context) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;

  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'To tylko wersja Demo!',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
      ),
      content: Text(
        'Wersja przeglądarkowa służy tylko do prezentacji działania radaru. '
        'Aby śledzić prawdziwe ceny na 31 rynkach i kupować produkty z rabatami, '
        'pobierz pełną aplikację na swój telefon.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.84),
          height: 1.45,
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildStoreMockButton(
              context: ctx,
              icon: Icons.android,
              label: 'Google Play',
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _buildStoreMockButton(
              context: ctx,
              icon: Icons.apple,
              label: 'App Store',
              isDark: isDark,
            ),
          ],
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Rozumiem'),
        ),
      ],
    ),
  );
}

Widget _buildStoreMockButton({
  required BuildContext context,
  required IconData icon,
  required String label,
  required bool isDark,
}) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;

  return Opacity(
    opacity: 0.65,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline.withValues(alpha: isDark ? 0.42 : 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onSurface.withValues(alpha: 0.7)),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    ),
  );
}
