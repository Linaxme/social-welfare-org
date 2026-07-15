import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/data/app_session.dart';

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
      listenable: AppSession.instance,
      builder: (context, _) {
        if (!AppSession.instance.isReady) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return MaterialApp.router(
          title: 'সোমিতি',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
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
