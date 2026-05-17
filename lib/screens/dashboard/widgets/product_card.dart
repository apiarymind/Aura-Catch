import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/tracked_item.dart';
import '../../../models/item_scope_attributes.dart';
import '../../../providers/link_generator_provider.dart';
import '../../../providers/localization_provider.dart';
import '../../../providers/region_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/demo_dialogs.dart';

class ProductCard extends ConsumerWidget {
  final TrackedItem item;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.item, required this.onTap});

  String _t(
    String key, {
    List<String>? args,
    Map<String, String>? namedArgs,
  }) {
    try {
      return tr(key, args: args, namedArgs: namedArgs);
    } catch (_) {
      return key;
    }
  }

  bool _requiresLogin(User? user) {
    if (user == null) return true;
    final email = user.email?.trim() ?? '';
    return user.isAnonymous || email.isEmpty;
  }

  Future<void> _handleBuyPress(BuildContext context, WidgetRef ref) async {
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

    // Parse scopes from JSONB attributes to find the best available URL.
    final scopeAttrs = ItemScopeAttributes.fromAttributesMap(item.attributes);
    final bestRawUrl = scopeAttrs.resolveBestBuyUrl() ?? item.productUrl;
    final isGoogleShopping = scopeAttrs.bestUrlIsGoogleShopping();

    Uri? launchUri;

    if (bestRawUrl != null && bestRawUrl.isNotEmpty) {
      if (isGoogleShopping) {
        debugPrint('[BuyNow] Google Shopping URL — opening directly: $bestRawUrl');
        launchUri = Uri.tryParse(bestRawUrl);
      } else {
        final region = ref.read(regionProvider);
        launchUri = ref.read(linkGeneratorServiceProvider).buildMonetizedLink(
          storeName: item.storeName,
          region: region,
          brand: item.brand,
          model: item.model,
          rawProductUrl: bestRawUrl,
        );
        debugPrint('[BuyNow] Affiliate link: $launchUri');
      }
    }

    if (launchUri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t('no_link_available'))),
        );
      }
      return;
    }

    final launched = await launchUrl(launchUri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('error'))),
      );
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.openingLink)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentRegion = ref.watch(regionProvider);
    final currencyPrefix = currencyPrefixForRegion(currentRegion);
    final plan = ref.watch(subscriptionProvider).plan;
    final isFreePlan = plan == AccountPlan.free;
    final isLocked = item.status.toUpperCase() == 'LOCKED';
    final displayedCurrentPrice = item.currentPrice ?? item.targetPrice;
    final isDeal = displayedCurrentPrice < item.targetPrice;
    final saveAmount = isDeal ? (item.targetPrice - displayedCurrentPrice) : 0.0;

    final trackingDuration = DateTime.now().toUtc().difference(item.addedAt.toUtc());
    final trackingDays = trackingDuration.inDays;
    final remainingForFree = const Duration(days: 30) - trackingDuration;

    final hasKnownStore = item.storeName.trim().isNotEmpty && item.storeName.trim().toLowerCase() != 'pending...';
    final isStoreVerified = hasKnownStore;

    final isDemo = kIsWeb && item.id.startsWith('demo_');

    final card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.brand,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isDemo) ...[                
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'SYMULACJA • WERSJA DEMO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 2),
              Text(
                item.model,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('current_price_label'),
                            style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$currencyPrefix${displayedCurrentPrice.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isDeal ? colorScheme.primary : colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isDeal)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
              ),
              const SizedBox(height: 10),
              Text(
                _t(
                  'target_price_label',
                  namedArgs: {'price': '$currencyPrefix${item.targetPrice.toStringAsFixed(2)}'},
                ),
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                item.lowestPrice180d == null
                    ? _t('lowest_180_label_pending')
                    : _t(
                        'lowest_180_label',
                        namedArgs: {'price': '$currencyPrefix${item.lowestPrice180d!.toStringAsFixed(2)}'},
                      ),
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                _t('tracking_for_days', namedArgs: {'days': '$trackingDays'}),
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              if (isFreePlan)
                Text(
                  remainingForFree.isNegative
                      ? _t('free_window_expired')
                      : _t('free_window_left_days', namedArgs: {'days': '${remainingForFree.inDays}'}),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: remainingForFree.isNegative ? colorScheme.error : colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    isStoreVerified ? Icons.security : Icons.warning_amber_rounded,
                    size: 18,
                    color: isStoreVerified ? Colors.green : Colors.amber.shade700,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${item.storeName} • ${isStoreVerified ? _t('store_verified') : _t('store_unknown')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLocked ? null : () => _handleBuyPress(context, ref),
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: Text(_t('buy_button')),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!isLocked) {
      return card;
    }

    return Stack(
      children: [
        Opacity(opacity: 0.5, child: card),
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, size: 56, color: colorScheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    _t('item_locked_label'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/premium'),
                    icon: const Icon(Icons.workspace_premium),
                    label: Text(_t('unlock_with_pro')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
