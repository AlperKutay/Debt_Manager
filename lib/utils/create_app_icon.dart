import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class CreateAppIcon {
  static Future<void> createAndSaveIcon() async {
    // Create a widget that will be rendered to an image
    final iconWidget = Container(
      width: 1024,
      height: 1024,
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '\$',
          style: TextStyle(
            color: Colors.white,
            fontSize: 600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    // Create a RepaintBoundary to capture the widget as an image
    final repaintBoundary = RepaintBoundary(
      child: iconWidget,
    );

    // Create a BuildContext to render the widget
    final buildContext = await _createBuildContext();
    
    // Render the widget to an image
    final image = await _captureWidget(repaintBoundary, buildContext);
    
    // Save the image to the assets directory
    await _saveImageToAssets(image);
  }

  static Future<BuildContext> _createBuildContext() async {
    final completer = Completer<BuildContext>();
    
    runApp(
      MaterialApp(
        home: Builder(
          builder: (context) {
            // Capture the context and complete the future
            completer.complete(context);
            return Container(); // Placeholder
          },
        ),
      ),
    );
    
    return completer.future;
  }

  static Future<ui.Image> _captureWidget(Widget widget, BuildContext context) async {
    // Create a RenderObject
    final renderObject = RenderRepaintBoundary();
    
    // Create a RenderObjectWidget
    final renderObjectWidget = RepaintBoundary(
      child: widget,
    );
    
    // Attach the RenderObject to the RenderObjectWidget
    final element = renderObjectWidget.createElement();
    element.mount(null, null);
    
    // Render the widget to an image
    final image = await renderObject.toImage(pixelRatio: 1.0);
    return image;
  }

  static Future<void> _saveImageToAssets(ui.Image image) async {
    // Convert the image to bytes
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    
    // Save the image to the assets directory
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/app_icon.png');
    await file.writeAsBytes(pngBytes);
    
    print('App icon saved to: ${file.path}');
  }
} 