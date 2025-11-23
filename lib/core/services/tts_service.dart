import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

/// Centralized Text-to-Speech Service
/// Manages TTS functionality across the app with language support
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  String _currentLanguage = 'en-US';

  /// Get the singleton instance
  static TtsService get instance => _instance;

  /// Initialize TTS with default settings
  Future<void> initialize({String language = 'en-US'}) async {
    if (_isInitialized) return;

    try {
      // Set default language
      await setLanguage(language);

      // Configure TTS settings
      await _flutterTts.setSpeechRate(0.5); // Normal speed
      await _flutterTts.setVolume(1.0); // Full volume
      await _flutterTts.setPitch(1.0); // Normal pitch

      // Platform-specific settings
      if (kIsWeb) {
        // Web-specific configuration
        debugPrint('🌐 Initializing TTS for Web');
        // Web TTS uses browser's Speech Synthesis API
        // It should work automatically, no special config needed
      } else {
        await _flutterTts.awaitSpeakCompletion(true);
      }

      // Set up handlers
      _flutterTts.setStartHandler(() {
        debugPrint('🔊 TTS Started');
      });

      _flutterTts.setCompletionHandler(() {
        debugPrint('✅ TTS Completed');
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint('❌ TTS Error: $msg');
      });

      _isInitialized = true;
      debugPrint('✅ TTS Service Initialized with language: $_currentLanguage');

      if (kIsWeb) {
        debugPrint('🌐 Web TTS ready - using browser Speech Synthesis API');
      }
    } catch (e) {
      debugPrint('❌ TTS Initialization Error: $e');
    }
  }

  /// Change TTS language
  Future<void> setLanguage(String languageCode) async {
    try {
      // Map language codes
      String ttsLanguage;
      switch (languageCode) {
        case 'ur':
          ttsLanguage = 'ur-PK'; // Urdu (Pakistan)
          break;
        case 'en':
          ttsLanguage = 'en-US'; // English (US)
          break;
        default:
          ttsLanguage = 'en-US';
      }

      await _flutterTts.setLanguage(ttsLanguage);
      _currentLanguage = ttsLanguage;
      debugPrint('🌍 TTS Language set to: $ttsLanguage');
    } catch (e) {
      debugPrint('❌ Error setting TTS language: $e');
    }
  }

  /// Speak text with current language
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (text.trim().isEmpty) return;

      // Stop any ongoing speech
      await stop();

      if (kIsWeb) {
        debugPrint('🌐 Web TTS: Speaking "$text"');
      }

      // Speak the text
      final result = await _flutterTts.speak(text);

      if (kIsWeb) {
        debugPrint('🌐 Web TTS Speak Result: $result');
      }

      debugPrint('🔊 Speaking: $text');
    } catch (e) {
      debugPrint('❌ TTS Speak Error: $e');
      if (kIsWeb) {
        debugPrint(
          '💡 TIP: Make sure to interact with the page first (click anywhere) to enable Web Speech API',
        );
      }
    }
  }

  /// Stop current speech
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('❌ TTS Stop Error: $e');
    }
  }

  /// Pause current speech
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      debugPrint('❌ TTS Pause Error: $e');
    }
  }

  /// Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('❌ TTS Set Speech Rate Error: $e');
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('❌ TTS Set Volume Error: $e');
    }
  }

  /// Set pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    try {
      await _flutterTts.setPitch(pitch.clamp(0.5, 2.0));
    } catch (e) {
      debugPrint('❌ TTS Set Pitch Error: $e');
    }
  }

  /// Get available languages
  Future<List<dynamic>> getLanguages() async {
    try {
      return await _flutterTts.getLanguages;
    } catch (e) {
      debugPrint('❌ TTS Get Languages Error: $e');
      return [];
    }
  }

  /// Get available voices
  Future<List<dynamic>> getVoices() async {
    try {
      return await _flutterTts.getVoices;
    } catch (e) {
      debugPrint('❌ TTS Get Voices Error: $e');
      return [];
    }
  }

  /// Check if TTS is currently speaking
  Future<bool> isSpeaking() async {
    try {
      // Note: isSpeaking is not available on all platforms
      // Return false as a safe default
      return false;
    } catch (e) {
      debugPrint('❌ TTS Is Speaking Error: $e');
      return false;
    }
  }

  /// Dispose TTS resources
  Future<void> dispose() async {
    try {
      await stop();
      _isInitialized = false;
    } catch (e) {
      debugPrint('❌ TTS Dispose Error: $e');
    }
  }
}
