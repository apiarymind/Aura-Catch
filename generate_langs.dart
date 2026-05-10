import 'dart:io';
import 'dart:convert';

void main() async {
  final locales = [
    'pl', 'en-US', 'en-GB', 'de', 'fr', 'it', 'es', 'de-CH', 'no', 'is', 'uk',
    'nl', 'nl-BE', 'de-AT', 'cs', 'sk', 'sv', 'da', 'fi', 'en-IE', 'pt', 'el',
    'hu', 'ro', 'bg', 'hr', 'lt', 'lv', 'et', 'sl', 'fr-LU'
  ];

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
    'confirm': 'Confirm',
    'volume_ml': 'Volume (ml)',
    'extract_info_image': 'Extract info from this image',
    'failed_camera': 'Failed to open camera: {}',
    'item_added_success': 'Item added to tracking list!',
    'analyzing_with_gemini': 'Analyzing with Gemini...',
    'error': 'Error',
    'error_details': 'Error: {}',
    'close': 'Close',
    'app_title': 'Aura Catch',
    'mic_placeholder': 'RTX 5090 used under \$1000',
    'no_items': 'No tracked items yet. Search for something!',
    'item_deleted': '{} {} deleted',
    'error_loading_items': 'Error loading items: {}',
    'showing_ad': 'Showing ad...',
    'what_are_you_looking_for': 'What are you looking for?',
    'failed_save': 'Failed to save: {}',
    // Auth translations
    'email': 'Email',
    'logout': 'Sign Out',
    'password': 'Password',
    'login_button': 'Sign In',
    'register_button': 'Sign Up',
    'sign_in_google': 'Sign In with Google',
    'sign_in_apple': 'Sign In with Apple',
    'dont_have_account': "Don't have an account? Sign Up",
    'already_have_account': 'Already have an account? Sign In',
    'invalid_email': 'Please enter a valid email address',
    'invalid_password': 'Password must be at least 6 characters',
    'auth_error': 'Authentication Error'
  };

  final plTranslations = {
    'edit_details': 'Potwierdź i edytuj szczegóły',
    'brand': 'Marka',
    'model': 'Model',
    'target_price': 'Cena docelowa',
    'condition': 'Stan',
    'cancel': 'Anuluj',
    'confirm': 'Potwierdź',
    'volume_ml': 'Pojemność (ml)',
    'extract_info_image': 'Wyodrębnij informacje z tego obrazu',
    'failed_camera': 'Nie udało się otworzyć aparatu: {}',
    'item_added_success': 'Przedmiot dodany do listy śledzenia!',
    'analyzing_with_gemini': 'Analizowanie przez Gemini...',
    'error': 'Błąd',
    'error_details': 'Błąd: {}',
    'close': 'Zamknij',
    'app_title': 'Aura Catch',
    'mic_placeholder': 'RTX 5090 używany poniżej \$1000',
    'no_items': 'Brak śledzonych przedmiotów. Wyszukaj coś!',
    'item_deleted': '{} {} usunięty',
    'error_loading_items': 'Błąd wczytywania przedmiotów: {}',
    'showing_ad': 'Wyświetlanie reklamy...',
    'what_are_you_looking_for': 'Czego szukasz?',
    'failed_save': 'Nie udało się zapisać: {}',
    // Auth translations
    'email': 'Email',
    'logout': 'Wyloguj się',
    'password': 'Hasło',
    'login_button': 'Zaloguj się',
    'register_button': 'Zarejestruj się',
    'sign_in_google': 'Zaloguj się przez Google',
    'sign_in_apple': 'Zaloguj się przez Apple',
    'dont_have_account': 'Nie masz konta? Zarejestruj się',
    'already_have_account': 'Masz już konto? Zaloguj się',
    'invalid_email': 'Wpisz poprawny adres email',
    'invalid_password': 'Hasło musi mieć co najmniej 6 znaków',
    'auth_error': 'Błąd uwierzytelniania'
  };

  // Helper function to write translations to a file safely
  Future<void> writeJsonFile(String name, Map<String, String> data) async {
    final file = File('${targetDir.path}/$name.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    print('Generated: ${file.absolute.path}');
  }

  for (final locale in locales) {
    final Map<String, String> baseTranslation = (locale.startsWith('pl')) ? plTranslations : defaultTranslations;
    
    // Add testing prefix for non-primary locales
    final Map<String, String> finalizedTranslation = baseTranslation.map((key, value) {
      if (locale != 'pl' && locale != 'en-US') {
        return MapEntry(key, '[$locale] $value');
      }
      return MapEntry(key, value);
    });

    // Write primary locale file (e.g. pl.json, de.json, en-US.json)
    await writeJsonFile(locale, finalizedTranslation);

    // If compound locale has hyphen (e.g. en-US), generate the underscore version (e.g. en_US.json)
    if (locale.contains('-')) {
      final underscoreName = locale.replaceAll('-', '_');
      await writeJsonFile(underscoreName, finalizedTranslation);

      // Also generate base language-only file (e.g. en.json for en-US) as highly recommended fallback
      final baseLang = locale.split('-')[0];
      await writeJsonFile(baseLang, finalizedTranslation);
    }
  }
  print('\nSuccessfully generated all localization files (including Underscore & Base Fallbacks)!');
}
