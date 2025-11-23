import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

/// Translation service for Firebase data and dynamic content
/// This service provides runtime translation for data fetched from Firebase
/// Uses ML Kit for automatic translation of descriptions and dynamic content
/// Note: ML Kit only works on mobile/desktop, not on web
class TranslationService {
  // ML Kit translator instances (cached for performance)
  static OnDeviceTranslator? _enToUrTranslator;
  static OnDeviceTranslator? _urToEnTranslator;

  // Track if models are downloaded
  static bool _modelsDownloaded = false;

  // Check if ML Kit is available on current platform
  static bool get isMLKitAvailable => !kIsWeb;

  /// Initialize ML Kit translators (only on mobile/desktop)
  static Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint(
        'ℹ️ ML Kit Translation not available on web - using static translations only',
      );
      return;
    }

    try {
      _enToUrTranslator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: TranslateLanguage.urdu,
      );

      _urToEnTranslator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.urdu,
        targetLanguage: TranslateLanguage.english,
      );

      debugPrint('✅ ML Kit Translation initialized');
    } catch (e) {
      debugPrint('❌ Error initializing ML Kit Translation: $e');
    }
  }

  /// Download translation models (called once, on WiFi recommended)
  /// Only works on mobile/desktop platforms
  static Future<bool> downloadModels() async {
    if (kIsWeb) {
      debugPrint('ℹ️ ML Kit not available on web');
      return false;
    }

    if (_modelsDownloaded) return true;

    try {
      final modelManager = OnDeviceTranslatorModelManager();

      // Check if models are already downloaded
      final isEnDownloaded = await modelManager.isModelDownloaded(
        TranslateLanguage.english.bcpCode,
      );
      final isUrDownloaded = await modelManager.isModelDownloaded(
        TranslateLanguage.urdu.bcpCode,
      );

      if (isEnDownloaded && isUrDownloaded) {
        _modelsDownloaded = true;
        debugPrint('✅ Translation models already downloaded');
        return true;
      }

      // Download models if not present
      debugPrint('📥 Downloading translation models...');

      if (!isEnDownloaded) {
        await modelManager.downloadModel(TranslateLanguage.english.bcpCode);
      }

      if (!isUrDownloaded) {
        await modelManager.downloadModel(TranslateLanguage.urdu.bcpCode);
      }

      _modelsDownloaded = true;
      debugPrint('✅ Translation models downloaded successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error downloading models: $e');
      return false;
    }
  }

  /// Check if translation models are available
  static Future<bool> areModelsDownloaded() async {
    if (kIsWeb) return false;
    try {
      final modelManager = OnDeviceTranslatorModelManager();
      final isEnDownloaded = await modelManager.isModelDownloaded(
        TranslateLanguage.english.bcpCode,
      );
      final isUrDownloaded = await modelManager.isModelDownloaded(
        TranslateLanguage.urdu.bcpCode,
      );
      return isEnDownloaded && isUrDownloaded;
    } catch (e) {
      return false;
    }
  }

  /// Dispose translators (call when app is closing)
  static void dispose() {
    _enToUrTranslator?.close();
    _urToEnTranslator?.close();
    _enToUrTranslator = null;
    _urToEnTranslator = null;
  }

  // Product categories translation
  static const Map<String, Map<String, String>> _categoryTranslations = {
    'Seeds': {'en': 'Seeds', 'ur': 'بیج'},
    'Crops': {'en': 'Crops', 'ur': 'فصلیں'},
    'Fertilizers': {'en': 'Fertilizers', 'ur': 'کھاد'},
    'Pesticides': {'en': 'Pesticides', 'ur': 'کیڑے مار دوا'},
    'Feeds': {'en': 'Feeds', 'ur': 'چارہ'},
    'Chemicals': {'en': 'Chemicals', 'ur': 'کیمیکلز'},
  };

  // Common words translation
  static const Map<String, Map<String, String>> _commonTranslations = {
    'Available': {'en': 'Available', 'ur': 'دستیاب'},
    'Out of Stock': {'en': 'Out of Stock', 'ur': 'اسٹاک ختم'},
    'New': {'en': 'New', 'ur': 'نیا'},
    'Used': {'en': 'Used', 'ur': 'استعمال شدہ'},
    'Pending': {'en': 'Pending', 'ur': 'زیر التواء'},
    'Approved': {'en': 'Approved', 'ur': 'منظور شدہ'},
    'Rejected': {'en': 'Rejected', 'ur': 'مسترد'},
    'Delivered': {'en': 'Delivered', 'ur': 'پہنچایا گیا'},
    'Cancelled': {'en': 'Cancelled', 'ur': 'منسوخ'},
  };

  // Cities translation
  static const Map<String, Map<String, String>> _cityTranslations = {
    'Karachi': {'en': 'Karachi', 'ur': 'کراچی'},
    'Lahore': {'en': 'Lahore', 'ur': 'لاہور'},
    'Islamabad': {'en': 'Islamabad', 'ur': 'اسلام آباد'},
    'Rawalpindi': {'en': 'Rawalpindi', 'ur': 'راولپنڈی'},
    'Faisalabad': {'en': 'Faisalabad', 'ur': 'فیصل آباد'},
    'Multan': {'en': 'Multan', 'ur': 'ملتان'},
    'Peshawar': {'en': 'Peshawar', 'ur': 'پشاور'},
    'Quetta': {'en': 'Quetta', 'ur': 'کوئٹہ'},
    'Sialkot': {'en': 'Sialkot', 'ur': 'سیالکوٹ'},
    'Gujranwala': {'en': 'Gujranwala', 'ur': 'گوجرانوالہ'},
    'Sahiwal': {'en': 'Sahiwal', 'ur': 'ساہیوال'},
  };

  /// Get current language code from context
  static String _getCurrentLanguage(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode;
  }

  /// Translate category name
  static String translateCategory(String category, BuildContext context) {
    final lang = _getCurrentLanguage(context);
    return _categoryTranslations[category]?[lang] ?? category;
  }

  /// Translate city name
  static String translateCity(String city, BuildContext context) {
    final lang = _getCurrentLanguage(context);
    return _cityTranslations[city]?[lang] ?? city;
  }

  /// Translate common word
  static String translateCommon(String word, BuildContext context) {
    final lang = _getCurrentLanguage(context);
    return _commonTranslations[word]?[lang] ?? word;
  }

  /// Get all categories in current language
  static List<String> getCategories(BuildContext context) {
    final lang = _getCurrentLanguage(context);
    return _categoryTranslations.values
        .map((translations) => translations[lang] ?? translations['en']!)
        .toList();
  }

  /// Get all cities in current language
  static List<String> getCities(BuildContext context) {
    final lang = _getCurrentLanguage(context);
    return _cityTranslations.values
        .map((translations) => translations[lang] ?? translations['en']!)
        .toList();
  }

  /// Reverse translate category from Urdu to English (for Firebase queries)
  static String categoryToEnglish(String category) {
    for (var entry in _categoryTranslations.entries) {
      if (entry.value['ur'] == category) {
        return entry.key;
      }
    }
    return category; // Return as-is if not found
  }

  /// Reverse translate city from Urdu to English (for Firebase queries)
  static String cityToEnglish(String city) {
    for (var entry in _cityTranslations.entries) {
      if (entry.value['ur'] == city) {
        return entry.key;
      }
    }
    return city; // Return as-is if not found
  }

  /// Translate product name (simple word-by-word translation for common terms)
  static String translateProductName(String name, BuildContext context) {
    final lang = _getCurrentLanguage(context);

    if (lang == 'en') return name;

    // Common product terms translation map
    final productTerms = {
      'Wheat': 'گندم',
      'Rice': 'چاول',
      'Corn': 'مکئی',
      'Cotton': 'کپاس',
      'Urea': 'یوریا',
      'DAP': 'ڈی اے پی',
      'Organic': 'نامیاتی',
      'Hybrid': 'ہائبرڈ',
      'Seeds': 'بیج',
      'Fertilizer': 'کھاد',
      'Spray': 'سپرے',
      'Insecticide': 'کیڑے مار',
      'Herbicide': 'جڑی بوٹی مار',
      'Tractor': 'ٹریکٹر',
      'Plough': 'ہل',
      'Water': 'پانی',
      'Soil': 'مٹی',
      'Premium': 'پریمیم',
      'Quality': 'معیار',
      'Best': 'بہترین',
      'Super': 'سپر',
      'Extra': 'اضافی',
      'Pure': 'خالص',
      'Natural': 'قدرتی',
      'Fresh': 'تازہ',
      'Green': 'سبز',
      'White': 'سفید',
      'Red': 'سرخ',
      'Black': 'کالا',
      'Yellow': 'پیلا',
    };

    // Try to translate word by word
    String translated = name;
    productTerms.forEach((english, urdu) {
      translated = translated.replaceAll(
        RegExp(english, caseSensitive: false),
        urdu,
      );
    });

    return translated;
  }

  /// Translate description (basic translation for common agricultural terms)
  static String translateDescription(String description, BuildContext context) {
    final lang = _getCurrentLanguage(context);

    if (lang == 'en' || description.isEmpty) return description;

    // Common agricultural terms for description
    final terms = {
      'high quality': 'اعلیٰ معیار',
      'best quality': 'بہترین معیار',
      'available': 'دستیاب',
      'for sale': 'فروخت کے لیے',
      'contact': 'رابطہ',
      'price': 'قیمت',
      'per kg': 'فی کلو',
      'per bag': 'فی بوری',
      'wholesale': 'تھوک',
      'retail': 'خوردہ',
      'delivery': 'ترسیل',
      'original': 'اصل',
      'imported': 'درآمدی',
      'local': 'مقامی',
    };

    String translated = description;
    terms.forEach((english, urdu) {
      translated = translated.replaceAll(
        RegExp(english, caseSensitive: false),
        '$english ($urdu)',
      );
    });

    return translated;
  }

  /// Translate description using ML Kit (for dynamic, long-form content)
  /// This method uses automatic translation - FREE and works offline
  /// Falls back to static translation on web or if models unavailable
  static Future<String> translateDescriptionML(
    String description,
    BuildContext context,
  ) async {
    final lang = _getCurrentLanguage(context);

    // Return as-is if English or empty
    if (lang == 'en' || description.isEmpty) return description;

    // Use static translation on web or if models not ready
    if (kIsWeb || !_modelsDownloaded || _enToUrTranslator == null) {
      if (kIsWeb) {
        debugPrint('ℹ️ Using static translation (ML Kit not available on web)');
      }
      return translateDescription(description, context);
    }

    try {
      // Translate using ML Kit
      final translated = await _enToUrTranslator!.translateText(description);
      return translated;
    } catch (e) {
      debugPrint('❌ ML Kit translation error: $e');
      // Fallback to static translation
      return translateDescription(description, context);
    }
  }

  /// Translate any text using ML Kit (generic method)
  /// Falls back to returning original text on web or if models unavailable
  static Future<String> translateText(
    String text,
    BuildContext context, {
    bool forceEnglish = false,
  }) async {
    if (text.isEmpty) return text;

    final lang = _getCurrentLanguage(context);

    // If forcing English or already in English, return as-is
    if (forceEnglish || lang == 'en') return text;

    // Return as-is on web or if models not ready
    if (kIsWeb || !_modelsDownloaded || _enToUrTranslator == null) {
      if (kIsWeb) {
        debugPrint('ℹ️ ML Kit not available on web');
      }
      return text;
    }

    try {
      final translated = await _enToUrTranslator!.translateText(text);
      return translated;
    } catch (e) {
      debugPrint('❌ Translation error: $e');
      return text;
    }
  }

  /// Format price with currency in current language
  static String formatPrice(double price, BuildContext context) {
    final lang = _getCurrentLanguage(context);

    if (lang == 'ur') {
      return 'روپے ${price.toStringAsFixed(0)}';
    }
    return 'Rs. ${price.toStringAsFixed(0)}';
  }

  /// Check if current language is Urdu
  static bool isUrdu(BuildContext context) {
    return _getCurrentLanguage(context) == 'ur';
  }

  /// Check if current language is English
  static bool isEnglish(BuildContext context) {
    return _getCurrentLanguage(context) == 'en';
  }
}
