import 'package:flutter/material.dart';
import 'package:kissan/l10n/gen/app_localizations.dart';
import 'package:kissan/screens/splash_screen.dart';
import 'package:kissan/localization/locale_controller.dart';
import 'package:kissan/core/firebase/firebase_bootstrap.dart';
import 'package:kissan/core/services/translation_service.dart';
import 'package:kissan/core/services/tts_service.dart';
import 'package:kissan/core/services/notification_service.dart';
//import './Buyers Screens./main_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();
  await ensureSignedIn();
  await AppLocaleController.loadSavedLocale();

  // Initialize ML Kit Translation
  await TranslationService.initialize();

  // Initialize TTS Service
  final currentLocale = AppLocaleController.locale.value;
  await TtsService.instance.initialize(
    language: currentLocale?.languageCode ?? 'en',
  );

  // Initialize Notification Service
  await NotificationService.instance.initialize();

  // Download translation models in background (won't block app start)
  TranslationService.downloadModels().then((success) {
    if (success) {
      debugPrint('✅ Translation models ready');
    } else {
      debugPrint(
        '⚠️ Translation models not downloaded - will use static translations',
      );
    }
  });

  runApp(const BuyerStart());
}

class BuyerStart extends StatelessWidget {
  const BuyerStart({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: AppLocaleController.locale,
      builder: (context, locale, _) {
        return MaterialApp(
          locale: locale,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          // Force LTR layout to prevent UI shift when switching to Urdu
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: child!,
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}

// Global app locale controller is provided in localization/locale_controller.dart
