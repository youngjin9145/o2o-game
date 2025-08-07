#!/bin/bash
set -e

# Download and extract Flutter
echo "Downloading Flutter..."
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.3-stable.tar.xz | tar -xJ -C /tmp

# Fix ownership issues
echo "Setting up Flutter permissions..."
git config --global --add safe.directory /tmp/flutter

# Add Flutter to PATH
export PATH="/tmp/flutter/bin:$PATH"

# Configure Flutter for web (skip analytics)
echo "Configuring Flutter for web..."
flutter config --no-analytics --enable-web

# Install dependencies
echo "Installing dependencies..."
flutter pub get

# Build for web
echo "Building Flutter web app..."
flutter build web --release --base-href "/"

echo "Build completed successfully!"