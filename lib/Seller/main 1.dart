import 'package:flutter/material.dart';
import '../Seller/screens/sign_in_screen.dart';
import 'package:kissan/l10n/gen/app_localizations.dart';
import 'package:kissan/localization/locale_controller.dart';
import 'package:kissan/core/firebase/firebase_bootstrap.dart';
import 'package:kissan/core/services/translation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();
  await ensureSignedIn();
  await AppLocaleController.loadSavedLocale();

  // Initialize ML Kit Translation
  await TranslationService.initialize();

  // Download translation models in background
  TranslationService.downloadModels().then((success) {
    if (success) {
      debugPrint('✅ Translation models ready');
    } else {
      debugPrint(
        '⚠️ Translation models not downloaded - will use static translations',
      );
    }
  });

  runApp(const SellerStart());
}

class SellerStart extends StatelessWidget {
  const SellerStart({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: AppLocaleController.locale,
      builder: (context, locale, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(scaffoldBackgroundColor: Colors.white),
          // Force LTR layout to prevent UI shift when switching to Urdu
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: child!,
            );
          },
          home: const SignInScreen(),
        );
      },
    );
  }
}
