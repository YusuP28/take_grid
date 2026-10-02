import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

enum ExportFormat { jpg, png }

enum ExportQuality {
  hd720('720p', 720),
  fhd1080('1080p', 1080),
  qhd1440('1440p', 1440),
  uhd2048('2048p', 2048),
  uhd4k('4K', 2160);

  final String label;
  final int px;
  const ExportQuality(this.label, this.px);
}

class ExportResult {
  final bool success;
  final String? path;
  final String? error;
  ExportResult({required this.success, this.path, this.error});
}

class ExportService {
  static final ExportService _i = ExportService._();
  factory ExportService() => _i;
  ExportService._();

  /// Capture widget dari GlobalKey → bytes PNG
  Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('captureWidget error: $e');
      return null;
    }
  }

  /// Proses + save ke galeri
  Future<ExportResult> saveToGallery({
    required Uint8List pngBytes,
    required ExportFormat format,
    required ExportQuality quality,
  }) async {
    try {
      // Proses di isolate (compute)
      final output = await compute(
        _processImage,
        _ProcessArgs(pngBytes, format.index, quality.px),
      );
      if (output == null) {
        return ExportResult(success: false, error: 'Gagal proses gambar');
      }

      final ext = format == ExportFormat.jpg ? 'jpg' : 'png';
      final filename = 'TakeGrid_${DateTime.now().millisecondsSinceEpoch}.$ext';

      final dir = await getTemporaryDirectory();
      final tempFile = File('${dir.path}/$filename');
      await tempFile.writeAsBytes(output);

      final ms = MediaStore();
      await ms.saveFile(
        tempFilePath: tempFile.path,
        dirType: DirType.download,
        dirName: DirType.download.defaults,
      );

      try { await tempFile.delete(); } catch (_) {}

      return ExportResult(success: true, path: filename);
    } catch (e) {
      debugPrint('saveToGallery error: $e');
      return ExportResult(success: false, error: e.toString());
    }
  }

  /// Save ke temp file (untuk share)
  Future<File?> saveToTempFile({
    required Uint8List pngBytes,
    required ExportFormat format,
    required ExportQuality quality,
  }) async {
    try {
      final decoded = img.decodeImage(pngBytes);
      if (decoded == null) return null;

      final resized = img.copyResize(
        decoded,
        width: quality.px,
        height: quality.px,
        interpolation: img.Interpolation.cubic,
      );

      Uint8List output;
      String ext;
      if (format == ExportFormat.jpg) {
        output = Uint8List.fromList(img.encodeJpg(resized, quality: 92));
        ext = 'jpg';
      } else {
        output = Uint8List.fromList(img.encodePng(resized));
        ext = 'png';
      }

      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/TakeGrid_${DateTime.now().millisecondsSinceEpoch}.$ext');
      await file.writeAsBytes(output);
      return file;
    } catch (e) {
      debugPrint('saveToTempFile error: $e');
      return null;
    }
  }

  /// Cek permission galeri
  Future<bool> hasGalleryAccess() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.status;
        if (status.isGranted) return true;
        // Android 13+: photos permission
        final photos = await Permission.photos.status;
        return photos.isGranted;
      }
      return true;
    } catch (_) {
      return true;
    }
  }

  Future<bool> requestGalleryAccess() async {
    try {
      if (Platform.isAndroid) {
        final result = await [Permission.storage, Permission.photos].request();
        return result.values.any((s) => s.isGranted);
      }
      return true;
    } catch (_) {
      return true;
    }
  }
}

class _ProcessArgs {
  final Uint8List bytes;
  final int formatIndex;
  final int px;
  _ProcessArgs(this.bytes, this.formatIndex, this.px);
}

/// Fungsi di isolate — decode, resize, encode
Uint8List? _processImage(_ProcessArgs args) {
  try {
    final decoded = img.decodeImage(args.bytes);
    if (decoded == null) return null;

    final resized = img.copyResize(
      decoded,
      width: args.px,
      height: args.px,
      interpolation: img.Interpolation.cubic,
    );

    if (args.formatIndex == 0) {
      // JPG
      return Uint8List.fromList(img.encodeJpg(resized, quality: 92));
    } else {
      return Uint8List.fromList(img.encodePng(resized));
    }
  } catch (_) {
    return null;
  }
}
