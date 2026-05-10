import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/theme_provider.dart';

class AuraLogo extends ConsumerWidget {
  final double size;
  final bool showWordmark;
  final TextStyle? wordmarkStyle;
  final double wordmarkSpacing;

  const AuraLogo({
    super.key,
    this.size = 36,
    this.showWordmark = true,
    this.wordmarkStyle,
    this.wordmarkSpacing = 8,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSkin = ref.watch(themeProvider);
    final theme = Theme.of(context);

    final logo = Image.asset(
      _logoAssetForSkin(activeSkin),
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (!showWordmark) {
      return logo;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        SizedBox(height: wordmarkSpacing),
        Text(
          'Aura Catch',
          style:
              wordmarkStyle ??
              theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }

  String _logoAssetForSkin(AppThemeSkin skin) {
    switch (skin) {
      case AppThemeSkin.hunter:
        return 'assets/images/logo_hunter.png';
      case AppThemeSkin.style:
        return 'assets/images/logo_style.png';
      case AppThemeSkin.original:
        return 'assets/images/logo_original.png';
    }
  }
}
