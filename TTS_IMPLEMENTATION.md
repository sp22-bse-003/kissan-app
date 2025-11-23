# Text-to-Speech (TTS) Implementation

## 🎯 Overview
The Kissan app now has full Text-to-Speech functionality integrated across all seller screens, making it accessible for users who prefer audio feedback.

## 🔧 Architecture

### 1. **TtsService** (`lib/core/services/tts_service.dart`)
Singleton service that manages all TTS functionality:
- Auto-initializes with the app's current language
- Syncs with language changes (English ↔ Urdu)
- Provides consistent speech across the app

### 2. **TtsIconButton** (`lib/core/widgets/tts_icon_button.dart`)
Reusable widget for adding TTS to any text:
- Animated speaker icon
- Tap to speak, tap again to stop
- Visual feedback when speaking
- Auto-stops when done

## 📱 Integration

### Initialized in main.dart:
```dart
await TtsService.instance.initialize(
  language: currentLocale?.languageCode ?? 'en',
);
```

### Auto-syncs with language changes:
```dart
// In locale_controller.dart
await TtsService.instance.setLanguage(newLocale.languageCode);
```

## 🎨 Where TTS is Active

### ✅ Product Form Screen
- All form field labels have TTS buttons
- Product Name, Price, Quantity, Category, Description

### ✅ Products Screen
- Each product card has a TTS button
- Speaks product name when tapped

### ✅ Orders Screen
- Each order card has a TTS button
- Speaks order title when tapped

### ✅ Dashboard Screen
- Order cards have TTS buttons
- Speaks order information

## 🎤 Usage Examples

### Simple TTS Button:
```dart
import 'package:kissan/core/widgets/tts_icon_button.dart';

TtsIconButton(
  text: 'Hello World',
  iconSize: 20,
  iconColor: Colors.grey,
  tooltip: 'Tap to listen',
)
```

### Direct TTS Service Call:
```dart
import 'package:kissan/core/services/tts_service.dart';

// Speak text
await TtsService.instance.speak('Hello World');

// Change language
await TtsService.instance.setLanguage('ur'); // Urdu
await TtsService.instance.setLanguage('en'); // English

// Adjust settings
await TtsService.instance.setSpeechRate(0.5); // Normal speed
await TtsService.instance.setVolume(1.0);      // Full volume
await TtsService.instance.setPitch(1.0);       // Normal pitch

// Stop speaking
await TtsService.instance.stop();
```

## 🌍 Language Support

### English (en-US)
- High-quality native voice
- Clear pronunciation
- Fast response

### Urdu (ur-PK)
- Native Urdu voice
- Proper pronunciation
- Supports Urdu text

## 🔄 Automatic Language Sync

When user changes app language:
1. AppLocaleController updates
2. TTS language automatically switches
3. Next speech uses new language
4. No manual intervention needed

## 🎯 Benefits

### For Farmers:
- ✅ Hands-free information access
- ✅ Helps users with reading difficulties
- ✅ Multi-language support (Urdu/English)
- ✅ Better accessibility

### For App:
- ✅ Modern, user-friendly interface
- ✅ Consistent TTS across all screens
- ✅ Easy to maintain
- ✅ Reusable components

## 🚀 Features

1. **Auto-Initialization**: TTS starts with the app
2. **Language Sync**: Follows app language changes
3. **Visual Feedback**: Animated icons show speaking state
4. **Error Handling**: Graceful fallbacks if TTS fails
5. **Platform Support**: Works on Android, iOS, Web, Desktop

## 📝 Notes

- TTS uses device's native speech engine
- Requires internet for first-time language download (on some devices)
- Some Android devices may need Google TTS app installed
- iOS has built-in TTS for all languages
