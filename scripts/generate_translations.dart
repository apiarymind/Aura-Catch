import 'dart:io';
import 'dart:convert';

void main() async {
  final locales = [
    'pl', 'en-US', 'en-GB', 'de', 'fr', 'it', 'es', 'de-CH', 'nb', 'is', 'uk',
    'nl', 'nl-BE', 'de-AT', 'cs', 'sk', 'sv', 'da', 'fi', 'en-IE', 'pt', 'el',
    'hu', 'ro', 'bg', 'hr', 'lt', 'lv', 'et', 'sl', 'fr-LU'
  ];

  // We are running from the workspace root or the flutter directory
  final targetDir = Directory('assets/translations');
  if (!await targetDir.exists()) {
    await targetDir.create(recursive: true);
  }

  final defaultTranslations = {
    'edit_details': 'Confirm & Edit Details',
    'brand': 'Brand',
    'model': 'Model',
    'target_price': 'Target Price',
    'condition': 'Condition',
    'cancel': 'Cancel',
    'confirm': 'Confirm'
  };

  final plTranslations = {
    'edit_details': 'Potwierdź i edytuj szczegóły',
    'brand': 'Marka',
    'model': 'Model',
    'target_price': 'Cena docelowa',
    'condition': 'Stan',
    'cancel': 'Anuluj',
    'confirm': 'Potwierdź'
  };

  for (final locale in locales) {
    final file = File('${targetDir.path}/$locale.json');
    final Map<String, String> translation = (locale == 'pl') ? plTranslations : defaultTranslations;
    
    final Map<String, String> localized = translation.map((key, value) {
      if (locale != 'pl' && locale != 'en-US') {
        return MapEntry(key, '[$locale] $value');
      }
      return MapEntry(key, value);
    });

    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(localized));
    print('Generated ${file.path}');
  }
  print('Successfully generated all 31 translation files!');
}
