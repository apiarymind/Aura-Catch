import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

import 'widgets/product_card.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/ai_search_provider.dart';
import '../../providers/tracking_provider.dart';
import '../../providers/region_provider.dart';
import '../../models/tracked_item.dart';
import '../../services/database_service.dart';
import '../../utils/attributes_utils.dart';
import '../../widgets/ad_banner.dart';
import '../../widgets/aura_logo.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  final List<TrackedItem> _webDemoItems = [];
  bool _speechEnabled = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) {
        if (!mounted) return;
        final isStillListening = status == 'listening';
        if (_isListening != isStillListening) {
          setState(() {
            _isListening = isStillListening;
          });
        }
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
        });
      },
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechToText.stop();
      if (mounted) {
        setState(() {
          _isListening = false;
        });
      }
      return;
    }

    // Hard permission guard: check mic + speech before starting
    var micStatus = await Permission.microphone.status;
    var speechStatus = await Permission.speech.status;
    if (!micStatus.isGranted && !speechStatus.isGranted) {
      // Try to request first
      micStatus = await Permission.microphone.request();
      speechStatus = await Permission.speech.request();
    }
    if (!micStatus.isGranted && !speechStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Brak uprawnień do mikrofonu')),
        );
      }
      return;
    }

    if (!_speechEnabled) {
      await _initSpeech();
      if (!_speechEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tr('failed_microphone'))),
          );
        }
        return;
      }
    }

    final localeId = _resolveSpeechLocaleId();
    await _speechToText.listen(
      localeId: localeId,
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _searchController.text = result.recognizedWords;
          _searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: _searchController.text.length),
          );
          _isListening = !result.finalResult;
        });
        if (result.finalResult && _searchController.text.trim().isNotEmpty) {
          _handleSearch(_searchController.text);
        }
      },
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
      ),
      pauseFor: const Duration(seconds: 3),
      listenFor: const Duration(seconds: 30),
    );

    if (mounted) {
      setState(() {
        _isListening = true;
      });
    }
  }

  String? _resolveSpeechLocaleId() {
    final locale = context.locale;
    final languageCode = locale.languageCode;
    final countryCode = locale.countryCode;

    if (countryCode != null && countryCode.isNotEmpty) {
      return '${languageCode}_${countryCode.toUpperCase()}';
    }

    return languageCode;
  }

  @override
  void dispose() {
    _speechToText.stop();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    if (query.trim().isEmpty) return;
    
    ref.read(aiSearchStateProvider.notifier).analyzeQuery(text: query);
    _showResultDialog();
  }

  void _handleCamera() async {
    final picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo == null) return;

      final bytes = await photo.readAsBytes();
      final String base64Image = base64Encode(bytes);

      ref.read(aiSearchStateProvider.notifier).analyzeQuery(
        text: tr('extract_info_image'),
        imageBase64: base64Image,
      );
      
      if (mounted) {
        _showResultDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('failed_camera', args: [e.toString()])),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final searchState = ref.watch(aiSearchStateProvider);

            return searchState.when(
              data: (data) {
                if (data == null) return const SizedBox.shrink();
                return _EditItemDialog(
                  aiData: data,
                  rawUserInput: _searchController.text,
                  onSuccess: () {
                    _searchController.clear();
                    ref.read(aiSearchStateProvider.notifier).reset();
                    ref.invalidate(trackedItemsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(tr('item_added_success'))),
                    );
                  },
                  onWebDemoAdd: (demoData) {
                    _searchController.clear();
                    ref.read(aiSearchStateProvider.notifier).reset();
                    _addWebDemoItem(demoData);
                  },
                );
              },
              loading: () => AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(tr('analyzing_with_gemini')),
                  ],
                ),
              ),
              error: (error, _) => AlertDialog(
                title: Text(tr('error')),
                content: Text(tr('error_details', args: [error.toString()])),
                actions: [
                  TextButton(
                    onPressed: () {
                      ref.read(aiSearchStateProvider.notifier).reset();
                      Navigator.of(context).pop();
                    },
                    child: Text(tr('close')),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool _isWebDemoItem(String id) => id.startsWith('demo_');

  String _resolveMockStore(String fullName) {
    final text = fullName.toLowerCase();
    if (text.contains('iphone') ||
        text.contains('mac') ||
        text.contains('samsung') ||
        text.contains('rtx')) {
      return 'Media Expert';
    }
    if (text.contains('parfum') || text.contains('chanel') || text.contains('cream')) {
      return 'Sephora';
    }
    return 'Amazon';
  }

  void _addWebDemoItem(Map<String, dynamic> demoData) {
    if (!kIsWeb) return;

    final targetPrice = (demoData['targetPrice'] as num).toDouble();
    final brand = demoData['brand']?.toString().trim().isNotEmpty == true
        ? demoData['brand'].toString().trim()
        : 'Unknown';
    final model = demoData['model']?.toString().trim().isNotEmpty == true
        ? demoData['model'].toString().trim()
        : 'Unknown';
    final attributes = Map<String, dynamic>.from(demoData['attributes'] as Map? ?? {});
    final conditionType = demoData['condition']?.toString() ?? 'NEW';

    final demoId = 'demo_${DateTime.now().microsecondsSinceEpoch}';
    final initialItem = TrackedItem(
      id: demoId,
      brand: brand,
      model: model,
      productUrl: null,
      addedAt: DateTime.now().toUtc(),
      targetPrice: targetPrice,
      currentPrice: targetPrice * 1.2,
      lowestPrice180d: null,
      status: 'Szukam...',
      storeName: 'Szukam...',
      attributes: attributes,
      conditionType: conditionType,
      scopeRegion: 'GLOBAL',
      storeReputation: 'GREEN_SHIELD',
    );

    setState(() {
      _webDemoItems.insert(0, initialItem);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tryb Demo: Rozpoczynam szybki skan rynków (Symulacja)...')),
    );

    Future.delayed(const Duration(seconds: 6), () {
      if (!mounted) return;
      final itemIndex = _webDemoItems.indexWhere((item) => item.id == demoId);
      if (itemIndex < 0) return;

      final current = _webDemoItems[itemIndex];
      final updatedItem = TrackedItem(
        id: current.id,
        brand: current.brand,
        model: current.model,
        productUrl: current.productUrl,
        addedAt: current.addedAt,
        targetPrice: current.targetPrice,
        currentPrice: current.targetPrice * 0.7,
        lowestPrice180d: current.targetPrice * 0.7,
        status: 'ACTIVE',
        storeName: _resolveMockStore('${current.brand} ${current.model}'),
        attributes: current.attributes,
        conditionType: current.conditionType,
        scopeRegion: current.scopeRegion,
        storeReputation: current.storeReputation,
      );

      setState(() {
        _webDemoItems[itemIndex] = updatedItem;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPro = ref.watch(subscriptionProvider) == AccountPlan.pro;
    final trackedItemsAsync = ref.watch(trackedItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Aura',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
            const AuraLogo(size: 55, showWordmark: false),
            const SizedBox(width: 6),
            Text(
              'Catch',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (!isPro) const AdBanner(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: _handleSearch,
              decoration: InputDecoration(
                hintText: tr('what_are_you_looking_for'),
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _handleSearch(_searchController.text),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red : null,
                  ),
                  onPressed: _toggleListening,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),
          Expanded(
            child: trackedItemsAsync.when(
              data: (items) {
                final displayedItems = kIsWeb ? [..._webDemoItems, ...items] : items;

                if (displayedItems.isEmpty) {
                  return Center(child: Text(tr('no_items')));
                }
                return ListView.builder(
                  itemCount: displayedItems.length,
                  itemBuilder: (context, index) {
                    final item = displayedItems[index];
                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        if (_isWebDemoItem(item.id)) {
                          setState(() {
                            _webDemoItems.removeWhere((demoItem) => demoItem.id == item.id);
                          });
                        } else {
                          ref.read(trackedItemsProvider.notifier).deleteItem(item.id);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(tr('item_deleted', args: [item.brand, item.model])),
                          ),
                        );
                      },
                      child: ProductCard(
                        item: item,
                        onTap: () => context.push('/alert-details', extra: item),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(tr('error_loading_items', args: [error.toString()])),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!isPro) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(tr('showing_ad'))),
            );
          }
          _handleCamera();
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class _EditItemDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> aiData;
  final String rawUserInput;
  final VoidCallback onSuccess;
  final ValueChanged<Map<String, dynamic>> onWebDemoAdd;

  const _EditItemDialog({
    required this.aiData,
    required this.rawUserInput,
    required this.onSuccess,
    required this.onWebDemoAdd,
  });

  @override
  ConsumerState<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends ConsumerState<_EditItemDialog> {
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _variantController;
  late final TextEditingController _priceController;
  final Map<String, TextEditingController> _dynamicControllers = {};
  String _selectedCondition = 'NEW';
  late final bool _isBeautyCategory;
  bool _isSavingLocal = false;

  static const List<String> _conditionOptions = ['NEW', 'USED', 'OUTLET'];

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.aiData['brand']?.toString() ?? '');
    _modelController = TextEditingController(text: _extractAiModel());
    _priceController = TextEditingController(text: widget.aiData['targetPrice']?.toString() ?? '');
    _isBeautyCategory = _matchesBeautyCategory(_extractCategory());
    _selectedCondition = _isBeautyCategory ? 'NEW' : _normalizeCondition(widget.aiData['condition']);

    // Pre-fill the variant field from AI-extracted attributes.
    // Priority: explicit 'wariant' key > 'volume_ml' > any key whose value looks like a size.
    _variantController = TextEditingController(text: _extractVariantPrefill());

    // Category-aware dynamic attributes initialization
    final category = widget.aiData['category']?.toString().toLowerCase() ?? '';
    final initialAttributes = Map<String, dynamic>.from(widget.aiData['attributes'] as Map? ?? {});

    // Ensure volume_ml is present for Beauty / Perfume items
    if (category.contains('beauty') || category.contains('perfume')) {
      if (!initialAttributes.containsKey('volume_ml')) {
        initialAttributes['volume_ml'] = widget.aiData['volume_ml'] ?? '';
      }
    }

    // Exclude keys that are represented by the dedicated variant field
    const variantKeys = {'wariant', 'volume_ml', 'size', 'storage', 'capacity', 'variant'};
    initialAttributes.removeWhere((key, _) => variantKeys.contains(key.toLowerCase()));

    initialAttributes.forEach((key, value) {
      _dynamicControllers[key] = TextEditingController(text: value?.toString() ?? '');
    });
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _variantController.dispose();
    _priceController.dispose();
    _dynamicControllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  String _normalizeCondition(dynamic rawCondition) {
    final value = rawCondition?.toString().trim().toUpperCase() ?? '';
    if (_conditionOptions.contains(value)) {
      return value;
    }
    return 'NEW';
  }

  String _extractAiModel() {
    final directModel = widget.aiData['model']?.toString().trim();
    if (directModel != null && directModel.isNotEmpty) return directModel;

    final parsedData = widget.aiData['parsed_data'];
    if (parsedData is Map<String, dynamic>) {
      final parsedModel = parsedData['model']?.toString().trim();
      if (parsedModel != null && parsedModel.isNotEmpty) return parsedModel;
    }

    return '';
  }

  String _extractCategory() {
    final directCategory = widget.aiData['category']?.toString().trim();
    if (directCategory != null && directCategory.isNotEmpty) return directCategory;

    final parsedData = widget.aiData['parsed_data'];
    if (parsedData is Map<String, dynamic>) {
      final parsedCategory = parsedData['category']?.toString().trim();
      if (parsedCategory != null && parsedCategory.isNotEmpty) return parsedCategory;
    }

    return '';
  }

  bool _matchesBeautyCategory(String category) {
    final normalized = category.toLowerCase();
    return normalized.contains('beauty') ||
        normalized.contains('cosmetics') ||
        normalized.contains('fragrance');
  }

  /// Extracts the best pre-fill value for the variant field from AI data.
  String _extractVariantPrefill() {
    final attrs = Map<String, dynamic>.from(widget.aiData['attributes'] as Map? ?? {});

    // 1. Explicit 'wariant' key
    final explicit = attrs['wariant']?.toString().trim()
        ?? attrs['variant']?.toString().trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;

    // 2. volume_ml (Beauty / Perfume)
    final volumeMl = (attrs['volume_ml'] ?? widget.aiData['volume_ml'])?.toString().trim();
    if (volumeMl != null && volumeMl.isNotEmpty) return '${volumeMl}ml';

    // 3. Storage / capacity / size
    for (final key in ['storage', 'capacity', 'size']) {
      final v = attrs[key]?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }

    // 4. Scan raw user input for size-like tokens (e.g. "35ml", "256GB")
    final source = '${widget.rawUserInput} ${widget.aiData['model'] ?? ''}'.trim();
    final regex = RegExp(r'\b(\d+(?:\.\d+)?\s*(?:ml|gb|tb|kg|l|cm|inch))\b', caseSensitive: false);
    final match = regex.firstMatch(source);
    if (match != null) return match.group(0) ?? '';

    return '';
  }

  Map<String, dynamic> _extractWebDemoAttributes(Map<String, dynamic> editedAttributes) {
    final cleaned = Map<String, dynamic>.from(editedAttributes)
      ..removeWhere((key, value) => value == null || value.toString().trim().isEmpty);

    if (cleaned.isNotEmpty) {
      return cleaned;
    }

    final source = '${widget.rawUserInput} ${_brandController.text} ${_modelController.text}'.trim();
    final regex = RegExp(r'\b(\d+(?:ml|gb|tb|kg|l|cm|inch))\b', caseSensitive: false);
    final matches = regex.allMatches(source).map((m) => m.group(1)).whereType<String>().toList();

    if (matches.isNotEmpty) {
      return {'Rozmiar/Wariant (Demo)': matches.toSet().join(', ')};
    }

    return {'Wersja': 'Demonstracyjna'};
  }

  Future<void> _handleConfirm() async {
    setState(() {
      _isSavingLocal = true;
    });
    try {
      final Map<String, dynamic> updatedAttributes = {};
      _dynamicControllers.forEach((key, controller) {
        updatedAttributes[key] = controller.text.trim();
      });

      // Merge the dedicated variant field into attributes
      final variantText = _variantController.text.trim();
      if (variantText.isNotEmpty) {
        updatedAttributes['wariant'] = variantText;
      }

      final sanitizedAttributes = sanitizeAttributesMap(updatedAttributes);

      final parsedTargetPrice = double.tryParse(_priceController.text.replaceAll(',', '.'));
      if (parsedTargetPrice == null) {
        throw Exception('Missing or invalid targetPrice');
      }

      if (kIsWeb) {
        final demoAttributes = _extractWebDemoAttributes(sanitizedAttributes);

        widget.onWebDemoAdd({
          'brand': _brandController.text,
          'model': _modelController.text,
          'targetPrice': parsedTargetPrice,
          'condition': _selectedCondition,
          'attributes': demoAttributes,
        });

        if (!mounted) return;
        Navigator.of(context).pop();
        return;
      }

      final dbService = ref.read(databaseServiceProvider);

      await dbService.addTrackedItem({
        'brand': _brandController.text,
        'model': _modelController.text,
        'targetPrice': parsedTargetPrice,
        'condition': _selectedCondition,
        'category': widget.aiData['category'],
        'attributes': sanitizedAttributes,
        if (widget.aiData['volume_ml'] != null) 'volume_ml': widget.aiData['volume_ml'],
      });

      if (!mounted) return;

      Navigator.of(context).pop();
      widget.onSuccess();
    } catch (e) {
      if (mounted) {
        if (e is FreePlanLimitReachedException) {
          ref.read(aiSearchStateProvider.notifier).reset();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tr('free_plan_limit_reached')),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.of(context).pop();
          context.push('/premium');
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('failed_save', args: [e.toString()])),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingLocal = false;
        });
      }
    }
  }

  String _formatAttributeLabel(String key) {
    final translated = tr(key);
    if (translated != key) return translated;
    
    // Fallback: convert snake_case to Title Case
    return key.split('_').map((w) {
      if (w.isEmpty) return '';
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color);
    final currentRegion = ref.watch(regionProvider);
    final currencyPrefix = currencyPrefixForRegion(currentRegion);

    return AlertDialog(
      title: Text(tr('edit_details'), style: textStyle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _brandController,
              style: textStyle,
              decoration: InputDecoration(
                labelText: tr('brand'),
                labelStyle: TextStyle(color: Theme.of(context).hintColor),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _modelController,
              style: textStyle,
              decoration: InputDecoration(
                labelText: tr('model'),
                labelStyle: TextStyle(color: Theme.of(context).hintColor),
              ),
            ),
            const SizedBox(height: 8),
            // ── Variant / Capacity field ──────────────────────────
            TextField(
              controller: _variantController,
              style: textStyle,
              decoration: InputDecoration(
                labelText: 'Wariant / Pojemnosc (np. 35ml, 256GB) - opcjonalne',
                hintText: 'Jesli szukasz konkretnej wersji, wpisz ja tutaj.',
                hintStyle: TextStyle(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
                labelStyle: TextStyle(color: Theme.of(context).hintColor),
                prefixIcon: const Icon(Icons.tune, size: 18),
              ),
            ),
            // ─────────────────────────────────────────────────────
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              style: textStyle,
              decoration: InputDecoration(
                labelText: tr('target_price'),
                prefixText: currencyPrefix,
                labelStyle: TextStyle(color: Theme.of(context).hintColor),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                tr('condition'),
                style: theme.textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: _conditionOptions
                  .map(
                    (condition) => ButtonSegment<String>(
                      value: condition,
                      label: Text(condition),
                      enabled: !_isBeautyCategory || condition == 'NEW',
                    ),
                  )
                  .toList(),
              selected: <String>{_selectedCondition},
              onSelectionChanged: (selection) {
                if (_isBeautyCategory) {
                  return;
                }
                setState(() {
                  _selectedCondition = selection.first;
                });
              },
            ),
            // Dynamic category-specific attributes TextFields
            ..._dynamicControllers.entries.map((entry) {
              final key = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextField(
                  controller: controller,
                  style: textStyle,
                  decoration: InputDecoration(
                    labelText: _formatAttributeLabel(key),
                    labelStyle: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        if (!_isSavingLocal)
          TextButton(
            onPressed: () {
              ref.read(aiSearchStateProvider.notifier).reset();
              Navigator.of(context).pop();
            },
            child: Text(tr('cancel')),
          ),
        ElevatedButton(
          onPressed: _isSavingLocal ? null : _handleConfirm,
          child: _isSavingLocal
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(tr('confirm')),
        ),
      ],
    );
  }
}
