#!/bin/bash

# Wireless ADB Connection Script for Flutter Development
# Make sure your phone and Mac are on the same Wi-Fi network

echo "🔧 Wireless ADB Connection Helper"
echo "=================================="
echo ""
echo "On your Android phone:"
echo "1. Go to Settings → About Phone"
echo "2. Tap 'Build Number' 7 times (enable Developer Options)"
echo "3. Go to Settings → Developer Options"
echo "4. Enable 'Wireless Debugging'"
echo ""
echo "Enter your phone's IP address (from Wi-Fi settings):"
read PHONE_IP

echo ""
echo "Enter the port (usually 5555 or from Wireless Debugging):"
read PORT

echo ""
echo "Connecting to $PHONE_IP:$PORT..."

$ANDROID_HOME/platform-tools/adb connect $PHONE_IP:$PORT

echo ""
echo "Checking connected devices..."
$ANDROID_HOME/platform-tools/adb devices

echo ""
echo "✅ If your device appears above, you're connected!"
echo "Run: flutter run"
echo ""
echo "To disconnect: adb disconnect $PHONE_IP:$PORT"
