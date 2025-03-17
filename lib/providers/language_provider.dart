import 'package:flutter/foundation.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'en';
  
  String get currentLanguage => _currentLanguage;
  
  void setLanguage(String languageCode) {
    if (languageCode == 'en' || languageCode == 'tr') {
      _currentLanguage = languageCode;
      notifyListeners();
    }
  }
} 