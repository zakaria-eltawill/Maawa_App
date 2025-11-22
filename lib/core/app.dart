import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/providers/language_provider.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/l10n/app_localizations.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider).router;
    final locale = ref.watch(languageProvider);

    // Debug: Print locale and font info
    if (kDebugMode) {
      debugPrint('🌐 App locale: ${locale.languageCode}');
      final fontFamily = locale.languageCode == 'ar' 
          ? GoogleFonts.cairo().fontFamily 
          : GoogleFonts.inter().fontFamily;
      debugPrint('🔤 Font family: $fontFamily');
    }

    return MaterialApp.router(
      title: 'مأوى',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(locale),
      routerConfig: router,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'), // Arabic
        Locale('en'), // English
      ],
    );
  }
}

