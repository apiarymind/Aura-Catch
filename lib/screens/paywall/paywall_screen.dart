import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../providers/localization_provider.dart';
import '../../services/auth_service.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  CustomerInfo? _customerInfo;
  Package? _monthlyPackage;
  bool _isLoadingOffering = true;
  bool _isPurchasing = false;

  bool get _isPro => _customerInfo?.entitlements.all['pro']?.isActive == true;

  static const List<Map<String, dynamic>> _proBenefits = [
    {
      'icon': Icons.stars_rounded,
      'text': 'Maks. 10 aktywnych slotów na produkty',
    },
    {
      'icon': Icons.swap_horiz_rounded,
      'text': 'Pełna elastyczność: usuwaj i dodawaj w każdej chwili',
    },
    {
      'icon': Icons.all_inclusive_rounded,
      'text': 'Nielimitowany (brak wygasania)',
    },
    {
      'icon': Icons.speed_rounded,
      'text': 'Skanowanie priorytetowe (wielokrotnie dziennie)',
    },
    {
      'icon': Icons.public_rounded,
      'text': '31 rynków globalnych',
    },
    {
      'icon': Icons.block_rounded,
      'text': '100% Bez reklam (Ad-Free)',
    },
    {
      'icon': Icons.notifications_active_rounded,
      'text': 'Priorytetowe, natychmiastowe powiadomienia o spadkach',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadOffering();
  }

  Future<void> _loadOffering() async {
    setState(() {
      _isLoadingOffering = true;
    });

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      Package? monthly;

      if (current != null) {
        for (final pkg in current.availablePackages) {
          final id = pkg.identifier.toLowerCase();
          if (pkg.packageType == PackageType.monthly || id.contains('month')) {
            monthly = pkg;
            break;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _customerInfo = customerInfo;
        _monthlyPackage = monthly;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load subscription options.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOffering = false;
        });
      }
    }
  }

  Future<void> _purchasePackage(Package? package) async {
    if (package == null || _isPurchasing) {
      return;
    }

    setState(() {
      _isPurchasing = true;
    });

    try {
      final info = await Purchases.purchasePackage(package);
      if (!mounted) return;
      setState(() {
        _customerInfo = info;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subscription activated.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  Future<void> _restorePurchases() async {
    if (_isPurchasing) {
      return;
    }

    setState(() {
      _isPurchasing = true;
    });

    try {
      final info = await Purchases.restorePurchases();
      if (!mounted) return;
      setState(() {
        _customerInfo = info;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchases restored.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authServiceProvider).currentUser;
    final requiresLogin = user == null || user.isAnonymous;
    final strings = ref.watch(localizationProvider);
    final monthlyLabel = _monthlyPackage?.storeProduct.priceString ?? '5.99 PLN';

    void guardLoginThen(VoidCallback onAllowed) {
      if (requiresLogin) {
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

      onAllowed();
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.premium)),
      body: _isPro
          ? Center(child: Text(strings.youArePro, style: const TextStyle(fontSize: 24)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  strings.unlockPro,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Polecany',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Plan PRO',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '5.99 PLN/mc',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          '30 dni próbnych gratis',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ..._proBenefits.map(
                  (benefit) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          benefit['icon'] as IconData,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            benefit['text'] as String,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (_isLoadingOffering) ...[
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 20),
                ],
                ElevatedButton(
                  onPressed: _isPurchasing
                      ? null
                      : () => guardLoginThen(() => _purchasePackage(_monthlyPackage)),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  child: Text('5.99 PLN / month ($monthlyLabel)'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isPurchasing ? null : _restorePurchases,
                  child: const Text('Restore Purchases'),
                ),
              ],
            ),
    );
  }
}
