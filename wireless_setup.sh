#!/bin/bash

echo "📱 Wireless ADB Pairing & Connection"
echo "===================================="
echo ""
echo "⚠️  Make sure your phone and Mac are on the SAME Wi-Fi network!"
echo ""
echo "On your phone:"
echo "1. Settings → About Phone → Tap 'Build Number' 7 times"
echo "2. Settings → Developer Options → Enable 'Wireless Debugging'"
echo "3. Tap 'Wireless Debugging' → 'Pair device with pairing code'"
echo ""
read -p "Ready? Press Enter to continue..."
echo ""

# Step 1: Pairing
echo "🔗 Step 1: PAIRING"
echo "----------------"
echo "On your phone, you should see:"
echo "  - Pairing code (6 digits)"
echo "  - IP address:port (e.g., 192.168.1.100:37285)"
echo ""
read -p "Enter the PAIRING IP:PORT (e.g., 192.168.1.100:37285): " PAIR_ADDRESS

if [ -z "$PAIR_ADDRESS" ]; then
    echo "❌ Error: No address entered!"
    exit 1
fi

echo ""
read -p "Enter the 6-digit PAIRING CODE from your phone: " PAIR_CODE

if [ -z "$PAIR_CODE" ]; then
    echo "❌ Error: No pairing code entered!"
    exit 1
fi

echo ""
echo "Pairing with $PAIR_ADDRESS..."
echo "$PAIR_CODE" | $ANDROID_HOME/platform-tools/adb pair $PAIR_ADDRESS

echo ""
echo "⏳ Waiting 2 seconds..."
sleep 2

# Step 2: Connect
echo ""
echo "🔌 Step 2: CONNECTING"
echo "--------------------"
echo "Now go back to the main 'Wireless Debugging' screen on your phone."
echo "You'll see the main IP address and port (usually different from pairing port)"
echo ""
read -p "Enter the MAIN IP:PORT (e.g., 192.168.1.100:35847): " CONNECT_ADDRESS

if [ -z "$CONNECT_ADDRESS" ]; then
    echo "❌ Error: No connection address entered!"
    exit 1
fi

echo ""
echo "Connecting to $CONNECT_ADDRESS..."
$ANDROID_HOME/platform-tools/adb connect $CONNECT_ADDRESS

echo ""
echo "📋 Connected Devices:"
echo "--------------------"
$ANDROID_HOME/platform-tools/adb devices

echo ""
echo "✅ Setup Complete!"
echo ""
echo "To test, run: flutter devices"
echo "To run your app: flutter run"
echo ""
echo "💡 To reconnect later (no pairing needed):"
echo "   adb connect $CONNECT_ADDRESS"
echo ""
echo "To disconnect:"
echo "   adb disconnect"
