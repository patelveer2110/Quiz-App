import 'dart:typed_data';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class QRService {
  // Generate QR image data for quiz code
  Future<Uint8List?> generateQRCode(String code) async {
    try {
      final qrPainter = QrPainter(
        data: code,
        version: QrVersions.auto,
        gapless: false,
      );

      final picData = await qrPainter.toImageData(300);
      return picData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("QR Generation Error: $e");
      return null;
    }
  }

  // Show QR as widget
  Widget qrWidget(String code) {
    return QrImageView( // ✅ Updated from QrImage
      data: code,
      size: 200,
      backgroundColor: Colors.white,
    );
  }
}
