#!/bin/bash

# Navigate to the project directory
cd "$(dirname "$0")"

# Fix permissions for the Pods directory
echo "Fixing permissions for Pods directory..."
chmod -R 755 ios/Pods

# Fix permissions for the frameworks.sh script
echo "Fixing permissions for Pods-Runner-frameworks.sh..."
chmod +x ios/Pods/Target\ Support\ Files/Pods-Runner/Pods-Runner-frameworks.sh

echo "Permissions fixed successfully!"

# Clean the build
echo "Cleaning build..."
flutter clean

# Get dependencies again
echo "Getting dependencies..."
flutter pub get

echo "Done! You can now try building for iOS again."

flutter pub run flutter_launcher_icons
flutter build ios --release
cd build/ios/iphoneos
mkdir Payload
mv Runner.app Payload/
zip -r Runner.ipa Payload
mv Runner.ipa ../../..