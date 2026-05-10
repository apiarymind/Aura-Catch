import 'package:flutter_riverpod/flutter_riverpod.dart';

final List<String> regionsList = [
  'Polska (+48)',
  'USA (+1)',
  'Wielka Brytania (+44)',
  'Niemcy (+49)',
  'Francja (+33)',
  'Włochy (+39)',
  'Hiszpania (+34)',
  'Szwajcaria (+41)',
  'Norwegia (+47)',
  'Islandia (+354)',
  'Ukraina (+380)',
  'Holandia (+31)',
  'Belgia (+32)',
  'Austria (+43)',
  'Czechy (+420)',
  'Słowacja (+421)',
  'Szwecja (+46)',
  'Dania (+45)',
  'Finlandia (+358)',
  'Irlandia (+353)',
  'Portugalia (+351)',
  'Grecja (+30)',
  'Węgry (+36)',
  'Rumunia (+40)',
  'Bułgaria (+359)',
  'Chorwacja (+385)',
  'Litwa (+370)',
  'Łotwa (+371)',
  'Estonia (+372)',
  'Słowenia (+386)',
  'Luksemburg (+352)'
];

String currencyPrefixForRegion(String region) {
  switch (region) {
    case 'Polska (+48)':
      return 'PLN ';
    case 'USA (+1)':
      return r'$ ';
    case 'Wielka Brytania (+44)':
      return '£ ';
    case 'Szwajcaria (+41)':
      return 'CHF ';
    case 'Norwegia (+47)':
      return 'NOK ';
    case 'Islandia (+354)':
      return 'ISK ';
    case 'Ukraina (+380)':
      return 'UAH ';
    case 'Czechy (+420)':
      return 'CZK ';
    case 'Szwecja (+46)':
      return 'SEK ';
    case 'Dania (+45)':
      return 'DKK ';
    case 'Węgry (+36)':
      return 'HUF ';
    case 'Rumunia (+40)':
      return 'RON ';
    case 'Bułgaria (+359)':
      return 'BGN ';
    case 'Niemcy (+49)':
    case 'Francja (+33)':
    case 'Włochy (+39)':
    case 'Hiszpania (+34)':
    case 'Holandia (+31)':
    case 'Belgia (+32)':
    case 'Austria (+43)':
    case 'Słowacja (+421)':
    case 'Finlandia (+358)':
    case 'Irlandia (+353)':
    case 'Portugalia (+351)':
    case 'Grecja (+30)':
    case 'Chorwacja (+385)':
    case 'Litwa (+370)':
    case 'Łotwa (+371)':
    case 'Estonia (+372)':
    case 'Słowenia (+386)':
    case 'Luksemburg (+352)':
      return '€ ';
    default:
      return r'$ ';
  }
}

class RegionNotifier extends Notifier<String> {
  @override
  String build() {
    return 'Polska (+48)'; // default region
  }

  void setRegion(String newRegion) {
    state = newRegion;
  }
}

final regionProvider = NotifierProvider<RegionNotifier, String>(() {
  return RegionNotifier();
});
