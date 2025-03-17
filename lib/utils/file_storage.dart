import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileStorage {
  static Future<void> writeToFile(String key, String value) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$key.txt');
      await file.writeAsString(value);
    } catch (e) {
      print('Error writing to file: $e');
    }
  }
  
  static Future<String?> readFromFile(String key) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$key.txt');
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      print('Error reading from file: $e');
    }
    return null;
  }
} 