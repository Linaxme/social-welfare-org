import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'shared/data/app_session.dart';
import 'shared/data/locale_provider.dart';
import 'shared/services/pdf_font_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preload PDF fonts in background for instant receipt generation
  PdfFontHelper.preload();

  // Init locale (non-blocking if it fails)
  try {
    await LocaleProvider.instance.init();
  } catch (e) {
    debugPrint('Locale init error: $e');
  }

  // Init Firebase + session
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // Always start session so isReady becomes true
  await AppSession.instance.start();

  runApp(
    const ProviderScope(
      child: SomitiApp(),
    ),
  );
}
