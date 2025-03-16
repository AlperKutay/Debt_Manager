import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class IconGenerator {
  static Future<void> generateIcons() async {
    // Create directory if it doesn't exist
    final directory = Directory('assets/images');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    // Generate main icon
    await _generateMainIcon();
    
    // Generate foreground icon
    await _generateForegroundIcon();
    
    print('Icons generated successfully!');
  }
  
  static Future<void> _generateMainIcon() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(1024, 1024);
    
    // Draw blue circle background
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
    
    // Draw dollar sign
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '\$',
        style: TextStyle(
          color: Colors.white,
          fontSize: 600,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
    
    // Convert to image
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    
    // Save to file
    final file = File('assets/images/app_icon.png');
    await file.writeAsBytes(buffer);
    print('Main icon saved to: ${file.path}');
  }
  
  static Future<void> _generateForegroundIcon() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(1024, 1024);
    
    // Draw dollar sign only (no background)
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '\$',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 700,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
    
    // Convert to image
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    
    // Save to file
    final file = File('assets/images/app_icon_foreground.png');
    await file.writeAsBytes(buffer);
    print('Foreground icon saved to: ${file.path}');
  }
} 