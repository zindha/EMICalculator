import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Shared utility for capturing a widget tree wrapped in a [RepaintBoundary]
/// as a PNG image and sharing it via the native share sheet.
class ImageExportService {
  const ImageExportService._();

  /// Captures the [RepaintBoundary] at [captureKey] as a PNG, saves it to a
  /// temporary file, and triggers the native share sheet.
  ///
  /// [fileName] is the base name for the temporary file (without extension).
  /// [shareSubject] is the subject line used when sharing.
  /// [pixelRatio] controls the image resolution (default 3.0).
  ///
  /// Returns the path to the saved file, or `null` if the boundary was not
  /// found or the capture failed.
  static Future<String?> captureAndShare({
    required GlobalKey captureKey,
    required String fileName,
    required String shareSubject,
    double pixelRatio = 3.0,
  }) async {
    final boundary = captureKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData?.buffer.asUint8List();
    if (bytes == null) return null;

    final directory = await getTemporaryDirectory();
    final filePath = '$directory/$fileName.png';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(filePath)], subject: shareSubject);
    return filePath;
  }
}
