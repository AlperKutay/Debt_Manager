import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

class NotificationPatch {
  static Future<void> applyPatch() async {
    try {
      // Get the path to the flutter_local_notifications package
      final packageInfo = await PlatformAssetBundle().loadString('packages/flutter_local_notifications/package_info.json');
      final packagePath = packageInfo.split('"packagePath":"')[1].split('"')[0];
      
      // Path to the Java file that needs patching
      final javaFilePath = path.join(
        packagePath, 
        'android/src/main/java/com/dexterous/flutterlocalnotifications/FlutterLocalNotificationsPlugin.java'
      );
      
      // Read the file
      final file = File(javaFilePath);
      if (!await file.exists()) {
        print('File not found: $javaFilePath');
        return;
      }
      
      String content = await file.readAsString();
      
      // Replace the problematic line
      if (content.contains('bigPictureStyle.bigLargeIcon(null);')) {
        content = content.replaceAll(
          'bigPictureStyle.bigLargeIcon(null);',
          'bigPictureStyle.bigLargeIcon((Bitmap) null);'
        );
        
        // Write the modified content back to the file
        await file.writeAsString(content);
        print('Successfully patched flutter_local_notifications plugin');
      } else {
        print('Could not find the line to patch');
      }
    } catch (e) {
      print('Error applying patch: $e');
    }
  }
} 