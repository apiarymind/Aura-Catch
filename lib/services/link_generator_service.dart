import 'package:flutter_dotenv/flutter_dotenv.dart';

class LinkGeneratorService {
  Uri buildMonetizedLink({
    required String storeName,
    required String region,
    required String brand,
    required String model,
    String? rawProductUrl,
  }) {
    final normalizedRegion = _normalizeRegion(region);
    final normalizedStore = storeName.trim().toLowerCase();
    final source = (rawProductUrl ?? '').trim();

    Uri? destination;
    _StoreConfig? matchedStore;

    if (source.isNotEmpty) {
      destination = _tryParseUrl(source);
      if (destination != null) {
        matchedStore = _findStoreByHost(normalizedRegion, destination.host.toLowerCase()) ??
            _findStoreByName(normalizedRegion, normalizedStore);
      }
    }

    destination ??= _buildFallbackSearchLink(
      regionCode: normalizedRegion,
      storeName: normalizedStore,
      brand: brand,
      model: model,
    );
    matchedStore ??= _findStoreByHost(normalizedRegion, destination.host.toLowerCase()) ??
        _findStoreByName(normalizedRegion, normalizedStore);

    final host = destination.host.toLowerCase();
    if (_isAmazonHost(host)) {
      return _amazonLink(destination);
    }
    if (_isEbayHost(host) || normalizedStore.contains('ebay')) {
      return _ebayLink(destination);
    }
    if (host.contains('allegro.')) {
      return _allegroLink(destination);
    }

    final network = matchedStore?.network ?? _regionDefaultNetwork[normalizedRegion] ?? _AffiliateNetwork.awin;
    switch (network) {
      case _AffiliateNetwork.amazon:
        return _amazonLink(destination);
      case _AffiliateNetwork.ebay:
        return _ebayLink(destination);
      case _AffiliateNetwork.awin:
        return _awinLink(destination);
      case _AffiliateNetwork.cj:
        return _cjLink(destination);
      case _AffiliateNetwork.admitad:
        return _admitadLink(destination);
      case _AffiliateNetwork.linkwise:
        return _linkwiseLink(destination);
      case _AffiliateNetwork.tradedoubler:
        return _tradedoublerLink(destination);
    }
  }

  Uri? _tryParseUrl(String value) {
    final parsed = Uri.tryParse(value);
    if (parsed != null && (parsed.scheme == 'https' || parsed.scheme == 'http')) {
      return parsed;
    }
    final withScheme = Uri.tryParse('https://$value');
    if (withScheme != null && (withScheme.scheme == 'https' || withScheme.scheme == 'http')) {
      return withScheme;
    }
    return null;
  }

  bool _isAmazonHost(String host) => host.contains('amazon.');

  bool _isEbayHost(String host) => host.contains('ebay.');

  Uri _amazonLink(Uri destination) {
    final tag = _env('AMAZON_ASSOCIATE_TAG', 'DUMMY_AMAZON_TAG');
    final params = Map<String, String>.from(destination.queryParameters);
    params['tag'] = tag;
    return destination.replace(queryParameters: params);
  }

  Uri _ebayLink(Uri destination) {
    final campaignId = _env('EBAY_CAMPAIGN_ID', 'DUMMY_EBAY_CAMP');
    final customId = _env('EBAY_CUSTOM_ID', 'aura_catch_app');

    return Uri.https('rover.ebay.com', '/rover/1/711-53200-19255-0/1', {
      'campid': campaignId,
      'customid': customId,
      'toolid': '10001',
      'mpre': destination.toString(),
    });
  }

  Uri _awinLink(Uri destination) {
    final publisherId = _env('AWIN_PUBLISHER_ID', 'DUMMY_AWIN_PUBLISHER');
    final clickref = _env('AWIN_CLICKREF', 'aura_catch_app');

    return Uri.https('www.awin1.com', '/cread.php', {
      'awinmid': '0',
      'awinaffid': publisherId,
      'clickref': clickref,
      'p': destination.toString(),
    });
  }

  Uri _cjLink(Uri destination) {
    final pid = dotenv.env['CJ_WEBSITE_ID'] ?? dotenv.env['CJ_AFFILIATE_ID'] ?? 'DUMMY_CJ_WEBSITE';

    return Uri.https('www.anrdoezrs.net', '/click-$pid-00000000', {
      'url': destination.toString(),
    });
  }

