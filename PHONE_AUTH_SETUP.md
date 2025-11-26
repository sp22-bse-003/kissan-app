# Firebase Phone Authentication Setup Guide

## 🚨 Why SMS is Not Being Sent

Firebase Phone Authentication requires proper configuration before SMS messages will be sent. Here's what you need to know:

### Common Issues:
1. **Phone Authentication Not Enabled** in Firebase Console
2. **Development Mode** - Firebase may block SMS to prevent costs
3. **Missing SHA Certificates** (Android)
4. **Missing APNs Configuration** (iOS)
5. **Billing Not Enabled** on Firebase (free tier has limits)

---

## 📱 Step-by-Step Setup

### 1. Firebase Console Configuration

#### Enable Phone Authentication:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `kissan-cae04`
3. Go to **Authentication** → **Sign-in method**
4. Click on **Phone** provider
5. Click **Enable** toggle
6. Click **Save**

#### Add Test Phone Numbers (For Development):
1. In the same **Phone** section
2. Scroll down to **Phone numbers for testing**
3. Add test numbers:
   - Phone: `+923001234567` → Code: `123456`
   - Phone: `+923009876543` → Code: `654321`
4. These numbers will work **without sending actual SMS**

---

### 2. Android Configuration (SHA Certificate)

Firebase Phone Auth on Android requires SHA-1 and SHA-256 certificates.

#### Get SHA Certificates:
```bash
cd android
./gradlew signingReport
```

Look for SHA-1 and SHA-256 under `Variant: debug`:
```
SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
SHA256: 11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44...
```

#### Add SHA to Firebase:
1. Firebase Console → Project Settings (⚙️ icon)
2. Scroll to **Your apps** → Android app
3. Click **Add fingerprint**
4. Paste SHA-1 (both debug and release)
5. Paste SHA-256 (both debug and release)
6. Download the new `google-services.json`
7. Replace `android/app/google-services.json` with the new file

#### Rebuild the App:
```bash
cd ..
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

---

### 3. iOS Configuration (APNs)

Firebase Phone Auth on iOS requires Apple Push Notification service (APNs) certificates.

#### Setup APNs:
1. Go to [Apple Developer](https://developer.apple.com/)
2. Create an **APNs Authentication Key**:
   - Certificates, Identifiers & Profiles → Keys
   - Create new key with APNs enabled
   - Download the `.p8` file
3. In Firebase Console:
   - Project Settings → Cloud Messaging
   - Under iOS app configuration
   - Upload APNs Authentication Key (.p8 file)
   - Enter Key ID and Team ID

#### Update iOS Configuration:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Enable Push Notifications capability
3. Download new `GoogleService-Info.plist` from Firebase
4. Replace `ios/Runner/GoogleService-Info.plist`

---

### 4. Enable Firebase Billing (Required for SMS)

Firebase's **Spark (free) plan** has very limited SMS quotas. For production:

1. Firebase Console → Upgrade to **Blaze (Pay as you go)**
2. Phone Authentication Costs:
   - **Free tier**: 10,000 verifications/month for US/Canada/India
   - **After limit**: ~$0.01 per verification (varies by country)
3. Set up budget alerts to avoid unexpected charges

---

## 🧪 Testing Options

### Option 1: Test Phone Numbers (Recommended for Development)

Add test phone numbers in Firebase Console (as described in Step 1). These work **instantly without SMS**.

**Usage:**
- Use test number: `+923001234567`
- Enter OTP: `123456` (the code you configured)
- No SMS sent, no costs, instant verification

### Option 2: Real Phone Numbers (Production)

After completing all setup steps above, real SMS will be sent.

**Testing:**
- Use your actual phone number
- Wait 10-30 seconds for SMS
- SMS may take longer in some countries
- Check spam/blocked messages if not received

---

## 🔧 Implementation Updates Needed

### Add Test Mode Support

Update your app to support test phone numbers during development:

```dart
// In auth_service.dart
static const testPhoneNumbers = {
  '+923001234567': '123456',
  '+923009876543': '654321',
};

bool isTestPhoneNumber(String phone) {
  return testPhoneNumbers.containsKey(phone);
}

String? getTestOTP(String phone) {
  return testPhoneNumbers[phone];
}
```

---

## 📊 Verification Status Checklist

Before expecting SMS:
- [ ] Phone Authentication enabled in Firebase Console
- [ ] Test phone numbers added (for development)
- [ ] SHA certificates added (Android)
- [ ] APNs configured (iOS)
- [ ] Firebase project upgraded to Blaze plan (for production)
- [ ] `google-services.json` updated (Android)
- [ ] `GoogleService-Info.plist` updated (iOS)
- [ ] App rebuilt after configuration changes

---

## 🐛 Troubleshooting

### "SMS Not Received"
1. Check Firebase Console → Authentication → Usage
2. Verify phone number format: `+92` prefix required
3. Try test phone numbers first
4. Check Firebase logs for errors

### "reCAPTCHA Not Appearing"
- This is normal on physical devices
- reCAPTCHA mainly appears on web/emulators
- Not required on real Android/iOS devices with proper setup

### "Network Error"
- Ensure internet connection
- Check Firebase project ID matches
- Verify SHA certificates are correct (Android)

### "Invalid Phone Number"
- Must include country code: `+92`
- No spaces or special characters: `+923001234567`
- Pakistan format: `+92` + 10 digits

---

## 🚀 Quick Start (Development Mode)

**For immediate testing without SMS:**

1. Firebase Console → Authentication → Phone → Enable
2. Add test number: `+923001234567` with code `123456`
3. In your app, use `+923001234567`
4. Enter OTP: `123456`
5. ✅ You're in! (No SMS needed)

---

## 📱 Production Deployment

When ready to deploy:

1. Complete all setup steps (SHA, APNs, Billing)
2. Remove test phone numbers from Firebase Console
3. Test with real phone numbers
4. Monitor Firebase Console → Authentication → Usage
5. Set up budget alerts in Google Cloud Console

---

## 🌍 Country-Specific Notes

### Pakistan (+92)
- SMS delivery: Usually 10-30 seconds
- Carriers: Jazz, Telenor, Zong, Ufone all supported
- Cost: ~$0.01-0.02 per SMS
- Format: `+92` + 10 digits (e.g., `+923001234567`)

---

## 🔐 Security Best Practices

1. **Never hardcode test OTPs** in production
2. **Rate limit** OTP requests (Firebase has built-in limits)
3. **Monitor usage** to detect abuse
4. **Set budget alerts** to control costs
5. **Use phone + password** for returning users (no SMS cost)

---

## 📞 Support

If issues persist:
- Check [Firebase Documentation](https://firebase.google.com/docs/auth/flutter/phone-auth)
- Review [FlutterFire Issues](https://github.com/firebase/flutterfire/issues)
- Check Firebase Console → Support → Create ticket
