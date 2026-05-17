import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../widgets/aura_logo.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = _LandingColorTokens.fromTheme(theme);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          final horizontalPadding = isDesktop ? 72.0 : 20.0;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [tokens.pageGradientStart, tokens.pageGradientEnd],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: isDesktop ? 48 : 28,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Aura',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: isDesktop ? 38 : 30,
                                        color: tokens.brandText,
                                      ),
                                    ),
                                    SizedBox(width: isDesktop ? 10 : 8),
                                    AuraLogo(
                                      size: isDesktop ? 100 : 80,
                                      showWordmark: false,
                                    ),
                                    SizedBox(width: isDesktop ? 10 : 8),
                                    Text(
                                      'Catch',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: isDesktop ? 38 : 30,
                                        color: tokens.brandText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: isDesktop ? 34 : 24),
                              _HeroSection(isDesktop: isDesktop),
                              SizedBox(height: isDesktop ? 32 : 24),
                              _TrustedPartnersSection(theme: theme, isDesktop: isDesktop),
                              SizedBox(height: isDesktop ? 32 : 24),
                              _MarketsFlagsSection(theme: theme, isDesktop: isDesktop),
                              SizedBox(height: isDesktop ? 56 : 36),
                              _CategoriesSection(theme: theme, isDesktop: isDesktop),
                              SizedBox(height: isDesktop ? 64 : 40),
                              _FeaturesSection(theme: theme, isDesktop: isDesktop),
                              SizedBox(height: isDesktop ? 64 : 40),
                              _PricingTableSection(theme: theme, isDesktop: isDesktop),
                              SizedBox(height: isDesktop ? 64 : 40),
                              _ThemesShowcaseSection(theme: theme, isDesktop: isDesktop),
                              SizedBox(height: isDesktop ? 64 : 40),
                              _FaqSection(theme: theme),
                              SizedBox(height: isDesktop ? 56 : 36),
                              _ComingSoonSection(theme: theme, isDesktop: isDesktop),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _Footer(theme: theme),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LandingColorTokens {
  final Color pageGradientStart;
  final Color pageGradientEnd;
  final Color heroBackground;
  final Color heroShadow;
  final Color brandText;
  final Color heroHeading;
  final Color heroSubheading;
  final Color sectionHeading;
  final Color featureCardBackground;
  final Color featureCardBorder;
  final Color featureIconBackground;
  final Color featureIconColor;
  final Color featureTitle;
  final Color featureBody;
  final Color footerBackground;
  final Color footerText;
  final Color footerLink;

  const _LandingColorTokens({
    required this.pageGradientStart,
    required this.pageGradientEnd,
    required this.heroBackground,
    required this.heroShadow,
    required this.brandText,
    required this.heroHeading,
    required this.heroSubheading,
    required this.sectionHeading,
    required this.featureCardBackground,
    required this.featureCardBorder,
    required this.featureIconBackground,
    required this.featureIconColor,
    required this.featureTitle,
    required this.featureBody,
    required this.footerBackground,
    required this.footerText,
    required this.footerLink,
  });

  factory _LandingColorTokens.fromTheme(ThemeData theme) {
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return _LandingColorTokens(
      pageGradientStart: theme.scaffoldBackgroundColor,
      pageGradientEnd: scheme.surface,
      heroBackground: scheme.surface,
      heroShadow: scheme.shadow.withValues(alpha: isDark ? 0.36 : 0.12),
      brandText: scheme.onSurface,
      heroHeading: scheme.onSurface,
      heroSubheading: scheme.onSurface.withValues(alpha: 0.78),
      sectionHeading: scheme.onSurface,
      featureCardBackground: scheme.surface,
      featureCardBorder: scheme.outline.withValues(alpha: isDark ? 0.48 : 0.32),
      featureIconBackground: scheme.primary.withValues(alpha: isDark ? 0.24 : 0.12),
      featureIconColor: scheme.primary,
      featureTitle: scheme.onSurface,
      featureBody: scheme.onSurface.withValues(alpha: 0.75),
      footerBackground: scheme.primary,
      footerText: scheme.onPrimary.withValues(alpha: 0.86),
      footerLink: scheme.onPrimary,
    );
  }
}

