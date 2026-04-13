#!/bin/bash

# Configuration
APP_NAME="WordFlow"
BUILD_NUMBER=$(date +%Y%m%d%H%M)
SYMBOL_PATH="build/app/outputs/symbols"

echo "🚀 Starting Production Build for $APP_NAME..."

# Clean project
flutter clean
flutter pub get

# Build Android App Bundle with Obfuscation
echo "📦 Building Android App Bundle (AAB)..."
flutter build appbundle \
  --obfuscate \
  --split-debug-info=$SYMBOL_PATH \
  --release

# Build APK (optional but useful for testing)
echo "📦 Building Android APK..."
flutter build apk \
  --obfuscate \
  --split-debug-info=$SYMBOL_PATH \
  --release

echo "✅ Build Complete!"
echo "📍 AAB: build/app/outputs/bundle/release/app-release.aab"
echo "📍 Symbols: $SYMBOL_PATH"
