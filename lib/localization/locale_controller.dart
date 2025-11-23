import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kissan/core/services/tts_service.dart';

class AppLocaleController {
  static final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);
  static const _key = 'app_locale_code';

  static Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && code.isNotEmpty) {
      locale.value = Locale(code);
    }
  }

  static Future<void> setLocale(Locale? newLocale) async {
    locale.value = newLocale;
    final prefs = await SharedPreferences.getInstance();
    if (newLocale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, newLocale.languageCode);

      // Update TTS language when app language changes
      await TtsService.instance.setLanguage(newLocale.languageCode);
    }
  }
}
