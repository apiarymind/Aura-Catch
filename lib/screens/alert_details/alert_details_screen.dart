import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/tracked_item.dart';
import '../../providers/link_generator_provider.dart';
import '../../providers/localization_provider.dart';
import '../../providers/region_provider.dart';
import '../../providers/tracking_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/demo_dialogs.dart';

class AlertDetailsScreen extends ConsumerStatefulWidget {
  final TrackedItem? item;

  const AlertDetailsScreen({super.key, required this.item});

  @override
  ConsumerState<AlertDetailsScreen> createState() => _AlertDetailsScreenState();
}

class _AlertDetailsScreenState extends ConsumerState<AlertDetailsScreen> {
  bool _isDeleting = false;

  bool _requiresLogin(User? user) {
    if (user == null) return true;
    final email = user.email?.trim() ?? '';
    return user.isAnonymous || email.isEmpty;
  }

  Future<void> _handleBuyNow() async {
    if (kIsWeb) {
      await showWebDemoDialog(context);
      return;
    }

    final strings = ref.read(localizationProvider);
    final user = ref.read(authServiceProvider).currentUser;

    if (_requiresLogin(user)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(strings.loginRequired),
          content: Text(strings.loginRegister),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(strings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/login');
              },
              child: Text(strings.login),
            ),
          ],
        ),
      );
      return;
    }

    final item = widget.item;
    if (item == null) return;

    final region = ref.read(regionProvider);
    final fallbackProductUrl = item.attributes['product_url']?.toString();
    final link = ref.read(linkGeneratorServiceProvider).buildMonetizedLink(
          storeName: item.storeName,
          region: region,
          brand: item.brand,
          model: item.model,
          rawProductUrl: item.productUrl ?? fallbackProductUrl,
        );

    debugPrint('Opening affiliate link: $link');
    final launched = await launchUrl(link, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('error'))),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.openingLink)),
    );
  }

  Future<void> _deleteAlert(TrackedItem item) async {
    setState(() {
      _isDeleting = true;
    });
    try {
      await ref.read(databaseServiceProvider).deleteTrackedItem(item.id);
      ref.invalidate(trackedItemsProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('delete_alert_failed', namedArgs: {'error': '$e'})),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  String _formatKey(String key) {
    return key
        .split('_')
        .map((part) => part.isEmpty ? '' : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(localizationProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final item = widget.item;

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.alertDetails)),
        body: Center(
          child: Text(
            tr('no_item_selected'),
            style: theme.textTheme.bodyLarge,
          ),
        ),
      );
    }

    final currentRegion = ref.watch(regionProvider);
    final currencyPrefix = currencyPrefixForRegion(currentRegion);
    final isDeal = item.currentPrice != null && item.currentPrice! < item.targetPrice;
    final saveAmount = isDeal ? item.targetPrice - item.currentPrice! : 0.0;
    final localAddedAt = item.addedAt.toLocal();
    final addedLabel =
        '${localAddedAt.year.toString().padLeft(4, '0')}-${localAddedAt.month.toString().padLeft(2, '0')}-${localAddedAt.day.toString().padLeft(2, '0')}';
    final attributes = Map<String, dynamic>.from(item.attributes)
      ..removeWhere((key, value) => value == null || value.toString().trim().isEmpty);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.alertDetails),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            item.brand,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.model,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('attributes_label'),
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (attributes.isEmpty)
                  Text(tr('no_attributes_detected'), style: theme.textTheme.bodyMedium)
                else
                  ...attributes.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(Icons.tune, size: 16, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_formatKey(entry.key)}: ${entry.value}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(
                    'target_price_label',
                    namedArgs: {'price': '$currencyPrefix${item.targetPrice.toStringAsFixed(2)}'},
                  ),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.currentPrice == null
                            ? tr('current_price_pending')
                            : tr(
                                'current_price_label_with_value',
                                namedArgs: {'price': '$currencyPrefix${item.currentPrice!.toStringAsFixed(2)}'},
                              ),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDeal ? colorScheme.primary : colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (isDeal)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          tr(
                            'save_amount_label',
                            namedArgs: {'amount': '$currencyPrefix${saveAmount.toStringAsFixed(2)}'},
                          ),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.lowestPrice180d == null
                      ? tr('lowest_180_label_pending')
                      : tr(
                          'lowest_180_label',
                          namedArgs: {'price': '$currencyPrefix${item.lowestPrice180d!.toStringAsFixed(2)}'},
                        ),
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('status_label', namedArgs: {'status': item.status}),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  tr('date_added_label', namedArgs: {'date': addedLabel}),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  tr('store_label', namedArgs: {'store': item.storeName}),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleBuyNow,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: Text(tr('buy_now_button')),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _isDeleting ? null : () => _deleteAlert(item),
            icon: _isDeleting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
            label: Text(tr('delete_alert_button')),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
