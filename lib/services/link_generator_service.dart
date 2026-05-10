import 'package:flutter_dotenv/flutter_dotenv.dart';

class LinkGeneratorService {
  Uri buildMonetizedLink({
    required String storeName,
    required String region,
    required String brand,
    required String model,
    String? rawProductUrl,
  }) {
    final normalizedStore = storeName.trim().toLowerCase();
    final source = (rawProductUrl ?? '').trim();

    if (source.isNotEmpty) {
      final parsed = Uri.tryParse(source);
      if (parsed != null && (parsed.scheme == 'https' || parsed.scheme == 'http')) {
        final host = parsed.host.toLowerCase();

        if (host.contains('amazon.')) {
          return _amazonLink(parsed);
        }
        if (host.contains('ebay.')) {
          return _ebayLink(parsed);
        }
        if (host.contains('allegro.')) {
          return _allegroLink(parsed);
        }
        if (_isAwinCandidate(host, normalizedStore, region)) {
          return _awinLink(parsed);
        }
        if (_isCjCandidate(host)) {
          return _cjLink(parsed);
        }

        return parsed;
      }
    }

    return _buildFallbackSearchLink(
      storeName: storeName,
      region: region,
      brand: brand,
      model: model,
    );
  }

  bool _isAwinCandidate(String host, String normalizedStore, String region) {
    const awinHosts = {
      'mediamarkt',
      'zalando',
      'bol.com',
      'digitec',
      'galaxus',
      'saturn',
    };

    final regionLower = region.toLowerCase();
    final likelyEuropean = regionLower.contains('polska') ||
        regionLower.contains('niemcy') ||
        regionLower.contains('francja') ||
        regionLower.contains('włochy') ||
        regionLower.contains('hiszpania') ||
        regionLower.contains('holandia') ||
        regionLower.contains('belgia') ||
        regionLower.contains('szwajcaria') ||
        regionLower.contains('austria') ||
        regionLower.contains('dania') ||
        regionLower.contains('szwecja') ||
        regionLower.contains('finlandia') ||
        regionLower.contains('portugalia') ||
        regionLower.contains('irlandia') ||
        regionLower.contains('luksemburg');

    return likelyEuropean && awinHosts.any((h) => host.contains(h) || normalizedStore.contains(h));
  }

  bool _isCjCandidate(String host) {
    const cjHosts = {
      'bestbuy.',
      'newegg.',
      'samsung.',
      'lenovo.',
      'hp.',
      'dell.',
    };
    return cjHosts.any(host.contains);
  }

  Uri _amazonLink(Uri destination) {
    final tag = dotenv.env['AMAZON_ASSOCIATE_TAG'] ?? '';
    if (tag.isEmpty) return destination;

    final params = Map<String, String>.from(destination.queryParameters);
    params['tag'] = tag;
    return destination.replace(queryParameters: params);
  }

  Uri _ebayLink(Uri destination) {
    final campaignId = dotenv.env['EBAY_CAMPAIGN_ID'] ?? '';
    final customId = dotenv.env['EBAY_CUSTOM_ID'] ?? 'aura_catch';

    if (campaignId.isEmpty) return destination;

    return Uri.https('rover.ebay.com', '/rover/1/711-53200-19255-0/1', {
      'campid': campaignId,
      'customid': customId,
      'toolid': '10001',
      'mpre': destination.toString(),
    });
  }

  Uri _awinLink(Uri destination) {
    final publisherId = dotenv.env['AWIN_PUBLISHER_ID'] ?? '';
    final clickref = dotenv.env['AWIN_CLICKREF'] ?? 'aura_catch';

    if (publisherId.isEmpty) return destination;

    return Uri.https('www.awin1.com', '/cread.php', {
      'awinmid': '0',
      'awinaffid': publisherId,
      'clickref': clickref,
      'p': destination.toString(),
    });
  }

  Uri _cjLink(Uri destination) {
    final pid = dotenv.env['CJ_WEBSITE_ID'] ?? '';
    if (pid.isEmpty) return destination;

    return Uri.https('www.anrdoezrs.net', '/click-$pid-00000000', {
      'url': destination.toString(),
    });
  }

  Uri _allegroLink(Uri destination) {
    final partnerId = dotenv.env['ALLEGRO_PARTNER_ID'] ?? '';
    if (partnerId.isEmpty) return destination;

    final params = Map<String, String>.from(destination.queryParameters);
    params['utm_source'] = 'aura_catch';
    params['utm_medium'] = 'affiliate';
    params['utm_campaign'] = partnerId;

    return destination.replace(queryParameters: params);
  }

  Uri _buildFallbackSearchLink({
    required String storeName,
    required String region,
    required String brand,
    required String model,
  }) {
    final query = '$brand $model'.trim();
    final regionLower = region.toLowerCase();

    if (regionLower.contains('polska') && storeName.toLowerCase().contains('allegro')) {
      return Uri.https('allegro.pl', '/listing', {'string': query});
    }
    if (storeName.toLowerCase().contains('ebay') || regionLower.contains('usa')) {
      return Uri.https('www.ebay.com', '/sch/i.html', {'_nkw': query});
    }

    return Uri.https('www.amazon.com', '/s', {'k': query});
  }
}
