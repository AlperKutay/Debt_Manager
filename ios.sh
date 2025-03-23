#!/bin/bash

# Navigate to the project directory
cd "$(dirname "$0")"

# Generate the app icon
echo "Generating app icon..."
dart generate_ios_icon.dart

# Fix permissions for the Pods directory
echo "Fixing permissions for Pods directory..."
chmod -R 755 ios/Pods 2>/dev/null || true

# Fix permissions for the frameworks.sh script
echo "Fixing permissions for Pods-Runner-frameworks.sh..."
chmod +x ios/Pods/Target\ Support\ Files/Pods-Runner/Pods-Runner-frameworks.sh 2>/dev/null || true

echo "Permissions fixed successfully!"

# Clean the build
echo "Cleaning build..."
flutter clean

# Get dependencies again
echo "Getting dependencies..."
flutter pub get

echo "Done! You can now try building for iOS again."

flutter pub run flutter_launcher_icons:main
flutter build ios --release

echo "Creating IPA file..."
cd build/ios/iphoneos
mkdir -p Payload
cp -r Runner.app Payload/
zip -r Runner.ipa Payload
mv Runner.ipa ../../..
cd ../../..

echo "Done! IPA file created at $(pwd)/Runner.ipa"