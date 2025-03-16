import 'dart:io';

void main() {
  final directory = Directory('lib');
  final files = directory.listSync(recursive: true);
  
  for (var file in files) {
    if (file is File && file.path.endsWith('.dart')) {
      final content = file.readAsStringSync();
      final regex = RegExp(r'Text\(\s*[\'"]([^\'"]+)[\'"]');
      final matches = regex.allMatches(content);
      
      if (matches.isNotEmpty) {
        print('File: ${file.path}');
        for (var match in matches) {
          if (match.group(1) != null) {
            print('  - "${match.group(1)}"');
          }
        }
        print('');
      }
    }
  }
} 