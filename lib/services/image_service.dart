import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressionException implements Exception {
  final String message;

  const ImageCompressionException(this.message);

  @override
  String toString() => message;
}

class ImageService {
  static const int _maxBytes = 150 * 1024;
  static const int _minQuality = 20;
  static const int _initialQuality = 95;
  static const int _qualityStep = 7;
  static const int _minWidth = 480;
  static const int _minHeight = 480;

  const ImageService();

  Future<String> compressXFileToBase64(XFile file) async {
    final bytes = await file.readAsBytes();
    final compressed = await compressToUnder150kb(bytes);
    return base64Encode(compressed);
  }

  Future<Uint8List> compressToUnder150kb(Uint8List input) async {
    if (input.lengthInBytes < _maxBytes) {
      return input;
    }

    var current = input;
    var quality = _initialQuality;
    var width = 1600;
    var height = 1600;

    while (true) {
      final compressed = await FlutterImageCompress.compressWithList(
        current,
        quality: quality,
        minWidth: width,
        minHeight: height,
        format: CompressFormat.jpeg,
      );

      if (compressed.isNotEmpty && compressed.lengthInBytes < _maxBytes) {
        return compressed;
      }

      if (quality <= _minQuality && width <= _minWidth && height <= _minHeight) {
        throw const ImageCompressionException(
          'Failed to compress image below 150KB. Please choose a smaller image.',
        );
      }

      if (quality > _minQuality) {
        quality = (quality - _qualityStep).clamp(_minQuality, _initialQuality);
      }

      width = (width * 0.9).round().clamp(_minWidth, 1600);
      height = (height * 0.9).round().clamp(_minHeight, 1600);

      current = compressed.isNotEmpty ? compressed : current;
    }
  }
}