  Uri _admitadLink(Uri destination) {
    final campaignId = _env('ADMITAD_CAMPAIGN_ID', 'DUMMY_ADMITAD_CAMPAIGN');
    final adspaceId = _env('ADMITAD_ADSPACE_ID', 'DUMMY_ADMITAD_ADSPACE');
    final subId = _env('ADMITAD_SUBID', 'aura_catch_app');

    return Uri.https('ad.admitad.com', '/g/$campaignId/$adspaceId/', {
      'ulp': destination.toString(),
      'subid': subId,
    });
  }

  Uri _linkwiseLink(Uri destination) {
    final affId = _env('LINKWISE_AFFILIATE_ID', 'DUMMY_LINKWISE_AFF');
    final merchantId = _env('LINKWISE_MERCHANT_ID', 'DUMMY_LINKWISE_MERCHANT');

    return Uri.https('click.linkwi.se', '/t', {
      'a': affId,
      'm': merchantId,
      'url': destination.toString(),
    });
  }

  Uri _tradedoublerLink(Uri destination) {
    final affId = _env('TRADEDOUBLER_AFFILIATE_ID', 'DUMMY_TD_AFF');
    final orgId = _env('TRADEDOUBLER_ORGANIZATION_ID', 'DUMMY_TD_ORG');

    return Uri.parse(
      'https://clk.tradedoubler.com/click?p=$orgId&a=$affId&url=${Uri.encodeComponent(destination.toString())}',
    );
  }

  Uri _allegroLink(Uri destination) {
    final partnerId = _env('ALLEGRO_PARTNER_ID', 'DUMMY_ALLEGRO_PARTNER');

    final params = Map<String, String>.from(destination.queryParameters);
    params['utm_source'] = 'aura_catch';
    params['utm_medium'] = 'affiliate';
    params['utm_campaign'] = partnerId;

    return destination.replace(queryParameters: params);
  }

