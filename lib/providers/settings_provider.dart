import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/settings.dart' as app_model;

class SettingsProvider with ChangeNotifier {
  app_model.Settings? _settings;
  bool _isLoading = false;

  app_model.Settings get settings => _settings ?? app_model.Settings();
  bool get isLoading => _isLoading;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await DatabaseHelper.instance.getSettings();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings(app_model.Settings settings) async {
    try {
      await DatabaseHelper.instance.updateSettings(settings);
      _settings = settings;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating settings: $e');
    }
  }

  Future<void> updateInitialDay(int day) async {
    if (_settings == null) await loadSettings();
    
    final updatedSettings = _settings!.copy(initialDay: day);
    await updateSettings(updatedSettings);
  }

  Future<void> updateCurrency(String currency) async {
    if (_settings == null) await loadSettings();
    
    final updatedSettings = _settings!.copy(currency: currency);
    await updateSettings(updatedSettings);
  }

  Future<void> updateThemeMode(String themeMode) async {
    if (_settings == null) await loadSettings();
    
    final updatedSettings = _settings!.copy(themeMode: themeMode);
    await updateSettings(updatedSettings);
  }
} 