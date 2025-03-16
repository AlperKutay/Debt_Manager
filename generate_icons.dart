import 'dart:io';

void main() async {
  print('Generating app icons...');
  
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
  
  print('App icons generation complete!');
} 