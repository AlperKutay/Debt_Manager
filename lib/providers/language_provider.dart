import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/file_storage.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'en';
  
  String get currentLanguage => _currentLanguage;
  
  LanguageProvider() {
    _loadSavedLanguage();
  }
  
  Future<void> _loadSavedLanguage() async {
    final savedLanguage = await FileStorage.readFromFile('language');
    if (savedLanguage != null && (savedLanguage == 'en' || savedLanguage == 'tr')) {
      _currentLanguage = savedLanguage;
      notifyListeners();
    }
  }
  
  Future<void> setLanguage(String languageCode, BuildContext context) async {
    if (languageCode == 'en' || languageCode == 'tr') {
      _currentLanguage = languageCode;
      await FileStorage.writeToFile('language', languageCode);
      notifyListeners();
      
      // Refresh transaction provider to update category names
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      transactionProvider.refreshCategoryNames();
    }
  }
} 