import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CreateIOSIcon {
  static Future<void> generateIcon() async {
    // Create a simple icon - a blue circle with a dollar sign
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(1024, 1024);
    
    // Background
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
    
    // Dollar sign
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 600,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: '\$',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
    
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    
    // Create directory if it doesn't exist
    final directory = Directory('assets/icon');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    // Save the image
    final file = File('assets/icon/app_icon.png');
    await file.writeAsBytes(buffer);
    
    print('iOS app icon generated at: ${file.path}');
  }
} 