class _HeroSection extends StatelessWidget {
  final bool isDesktop;

  const _HeroSection({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = _LandingColorTokens.fromTheme(theme);

    return Container(
      padding: EdgeInsets.all(isDesktop ? 44 : 24),
      decoration: BoxDecoration(
        color: tokens.heroBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: tokens.heroShadow,
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                Text(
                  'landing.hero_title'.tr(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    fontSize: isDesktop ? 42 : 28,
                    color: tokens.heroHeading,
                  ),
                ),
                SizedBox(height: isDesktop ? 24 : 18),
                Text.rich(
                  TextSpan(
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: isDesktop ? 20 : 16,
                      height: 1.55,
                      color: tokens.heroSubheading,
                    ),
                    children: [
                      TextSpan(text: 'landing.desc_p1'.tr()),
                      TextSpan(
                        text: 'landing.desc_bold1'.tr(), 
                        style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                      TextSpan(text: 'landing.desc_p2'.tr()),
                      TextSpan(
                        text: 'landing.desc_bold2'.tr(), 
                        style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                      TextSpan(text: 'landing.desc_p3'.tr()),
                      TextSpan(
                        text: 'landing.desc_bold3'.tr(), 
                        style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: isDesktop ? 30 : 22),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 28 : 20,
                    vertical: isDesktop ? 18 : 14,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('landing.btn_open_app'.tr()),
              ),
              OutlinedButton(
                onPressed: () => context.go('/login'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 28 : 20,
                    vertical: isDesktop ? 18 : 14,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('landing.btn_login'.tr()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrustedPartnersSection extends StatelessWidget {
  final ThemeData theme;
  final bool isDesktop;

  const _TrustedPartnersSection({required this.theme, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final headingGreen = isDark ? const Color(0xFF81E39C) : const Color(0xFF1F7D3B);
    final chipBorder = scheme.outline.withValues(alpha: isDark ? 0.34 : 0.2);
    final chipBackground = scheme.surface.withValues(alpha: isDark ? 0.78 : 0.95);

    const partners = [
      'Allegro',
      'Amazon',
      'Media Expert',
      'Sephora',
      'Zalando',
      'Notino',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'landing.trusted_partners_title'.tr(),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: headingGreen,
            fontSize: isDesktop ? 34 : 24,
            height: 1.2,
          ),
        ),
        SizedBox(height: isDesktop ? 24 : 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final partner in partners)
              _PartnerChip(
                label: partner,
                borderColor: chipBorder,
                backgroundColor: chipBackground,
                textColor: scheme.onSurface,
                isDesktop: isDesktop,
              ),
          ],
        ),
        SizedBox(height: isDesktop ? 20 : 14),
        Text(
          'landing.trusted_partners_subtitle'.tr(),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: headingGreen,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _PartnerChip extends StatelessWidget {
  final String label;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;
  final bool isDesktop;

  const _PartnerChip({
    required this.label,
    required this.borderColor,
    required this.backgroundColor,
    required this.textColor,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 16 : 12,
        vertical: isDesktop ? 10 : 8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.storefront_outlined,
            size: isDesktop ? 18 : 16,
            color: textColor,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
          ),
        ],
      ),
    );
  }
}

class _MarketsFlagsSection extends StatelessWidget {
  final ThemeData theme;
  final bool isDesktop;

  const _MarketsFlagsSection({required this.theme, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    const markets = [
      (flag: '🇵🇱', name: 'Polska'),
      (flag: '🇺🇸', name: 'United States'),
      (flag: '🇬🇧', name: 'United Kingdom'),
      (flag: '🇩🇪', name: 'Deutschland'),
      (flag: '🇫🇷', name: 'France'),
      (flag: '🇮🇹', name: 'Italia'),
      (flag: '🇪🇸', name: 'España'),
      (flag: '🇨🇭', name: 'Schweiz'),
      (flag: '🇳🇴', name: 'Norge'),
      (flag: '🇮🇸', name: 'Ísland'),
      (flag: '🇺🇦', name: 'Україна'),
      (flag: '🇳🇱', name: 'Nederland'),
      (flag: '🇧🇪', name: 'België'),
      (flag: '🇦🇹', name: 'Österreich'),
      (flag: '🇨🇿', name: 'Česko'),
      (flag: '🇸🇰', name: 'Slovensko'),
      (flag: '🇸🇪', name: 'Sverige'),
      (flag: '🇩🇰', name: 'Danmark'),
      (flag: '🇫🇮', name: 'Suomi'),
      (flag: '🇮🇪', name: 'Éire'),
      (flag: '🇵🇹', name: 'Portugal'),
      (flag: '🇬🇷', name: 'Ελλάδα'),
      (flag: '🇭🇺', name: 'Magyarország'),
      (flag: '🇷🇴', name: 'România'),
      (flag: '🇧🇬', name: 'България'),
      (flag: '🇭🇷', name: 'Hrvatska'),
      (flag: '🇱🇹', name: 'Lietuva'),
      (flag: '🇱🇻', name: 'Latvija'),
      (flag: '🇪🇪', name: 'Eesti'),
      (flag: '🇸🇮', name: 'Slovenija'),
      (flag: '🇱🇺', name: 'Lëtzebuerg'),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 16 : 12, vertical: isDesktop ? 12 : 10),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: isDark ? 0.64 : 0.84),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline.withValues(alpha: isDark ? 0.34 : 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'landing.markets_title'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1000
                  ? 4
                  : constraints.maxWidth >= 700
                      ? 3
                      : 2;
              const spacing = 8.0;
              final itemWidth = (constraints.maxWidth - (columns - 1) * spacing) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final market in markets)
                    SizedBox(
                      width: itemWidth,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: isDark ? 0.16 : 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: scheme.outline.withValues(alpha: isDark ? 0.28 : 0.16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(market.flag, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                market.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurface.withValues(alpha: 0.88),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  final ThemeData theme;
  final bool isDesktop;

  const _FeaturesSection({required this.theme, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final tokens = _LandingColorTokens.fromTheme(theme);
    final cards = [
      _FeatureData(
        icon: Icons.auto_awesome,
        title: 'landing.f_ai_title'.tr(),
        description: 'landing.f_ai_desc'.tr(),
      ),
      _FeatureData(
        icon: Icons.public,
        title: 'landing.f_global_title'.tr(),
        description: 'landing.f_global_desc'.tr(),
      ),
      _FeatureData(
        icon: Icons.notifications_active,
        title: 'landing.f_alerts_title'.tr(),
        description: 'landing.f_alerts_desc'.tr(),
      ),
      _FeatureData(
        icon: Icons.history,
        title: 'landing.f_omnibus_title'.tr(),
        description: 'landing.f_omnibus_desc'.tr(),
      ),
      _FeatureData(
        icon: Icons.filter_alt,
        title: 'landing.f_filters_title'.tr(),
        description: 'landing.f_filters_desc'.tr(),
      ),
      _FeatureData(
        icon: Icons.info_outline,
        title: 'landing.f_customs_title'.tr(),
        description: 'landing.f_customs_desc'.tr(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'landing.features_title'.tr(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: tokens.sectionHeading,
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1000
                ? 3
                : constraints.maxWidth >= 640
                    ? 2
                    : 1;
            const spacing = 16.0;
            final cardWidth = (constraints.maxWidth - (columns - 1) * spacing) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final card in cards)
                  SizedBox(
                    width: cardWidth,
                    child: _FeatureCard(data: card),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ThemesShowcaseSection extends StatelessWidget {
  final ThemeData theme;
  final bool isDesktop;

  const _ThemesShowcaseSection({required this.theme, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _ThemeShowcaseData(
        imagePath: 'assets/images/1.png',
        title: 'landing.t_style_title'.tr(),
        description: 'landing.t_style_desc'.tr(),
      ),
      _ThemeShowcaseData(
        imagePath: 'assets/images/2.png',
        title: 'landing.t_hunter_title'.tr(),
        description: 'landing.t_hunter_desc'.tr(),
      ),
      _ThemeShowcaseData(
        imagePath: 'assets/images/3.png',
        title: 'landing.t_original_title'.tr(),
        description: 'landing.t_original_desc'.tr(),
      ),
    ];

    final tokens = _LandingColorTokens.fromTheme(theme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'landing.themes_title'.tr(),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: tokens.sectionHeading,
          ),
        ),
        SizedBox(height: isDesktop ? 26 : 18),
        isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    Expanded(child: _ThemeShowcaseCard(data: cards[i], isDesktop: isDesktop)),
                    if (i < cards.length - 1) const SizedBox(width: 16),
                  ],
                ],
              )
            : Column(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    _ThemeShowcaseCard(data: cards[i], isDesktop: isDesktop),
                    if (i < cards.length - 1) const SizedBox(height: 14),
                  ],
                ],
              ),
      ],
    );
  }
}

class _FaqSection extends StatelessWidget {
  final ThemeData theme;

  const _FaqSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final items = [
      (
        question: 'landing.faq_q1'.tr(),
        answer: 'landing.faq_a1'.tr(),
      ),
      (
        question: 'landing.faq_q2'.tr(),
        answer: 'landing.faq_a2'.tr(),
      ),
      (
        question: 'landing.faq_q3'.tr(),
        answer: 'landing.faq_a3'.tr(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'landing.faq_title'.tr(),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.outline.withValues(alpha: isDark ? 0.44 : 0.28)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                Theme(
                  data: theme.copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    iconColor: scheme.primary,
                    collapsedIconColor: scheme.onSurface.withValues(alpha: 0.7),
                    title: Text(
                      items[i].question,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          items[i].answer,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.8),
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: scheme.outline.withValues(alpha: isDark ? 0.32 : 0.2),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ComingSoonSection extends StatelessWidget {
  final ThemeData theme;
  final bool isDesktop;

  const _ComingSoonSection({required this.theme, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final scheme = theme.colorScheme;

    return Column(
      children: [
        Text(
          'landing.soon_title'.tr(),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            _ComingSoonBadge(icon: Icons.android, label: 'landing.soon_google'.tr()),
            _ComingSoonBadge(icon: Icons.apple, label: 'landing.soon_apple'.tr()),
          ],
        ),
      ],
    );
  }
}

class _ComingSoonBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ComingSoonBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Opacity(
      opacity: 0.72,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outline.withValues(alpha: isDark ? 0.48 : 0.26)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: scheme.onSurface.withValues(alpha: 0.7)),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -6,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: isDark ? 0.8 : 0.74),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'landing.soon_badge'.tr(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeShowcaseData {
  final String imagePath;
  final String title;
  final String description;

  const _ThemeShowcaseData({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

class _ThemeShowcaseCard extends StatelessWidget {
  final _ThemeShowcaseData data;
  final bool isDesktop;

  const _ThemeShowcaseCard({required this.data, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = _LandingColorTokens.fromTheme(theme);
    final phoneHeight = isDesktop ? 320.0 : 360.0;
    final phoneWidth = phoneHeight * 0.48;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: tokens.featureCardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.featureCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: phoneWidth,
              height: phoneHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: tokens.featureCardBorder),
                boxShadow: [
                  BoxShadow(
                    color: tokens.heroShadow,
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Image.asset(data.imagePath, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            data.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: tokens.featureTitle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: tokens.featureBody,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CATEGORIES SECTION
// ─────────────────────────────────────────────

class _CategoriesSection extends StatelessWidget {
  final ThemeData theme;
  final bool isDesktop;

  const _CategoriesSection({required this.theme, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final tokens = _LandingColorTokens.fromTheme(theme);
    final scheme = theme.colorScheme;

    final categories = [
      (
        icon: Icons.devices,
        titleKey: 'landing.cat_1_title',
        descKey: 'landing.cat_1_desc',
      ),
      (
        icon: Icons.kitchen,
        titleKey: 'landing.cat_2_title',
        descKey: 'landing.cat_2_desc',
      ),
      (
        icon: Icons.watch,
        titleKey: 'landing.cat_3_title',
        descKey: 'landing.cat_3_desc',
      ),
      (
        icon: Icons.sports_esports,
        titleKey: 'landing.cat_4_title',
        descKey: 'landing.cat_4_desc',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'landing.cat_title'.tr(),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: tokens.sectionHeading,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'landing.cat_subtitle'.tr(),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.65),
            height: 1.5,
          ),
        ),
        SizedBox(height: isDesktop ? 26 : 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 700 ? 4 : 2;
            const spacing = 14.0;
            final cardWidth =
                (constraints.maxWidth - (columns - 1) * spacing) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final cat in categories)
                  SizedBox(
                    width: cardWidth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: tokens.featureCardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: tokens.featureCardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: tokens.featureIconBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              cat.icon,
                              size: 24,
                              color: tokens.featureIconColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            cat.titleKey.tr(),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: tokens.featureTitle,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat.descKey.tr(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: tokens.featureBody,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// PRICING TABLE SECTION
// ─────────────────────────────────────────────

class _PricingTableSection extends StatefulWidget {
  final ThemeData theme;
  final bool isDesktop;

  const _PricingTableSection({required this.theme, required this.isDesktop});

  @override
  State<_PricingTableSection> createState() => _PricingTableSectionState();
}

class _PricingTableSectionState extends State<_PricingTableSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rows = [
      (
        feature: 'landing.p_f1_title'.tr(),
        free: 'landing.p_f1_free'.tr(),
        pro: 'landing.p_f1_pro'.tr(),
        freeIcon: Icons.hourglass_bottom,
        proIcon: Icons.workspace_premium,
      ),
      (
        feature: 'landing.p_f2_title'.tr(),
        free: 'landing.p_f2_free'.tr(),
        pro: 'landing.p_f2_pro'.tr(),
        freeIcon: Icons.lock_clock,
        proIcon: Icons.swap_horiz,
      ),
      (
        feature: 'landing.p_f3_title'.tr(),
        free: 'landing.p_f3_free'.tr(),
        pro: 'landing.p_f3_pro'.tr(),
        freeIcon: Icons.calendar_today_outlined,
        proIcon: Icons.all_inclusive,
      ),
      (
        feature: 'landing.p_f3_scan_title'.tr(),
        free: 'landing.p_f3_scan_free'.tr(),
        pro: 'landing.p_f3_scan_pro'.tr(),
        freeIcon: Icons.schedule,
        proIcon: Icons.speed,
      ),
      (
        feature: 'landing.p_f4_title'.tr(),
        free: 'landing.p_f4_free'.tr(),
        pro: 'landing.p_f4_pro'.tr(),
        freeIcon: Icons.public,
        proIcon: Icons.public,
      ),
      (
        feature: 'landing.p_f5_title'.tr(),
        free: 'landing.p_f5_free'.tr(),
        pro: 'landing.p_f5_pro'.tr(),
        freeIcon: Icons.ads_click,
        proIcon: Icons.block,
      ),
      (
        feature: 'landing.p_f6_title'.tr(),
        free: 'landing.p_f6_free'.tr(),
        pro: 'landing.p_f6_pro'.tr(),
        freeIcon: Icons.notifications_outlined,
        proIcon: Icons.notifications_active,
      ),
    ];

    final theme = widget.theme;
    final isDesktop = widget.isDesktop;
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = scheme.outline.withValues(alpha: isDark ? 0.38 : 0.22);
    final headerBg = scheme.surface;
    final rowEvenBg = scheme.surfaceContainerLowest;
    final rowOddBg = scheme.surface;
    final proHighlight = scheme.primary.withValues(alpha: isDark ? 0.14 : 0.08);
    final proHeaderBg = scheme.primary.withValues(alpha: isDark ? 0.26 : 0.12);
    final proBorderColor = scheme.primary.withValues(alpha: isDark ? 0.72 : 0.5);

    Widget buildBadge() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'landing.p_recommended'.tr(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        );

    Widget buildHeaderCell(String text, {bool isPro = false}) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isPro ? proHeaderBg : headerBg,
            border: Border(
              bottom: BorderSide(color: isPro ? proBorderColor : borderColor, width: isPro ? 2 : 1),
              right: BorderSide(color: borderColor),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isPro) ...[buildBadge(), const SizedBox(height: 6)],
              Text(
                text,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isPro ? scheme.primary : scheme.onSurface,
                  fontSize: isDesktop ? 13 : 11,
                ),
              ),
            ],
          ),
        );

    Widget buildFeatureCell(String text, {required bool isEven}) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isEven ? rowEvenBg : rowOddBg,
            border: Border(
              bottom: BorderSide(color: borderColor),
              right: BorderSide(color: borderColor),
            ),
          ),
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
        );

    Widget buildCell(
      String text,
      IconData icon, {
      required bool isEven,
      required bool isPro,
      bool isLast = false,
    }) =>
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isPro
                ? proHighlight
                : (isEven ? rowEvenBg : rowOddBg),
            border: Border(
              bottom: isLast ? BorderSide.none : BorderSide(color: isPro ? proBorderColor.withValues(alpha: 0.4) : borderColor),
              right: BorderSide(color: isPro ? proBorderColor : borderColor, width: isPro ? 1.5 : 1),
              left: isPro ? BorderSide(color: proBorderColor, width: 1.5) : BorderSide.none,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 16,
                color: isPro ? scheme.primary : scheme.onSurface.withValues(alpha: 0.55),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isPro
                        ? scheme.onSurface
                        : scheme.onSurface.withValues(alpha: 0.78),
                    height: 1.4,
                    fontWeight: isPro ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        );

    // ── TABLE BUILD ──
    final table = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: isDark ? 0.28 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header row
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: buildHeaderCell('landing.p_header_func'.tr()),
                ),
                Expanded(
                  flex: 4,
                  child: buildHeaderCell('landing.p_header_free'.tr()),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: proHeaderBg,
                      border: Border(
                        bottom: BorderSide(color: proBorderColor, width: 2),
                        right: BorderSide(color: borderColor),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildBadge(),
                        const SizedBox(height: 6),
                        Text(
                          'landing.p_header_pro'.tr(),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.primary,
                            fontSize: isDesktop ? 13 : 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'landing.p_pro_price'.tr(),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.primary.withValues(alpha: 0.85),
                            fontSize: isDesktop ? 11 : 9,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: proBorderColor),
                          ),
                          child: Text(
                            'landing.p_pro_trial'.tr(),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: isDesktop ? 10 : 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Data rows
          for (var i = 0; i < rows.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: buildFeatureCell(rows[i].feature, isEven: i.isEven),
                  ),
                  Expanded(
                    flex: 4,
                    child: buildCell(
                      rows[i].free,
                      rows[i].freeIcon,
                      isEven: i.isEven,
                      isPro: false,
                      isLast: i == rows.length - 1,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: buildCell(
                      rows[i].pro,
                      rows[i].proIcon,
                      isEven: i.isEven,
                      isPro: true,
                      isLast: i == rows.length - 1,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'landing.pricing_title'.tr(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'landing.pricing_subtitle'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
        SizedBox(height: isDesktop ? 22 : 16),
        // Scrollable on mobile, full-width on desktop
        isDesktop
            ? table
            : ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: SizedBox(width: 760, child: table),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData data;

  const _FeatureCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = _LandingColorTokens.fromTheme(theme);

    return Container(
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(minHeight: 240),
      decoration: BoxDecoration(
        color: tokens.featureCardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.featureCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tokens.featureIconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: tokens.featureIconColor),
          ),
          const SizedBox(height: 14),
          Text(
            data.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: tokens.featureTitle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: tokens.featureBody,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final ThemeData theme;

  const _Footer({required this.theme});

  @override
  Widget build(BuildContext context) {
    final tokens = _LandingColorTokens.fromTheme(theme);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: tokens.footerBackground,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 14,
            runSpacing: 8,
            children: [
              Text(
                'landing.footer_copyright'.tr(args: ['${DateTime.now().year}']),
                style: theme.textTheme.bodySmall?.copyWith(color: tokens.footerText),
              ),
              Wrap(
                spacing: 10,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: tokens.footerLink),
                    onPressed: () => context.go('/privacy-policy'),
                    child: Text('landing.footer_privacy'.tr()),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: tokens.footerLink),
                    onPressed: () => context.go('/terms-of-service'),
                    child: Text('landing.footer_terms'.tr()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
