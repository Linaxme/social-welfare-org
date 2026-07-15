import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/data/app_session.dart';
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
      listenable: Listenable.merge([AppSession.instance, ThemeProvider.instance]),
      builder: (context, _) {
        if (!AppSession.instance.isReady) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeProvider.instance.themeMode,
            home: const Scaffold(
              backgroundColor: Color(0xFFFFFFFF),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.diversity_3_rounded,
                      size: 64,
                      color: Color(0xFF006644),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'সোমিতি',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF006644),
                      ),
                    ),
                    SizedBox(height: 24),
                    CircularProgressIndicator(
                      color: Color(0xFF006644),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return MaterialApp.router(
          title: 'Hilful Fuzul',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeProvider.instance.themeMode,
          locale: const Locale('bn'),
          supportedLocales: const [
            Locale('bn'),
            Locale('en'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: _router,
        );
      },
    );
  }
}
