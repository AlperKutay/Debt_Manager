import 'dart:io';
import 'lib/utils/create_ios_icon.dart';

void main() async {
  print('Generating iOS app icon...');
  
  // Generate the icon
  await CreateIOSIcon.generateIcon();
  
  // Run flutter pub get to ensure dependencies are up to date
  await Process.run('flutter', ['pub', 'get']);
  
  // Run flutter_launcher_icons
  final result = await Process.run(
    'flutter', 
    ['pub', 'run', 'flutter_launcher_icons']
  );
  
  print(result.stdout);
  
  if (result.stderr.toString().isNotEmpty) {
    print('Error: ${result.stderr}');
  }
  
  print('iOS app icon generation complete!');
} 