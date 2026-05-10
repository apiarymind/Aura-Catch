import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/localization_provider.dart';

class ShopReputationBadge extends ConsumerWidget {
  final String status;

  const ShopReputationBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(localizationProvider);

    if (status == 'GREEN_SHIELD') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shield, color: Colors.green, size: 16),
          const SizedBox(width: 4),
          Text(strings.safeShop, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
          const SizedBox(width: 4),
          Text(strings.warning, style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      );
    }
  }
}
