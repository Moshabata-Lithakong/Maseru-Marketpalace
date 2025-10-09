import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  final SharedPreferences prefs;
  
  Locale _currentLocale = const Locale('en', 'US');
  static const String _languageKey = 'language';

  LanguageProvider(this.prefs) {
    _loadLanguage();
  }

  Locale get currentLocale => _currentLocale;
  String get currentLanguage => _currentLocale.languageCode;

  void _loadLanguage() {
    final savedLanguage = prefs.getString(_languageKey);
    if (savedLanguage != null) {
      _currentLocale = Locale(savedLanguage);
    }
    notifyListeners();
  }

  void setLanguage(String languageCode) {
    _currentLocale = Locale(languageCode);
    prefs.setString(_languageKey, languageCode);
    notifyListeners();
  }

  void toggleLanguage() {
    _currentLocale = _currentLocale.languageCode == 'en' 
        ? const Locale('st') 
        : const Locale('en');
    prefs.setString(_languageKey, _currentLocale.languageCode);
    notifyListeners();
  }
}