  String _env(String key, String fallback) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) {
      return fallback;
    }
    return value;
  }

  Uri _buildFallbackSearchLink({
    required String regionCode,
    required String storeName,
    required String brand,
    required String model,
  }) {
    final query = '$brand $model'.trim();

    if (storeName.contains('ebay')) {
      return Uri.https('www.ebay.com', '/sch/i.html', {'_nkw': query});
    }

    final stores = _regionStoreMap[regionCode] ?? _regionStoreMap['US']!;
    final preferred = _findStoreByName(regionCode, storeName) ?? stores.first;

    return Uri.https(preferred.searchHost, preferred.searchPath, {
      preferred.searchQueryKey: query,
    });
  }

  _StoreConfig? _findStoreByName(String regionCode, String normalizedStore) {
    final stores = _regionStoreMap[regionCode];
    if (stores == null) {
      return null;
    }
    for (final store in stores) {
      if (store.name.toLowerCase() == normalizedStore) {
        return store;
      }
      if (store.aliases.any(normalizedStore.contains)) {
        return store;
      }
    }
    return null;
  }

  _StoreConfig? _findStoreByHost(String regionCode, String host) {
    final stores = _regionStoreMap[regionCode];
    if (stores == null) {
      return null;
    }
    for (final store in stores) {
      if (store.hostMatchers.any(host.contains)) {
        return store;
      }
    }
    return null;
  }

  String _normalizeRegion(String rawRegion) {
    final upper = rawRegion.trim().toUpperCase();
    if (_regionStoreMap.containsKey(upper)) {
      return upper;
    }

    final lowered = rawRegion.trim().toLowerCase();
    return _regionAliases[lowered] ?? 'US';
  }

  static const Map<String, String> _regionAliases = {
    'polska': 'PL',
    'usa': 'US',
    'wielka brytania': 'GB',
    'uk': 'GB',
    'niemcy': 'DE',
    'francja': 'FR',
    'włochy': 'IT',
    'wlochy': 'IT',
    'hiszpania': 'ES',
    'szwajcaria': 'CH',
    'norwegia': 'NO',
    'islandia': 'IS',
    'ukraina': 'UA',
    'holandia': 'NL',
    'belgia': 'BE',
    'austria': 'AT',
    'czechy': 'CZ',
    'słowacja': 'SK',
    'slowacja': 'SK',
    'szwecja': 'SE',
    'dania': 'DK',
    'finlandia': 'FI',
    'irlandia': 'IE',
    'portugalia': 'PT',
    'grecja': 'GR',
    'węgry': 'HU',
    'wegry': 'HU',
    'rumunia': 'RO',
    'bułgaria': 'BG',
    'bulgaria': 'BG',
    'chorwacja': 'HR',
    'litwa': 'LT',
    'łotwa': 'LV',
    'lotwa': 'LV',
    'estonia': 'EE',
    'słowenia': 'SI',
    'slowenia': 'SI',
    'luksemburg': 'LU',
  };

  static const Map<String, _AffiliateNetwork> _regionDefaultNetwork = {
    'PL': _AffiliateNetwork.awin,
    'US': _AffiliateNetwork.cj,
    'GB': _AffiliateNetwork.cj,
    'DE': _AffiliateNetwork.awin,
    'FR': _AffiliateNetwork.awin,
    'IT': _AffiliateNetwork.awin,
    'ES': _AffiliateNetwork.awin,
    'CH': _AffiliateNetwork.awin,
    'NO': _AffiliateNetwork.cj,
    'IS': _AffiliateNetwork.tradedoubler,
    'UA': _AffiliateNetwork.admitad,
    'NL': _AffiliateNetwork.awin,
    'BE': _AffiliateNetwork.awin,
    'AT': _AffiliateNetwork.awin,
    'CZ': _AffiliateNetwork.awin,
    'SK': _AffiliateNetwork.awin,
    'SE': _AffiliateNetwork.cj,
    'DK': _AffiliateNetwork.cj,
    'FI': _AffiliateNetwork.cj,
    'IE': _AffiliateNetwork.awin,
    'PT': _AffiliateNetwork.awin,
    'GR': _AffiliateNetwork.linkwise,
    'HU': _AffiliateNetwork.awin,
    'RO': _AffiliateNetwork.admitad,
    'BG': _AffiliateNetwork.admitad,
    'HR': _AffiliateNetwork.awin,
    'LT': _AffiliateNetwork.awin,
    'LV': _AffiliateNetwork.awin,
    'EE': _AffiliateNetwork.awin,
    'SI': _AffiliateNetwork.awin,
    'LU': _AffiliateNetwork.awin,
  };

  static const Map<String, List<_StoreConfig>> _regionStoreMap = {
    'PL': [
      _StoreConfig('allegro', _AffiliateNetwork.awin, ['allegro.pl'], 'allegro.pl', '/listing', 'string', aliases: ['allegro']),
      _StoreConfig('ceneo', _AffiliateNetwork.awin, ['ceneo.pl'], 'www.ceneo.pl', '/szukaj', 'q', aliases: ['ceneo']),
      _StoreConfig('mediaexpert', _AffiliateNetwork.awin, ['mediaexpert.pl'], 'www.mediaexpert.pl', '/search', 'query[menu_item]', aliases: ['media expert', 'mediaexpert']),
    ],
    'US': [
      _StoreConfig('walmart', _AffiliateNetwork.cj, ['walmart.com'], 'www.walmart.com', '/search', 'q', aliases: ['walmart']),
      _StoreConfig('bestbuy', _AffiliateNetwork.cj, ['bestbuy.com'], 'www.bestbuy.com', '/site/searchpage.jsp', 'st', aliases: ['best buy', 'bestbuy']),
      _StoreConfig('ebay', _AffiliateNetwork.ebay, ['ebay.com'], 'www.ebay.com', '/sch/i.html', '_nkw', aliases: ['ebay']),
    ],
    'GB': [
      _StoreConfig('currys', _AffiliateNetwork.cj, ['currys.co.uk'], 'www.currys.co.uk', '/search', 'searchTerm', aliases: ['currys']),
      _StoreConfig('argos', _AffiliateNetwork.cj, ['argos.co.uk'], 'www.argos.co.uk', '/search', 'searchTerm', aliases: ['argos']),
      _StoreConfig('ebay', _AffiliateNetwork.ebay, ['ebay.co.uk'], 'www.ebay.co.uk', '/sch/i.html', '_nkw', aliases: ['ebay']),
    ],
    'DE': [
      _StoreConfig('otto', _AffiliateNetwork.awin, ['otto.de'], 'www.otto.de', '/suche', 'suchbegriff', aliases: ['otto']),
      _StoreConfig('mediamarkt', _AffiliateNetwork.awin, ['mediamarkt.de'], 'www.mediamarkt.de', '/de/search.html', 'query', aliases: ['mediamarkt', 'media markt']),
      _StoreConfig('idealo', _AffiliateNetwork.awin, ['idealo.de'], 'www.idealo.de', '/preisvergleich/MainSearchProductCategory.html', 'q', aliases: ['idealo']),
    ],
    'FR': [
      _StoreConfig('cdiscount', _AffiliateNetwork.awin, ['cdiscount.com'], 'www.cdiscount.com', '/search/10', 's', aliases: ['cdiscount']),
      _StoreConfig('fnac', _AffiliateNetwork.awin, ['fnac.com'], 'www.fnac.com', '/SearchResult/ResultList.aspx', 'Search', aliases: ['fnac']),
      _StoreConfig('darty', _AffiliateNetwork.awin, ['darty.com'], 'www.darty.com', '/nav/recherche', 'text', aliases: ['darty']),
    ],
    'IT': [
      _StoreConfig('unieuro', _AffiliateNetwork.awin, ['unieuro.it'], 'www.unieuro.it', '/online/search', 'q', aliases: ['unieuro']),
      _StoreConfig('mediaworld', _AffiliateNetwork.awin, ['mediaworld.it'], 'www.mediaworld.it', '/it/search', 'q', aliases: ['mediaworld']),
      _StoreConfig('ebay', _AffiliateNetwork.ebay, ['ebay.it'], 'www.ebay.it', '/sch/i.html', '_nkw', aliases: ['ebay']),
    ],
    'ES': [
      _StoreConfig('pccomponentes', _AffiliateNetwork.awin, ['pccomponentes.com'], 'www.pccomponentes.com', '/buscar', 'query', aliases: ['pccomponentes']),
      _StoreConfig('elcorteingles', _AffiliateNetwork.awin, ['elcorteingles.es'], 'www.elcorteingles.es', '/search-nwx', 's', aliases: ['el corte ingles', 'elcorteingles']),
      _StoreConfig('mediamarkt', _AffiliateNetwork.awin, ['mediamarkt.es'], 'www.mediamarkt.es', '/es/search.html', 'query', aliases: ['mediamarkt']),
    ],
    'CH': [
      _StoreConfig('digitec', _AffiliateNetwork.awin, ['digitec.ch'], 'www.digitec.ch', '/en/search', 'q', aliases: ['digitec']),
      _StoreConfig('galaxus', _AffiliateNetwork.awin, ['galaxus.ch'], 'www.galaxus.ch', '/en/search', 'q', aliases: ['galaxus']),
      _StoreConfig('brack', _AffiliateNetwork.awin, ['brack.ch'], 'www.brack.ch', '/search', 'q', aliases: ['brack']),
    ],
    'NO': [
      _StoreConfig('elkjop', _AffiliateNetwork.cj, ['elkjop.no'], 'www.elkjop.no', '/search', 'q', aliases: ['elkjop', 'elkjøp']),
      _StoreConfig('komplett', _AffiliateNetwork.cj, ['komplett.no'], 'www.komplett.no', '/search', 'q', aliases: ['komplett']),
      _StoreConfig('proshop', _AffiliateNetwork.cj, ['proshop.no'], 'www.proshop.no', '/search', 's', aliases: ['proshop']),
    ],
    'IS': [
      _StoreConfig('elko', _AffiliateNetwork.tradedoubler, ['elko.is'], 'elko.is', '/leit', 'q', aliases: ['elko']),
      _StoreConfig('tolvutek', _AffiliateNetwork.tradedoubler, ['tolvutek.is'], 'tolvutek.is', '/leit', 'q', aliases: ['tolvutek']),
      _StoreConfig('computeris', _AffiliateNetwork.tradedoubler, ['computer.is'], 'www.computer.is', '/is/search', 'q', aliases: ['computer.is', 'computeris']),
    ],
    'UA': [
      _StoreConfig('rozetka', _AffiliateNetwork.admitad, ['rozetka.com.ua'], 'rozetka.com.ua', '/search/', 'text', aliases: ['rozetka']),
      _StoreConfig('foxtrot', _AffiliateNetwork.admitad, ['foxtrot.com.ua'], 'www.foxtrot.com.ua', '/uk/shop', 'search', aliases: ['foxtrot']),
      _StoreConfig('allo', _AffiliateNetwork.admitad, ['allo.ua'], 'allo.ua', '/ua/catalogsearch/result/', 'q', aliases: ['allo']),
    ],
    'NL': [
      _StoreConfig('bol', _AffiliateNetwork.awin, ['bol.com'], 'www.bol.com', '/nl/nl/s/', 'searchtext', aliases: ['bol', 'bol.com']),
      _StoreConfig('coolblue', _AffiliateNetwork.awin, ['coolblue.nl'], 'www.coolblue.nl', '/zoeken', 'query', aliases: ['coolblue']),
      _StoreConfig('mediamarkt', _AffiliateNetwork.awin, ['mediamarkt.nl'], 'www.mediamarkt.nl', '/nl/search.html', 'query', aliases: ['mediamarkt']),
    ],
    'BE': [
      _StoreConfig('bol', _AffiliateNetwork.awin, ['bol.com'], 'www.bol.com', '/be/nl/s/', 'searchtext', aliases: ['bol', 'bol.com']),
      _StoreConfig('coolblue', _AffiliateNetwork.awin, ['coolblue.be'], 'www.coolblue.be', '/nl/zoeken', 'query', aliases: ['coolblue']),
      _StoreConfig('vandenborre', _AffiliateNetwork.awin, ['vandenborre.be'], 'www.vandenborre.be', '/fr/search', 'q', aliases: ['vanden borre', 'vandenborre']),
    ],
    'AT': [
      _StoreConfig('mediamarkt', _AffiliateNetwork.awin, ['mediamarkt.at'], 'www.mediamarkt.at', '/de/search.html', 'query', aliases: ['mediamarkt']),
      _StoreConfig('universal', _AffiliateNetwork.awin, ['universal.at'], 'www.universal.at', '/suche', 'q', aliases: ['universal']),
      _StoreConfig('electronic4you', _AffiliateNetwork.awin, ['electronic4you.at'], 'www.electronic4you.at', '/search', 'q', aliases: ['electronic4you']),
    ],
    'CZ': [
      _StoreConfig('alza', _AffiliateNetwork.awin, ['alza.cz'], 'www.alza.cz', '/search.htm', 'exps', aliases: ['alza']),
      _StoreConfig('mall', _AffiliateNetwork.awin, ['mall.cz'], 'www.mall.cz', '/hledani', 'q', aliases: ['mall']),
      _StoreConfig('czc', _AffiliateNetwork.awin, ['czc.cz'], 'www.czc.cz', '/hledat', 'q-c-0-f_2027485=s', aliases: ['czc']),
    ],
    'SK': [
      _StoreConfig('alza', _AffiliateNetwork.awin, ['alza.sk'], 'www.alza.sk', '/search.htm', 'exps', aliases: ['alza']),
      _StoreConfig('nay', _AffiliateNetwork.awin, ['nay.sk'], 'www.nay.sk', '/vyhladavanie', 'q', aliases: ['nay']),
      _StoreConfig('mall', _AffiliateNetwork.awin, ['mall.sk'], 'www.mall.sk', '/hladanie', 'q', aliases: ['mall']),
    ],
    'SE': [
      _StoreConfig('elgiganten', _AffiliateNetwork.cj, ['elgiganten.se'], 'www.elgiganten.se', '/search', 'q', aliases: ['elgiganten']),
      _StoreConfig('netonnet', _AffiliateNetwork.cj, ['netonnet.se'], 'www.netonnet.se', '/search', 'query', aliases: ['netonnet']),
      _StoreConfig('komplett', _AffiliateNetwork.cj, ['komplett.se'], 'www.komplett.se', '/search', 'q', aliases: ['komplett']),
    ],
    'DK': [
      _StoreConfig('elgiganten', _AffiliateNetwork.cj, ['elgiganten.dk'], 'www.elgiganten.dk', '/search', 'q', aliases: ['elgiganten']),
      _StoreConfig('proshop', _AffiliateNetwork.cj, ['proshop.dk'], 'www.proshop.dk', '/Search', 's', aliases: ['proshop']),
      _StoreConfig('computersalg', _AffiliateNetwork.cj, ['computersalg.dk'], 'www.computersalg.dk', '/i', 'query', aliases: ['computersalg']),
    ],
    'FI': [
      _StoreConfig('gigantti', _AffiliateNetwork.cj, ['gigantti.fi'], 'www.gigantti.fi', '/search', 'q', aliases: ['gigantti']),
      _StoreConfig('verkkokauppa', _AffiliateNetwork.cj, ['verkkokauppa.com'], 'www.verkkokauppa.com', '/fi/search', 'query', aliases: ['verkkokauppa']),
      _StoreConfig('jimms', _AffiliateNetwork.cj, ['jimms.fi'], 'www.jimms.fi', '/fi/Product/Search', 'q', aliases: ['jimms']),
    ],
    'IE': [
      _StoreConfig('currys', _AffiliateNetwork.awin, ['currys.ie'], 'www.currys.ie', '/search', 'searchTerm', aliases: ['currys']),
      _StoreConfig('harveynorman', _AffiliateNetwork.awin, ['harveynorman.ie'], 'www.harveynorman.ie', '/search', 'q', aliases: ['harvey norman', 'harveynorman']),
      _StoreConfig('did', _AffiliateNetwork.awin, ['did.ie'], 'www.did.ie', '/search', 'query', aliases: ['did', 'did electrical']),
    ],
    'PT': [
      _StoreConfig('worten', _AffiliateNetwork.awin, ['worten.pt'], 'www.worten.pt', '/pesquisa', 'query', aliases: ['worten']),
      _StoreConfig('fnac', _AffiliateNetwork.awin, ['fnac.pt'], 'www.fnac.pt', '/SearchResult/ResultList.aspx', 'Search', aliases: ['fnac']),
      _StoreConfig('kuantokusta', _AffiliateNetwork.awin, ['kuantokusta.pt'], 'www.kuantokusta.pt', '/search', 'query', aliases: ['kuantokusta']),
    ],
    'GR': [
      _StoreConfig('skroutz', _AffiliateNetwork.linkwise, ['skroutz.gr'], 'www.skroutz.gr', '/search', 'keyphrase', aliases: ['skroutz']),
      _StoreConfig('public', _AffiliateNetwork.linkwise, ['public.gr'], 'www.public.gr', '/search', 'q', aliases: ['public']),
      _StoreConfig('plaisio', _AffiliateNetwork.linkwise, ['plaisio.gr'], 'www.plaisio.gr', '/search', 'text', aliases: ['plaisio']),
    ],
    'HU': [
      _StoreConfig('emag', _AffiliateNetwork.awin, ['emag.hu'], 'www.emag.hu', '/search', 'ref', aliases: ['emag']),
      _StoreConfig('alza', _AffiliateNetwork.awin, ['alza.hu'], 'www.alza.hu', '/search.htm', 'exps', aliases: ['alza']),
      _StoreConfig('mediamarkt', _AffiliateNetwork.awin, ['mediamarkt.hu'], 'www.mediamarkt.hu', '/hu/search.html', 'query', aliases: ['mediamarkt']),
    ],
    'RO': [
      _StoreConfig('emag', _AffiliateNetwork.admitad, ['emag.ro'], 'www.emag.ro', '/search', 'ref', aliases: ['emag']),
      _StoreConfig('flanco', _AffiliateNetwork.admitad, ['flanco.ro'], 'www.flanco.ro', '/catalogsearch/result/', 'q', aliases: ['flanco']),
      _StoreConfig('cel', _AffiliateNetwork.admitad, ['cel.ro'], 'www.cel.ro', '/cauta', 'q', aliases: ['cel']),
    ],
    'BG': [
      _StoreConfig('emag', _AffiliateNetwork.admitad, ['emag.bg'], 'www.emag.bg', '/search', 'ref', aliases: ['emag']),
      _StoreConfig('technopolis', _AffiliateNetwork.admitad, ['technopolis.bg'], 'www.technopolis.bg', '/bg/Search', 'query', aliases: ['technopolis']),
      _StoreConfig('ozone', _AffiliateNetwork.admitad, ['ozone.bg'], 'www.ozone.bg', '/search', 'q', aliases: ['ozone']),
    ],
    'HR': [
      _StoreConfig('links', _AffiliateNetwork.awin, ['links.hr'], 'www.links.hr', '/hr/search', 'q', aliases: ['links']),
      _StoreConfig('instar', _AffiliateNetwork.awin, ['instar-informatika.hr'], 'www.instar-informatika.hr', '/search', 'q', aliases: ['instar']),
      _StoreConfig('ekupi', _AffiliateNetwork.awin, ['ekupi.hr'], 'www.ekupi.hr', '/hr/Pretraga', 'q', aliases: ['ekupi']),
    ],
    'LT': [
      _StoreConfig('pigu', _AffiliateNetwork.awin, ['pigu.lt'], 'pigu.lt', '/lt/search', 'q', aliases: ['pigu']),
      _StoreConfig('varle', _AffiliateNetwork.awin, ['varle.lt'], 'www.varle.lt', '/paieska', 'q', aliases: ['varle']),
      _StoreConfig('kilobaitas', _AffiliateNetwork.awin, ['kilobaitas.lt'], 'www.kilobaitas.lt', '/paieska', 'q', aliases: ['kilobaitas']),
    ],
    'LV': [
      _StoreConfig('1a', _AffiliateNetwork.awin, ['1a.lv'], 'www.1a.lv', '/search', 'q', aliases: ['1a']),
      _StoreConfig('rdveikals', _AffiliateNetwork.awin, ['rdveikals.lv'], 'www.rdveikals.lv', '/search', 'q', aliases: ['rd', 'rdveikals']),
      _StoreConfig('220lv', _AffiliateNetwork.awin, ['220.lv'], '220.lv', '/lv/search', 'q', aliases: ['220.lv']),
    ],
    'EE': [
      _StoreConfig('kaup24', _AffiliateNetwork.awin, ['kaup24.ee'], 'www.kaup24.ee', '/et/search', 'q', aliases: ['kaup24']),
      _StoreConfig('1a', _AffiliateNetwork.awin, ['1a.ee'], 'www.1a.ee', '/search', 'q', aliases: ['1a']),
      _StoreConfig('hinnavaatlus', _AffiliateNetwork.awin, ['hinnavaatlus.ee'], 'www.hinnavaatlus.ee', '/search', 'query', aliases: ['hinnavaatlus']),
    ],
    'SI': [
      _StoreConfig('mimovrste', _AffiliateNetwork.awin, ['mimovrste.com'], 'www.mimovrste.com', '/iskanje', 'q', aliases: ['mimovrste']),
      _StoreConfig('bigbang', _AffiliateNetwork.awin, ['bigbang.si'], 'www.bigbang.si', '/iskanje', 'q', aliases: ['big bang', 'bigbang']),
      _StoreConfig('ceneje', _AffiliateNetwork.awin, ['ceneje.si'], 'www.ceneje.si', '/Iskanje/Izdelki', 'q', aliases: ['ceneje']),
    ],
    'LU': [
      _StoreConfig('hifi', _AffiliateNetwork.awin, ['hifi.lu'], 'www.hifi.lu', '/search', 'q', aliases: ['hifi', 'hifi.lu']),
      _StoreConfig('cora', _AffiliateNetwork.awin, ['cora.lu'], 'www.cora.lu', '/fr/search', 'q', aliases: ['cora']),
      _StoreConfig('mediamarkt', _AffiliateNetwork.awin, ['mediamarkt.lu'], 'www.mediamarkt.lu', '/fr/search.html', 'query', aliases: ['mediamarkt']),
    ],
  };
}

enum _AffiliateNetwork {
  amazon,
  ebay,
  awin,
  cj,
  admitad,
  linkwise,
  tradedoubler,
}

class _StoreConfig {
  const _StoreConfig(
    this.name,
    this.network,
    this.hostMatchers,
    this.searchHost,
    this.searchPath,
    this.searchQueryKey, {
    this.aliases = const [],
  });

  final String name;
  final _AffiliateNetwork network;
  final List<String> hostMatchers;
  final String searchHost;
  final String searchPath;
  final String searchQueryKey;
  final List<String> aliases;
}
