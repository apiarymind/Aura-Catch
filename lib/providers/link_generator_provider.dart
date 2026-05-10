import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/link_generator_service.dart';

final linkGeneratorServiceProvider = Provider<LinkGeneratorService>((ref) {
  return LinkGeneratorService();
});
