import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.6);
    final policyBody = 'legal.privacy.body'.tr();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text('legal.privacy.appbar_title'.tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'legal.privacy.page_title'.tr(),
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'legal.privacy.effective_date'.tr(),
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'legal.privacy.document_version'.tr(),
              style: bodyStyle,
            ),
            const SizedBox(height: 20),
            SelectableText(
              policyBody,
              style: bodyStyle,
            ),
          ],
        ),
      ),
    );
  }
}
