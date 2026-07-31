import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static final LocaleProvider instance = LocaleProvider._();
  LocaleProvider._();

  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isBn => _locale.languageCode == 'bn';
  bool get isEn => _locale.languageCode == 'en';

  String get localeCode => _locale.languageCode;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale') ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }

  Future<void> toggleLocale() async {
    final newLocale = isBn ? const Locale('en') : const Locale('bn');
    await setLocale(newLocale);
  }
}
