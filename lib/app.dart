import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/data/app_session.dart';
import 'shared/data/locale_provider.dart';
import 'shared/data/theme_provider.dart';

class SomitiApp extends ConsumerStatefulWidget {
  const SomitiApp({super.key});

  @override
  ConsumerState<SomitiApp> createState() => _SomitiAppState();
}

class _SomitiAppState extends ConsumerState<SomitiApp> {
  late final _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        AppSession.instance,
        ThemeProvider.instance,
        LocaleProvider.instance,
      ]),
      builder: (context, _) {
        final strings = AppStrings.current;
        if (!AppSession.instance.isReady) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeProvider.instance.themeMode,
            locale: LocaleProvider.instance.locale,
            home: Scaffold(
              backgroundColor: const Color(0xFFFFFFFF),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D7A56).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.diversity_3_rounded,
                          size: 56,
                          color: Color(0xFF006644),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        strings.appNameBn,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF006644),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFF006644),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return MaterialApp.router(
          key: ValueKey(LocaleProvider.instance.localeCode),
          title: 'Hilful Fuzul',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeProvider.instance.themeMode,
          locale: LocaleProvider.instance.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('bn'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: _router,
          scrollBehavior: const AppScrollBehavior(),
        );
      },
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
