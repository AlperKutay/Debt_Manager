import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/restart_widget.dart';  // Import from utils
import '../utils/app_strings.dart';
import '../providers/language_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _initialDayController = TextEditingController();
  String _selectedLanguage = 'English';
  
  @override
  void initState() {
    super.initState();
    
    // Load settings when the screen opens
    Future.microtask(() {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      settingsProvider.loadSettings().then((_) {
        _initialDayController.text = settingsProvider.settings.initialDay.toString();
      });
      
      // Set the selected language based on the current language
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      setState(() {
        _selectedLanguage = languageProvider.currentLanguage == 'en' ? 'English' : 'Turkish';
      });
    });
  }
  
  @override
  void dispose() {
    _initialDayController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context).currentLanguage;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('settings', language: language)),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (settingsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final settings = settingsProvider.settings;
          final language = Provider.of<LanguageProvider>(context).currentLanguage;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Initial Day Setting
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get('startingDay', language: language),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.get('startingDayHelp', language: language),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: settings.initialDay,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        items: List.generate(28, (index) {
                          final day = index + 1;
                          return DropdownMenuItem<int>(
                            value: day,
                            child: Text(AppStrings.get('Day $day', language: language)),
                          );
                        }),
                        onChanged: (value) {
                          if (value != null) {
                            settingsProvider.updateInitialDay(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Currency Setting
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get('currency', language: language),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: settings.currency,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: 'USD',
                            child: Text('US Dollar (\$)'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'EUR',
                            child: Text('Euro (€)'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'GBP',
                            child: Text('British Pound (£)'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'JPY',
                            child: Text('Japanese Yen (¥)'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'TRY',
                            child: Text('Turkish Lira (₺)'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            settingsProvider.updateCurrency(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Language Setting
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get('language', language: language),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedLanguage,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: 'English',
                            child: Text(AppStrings.get('English', language: language)),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Turkish',
                            child: Text(AppStrings.get('Turkish', language: language)),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedLanguage = value;
                            });
                            
                            // Update the language provider
                            final languageCode = value == 'English' ? 'en' : 'tr';
                            Provider.of<LanguageProvider>(context, listen: false).setLanguage(languageCode, context);
                            
                            // Show a message that language change requires app restart
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.get('languageChangeMessage', 
                                  language: languageCode)),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Theme Setting
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get('theme', language: language),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: settings.themeMode,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: 'system',
                            child: Text(AppStrings.get('systemDefault', language: language)),
                          ),
                          DropdownMenuItem<String>(
                            value: 'light',
                            child: Text(AppStrings.get('light', language: language)),
                          ),
                          DropdownMenuItem<String>(
                            value: 'dark',
                            child: Text(AppStrings.get('dark', language: language)),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            settingsProvider.updateThemeMode(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getLanguageName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
      default:
        return 'English';
    }
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () async {
                  // Update locale
                  final provider = Provider.of<SettingsProvider>(context, listen: false);
                  await provider.updateLocale('en');
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    
                    // Force rebuild of the entire app
                    RestartWidget.restartApp(context);
                    
                    // Show confirmation and suggest manual restart
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Language changed to English. Please restart the app for changes to take effect.'),
                        duration: Duration(seconds: 5),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                title: const Text('Türkçe'),
                onTap: () async {
                  // Update locale
                  final provider = Provider.of<SettingsProvider>(context, listen: false);
                  await provider.updateLocale('tr');
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    
                    // Force rebuild of the entire app
                    RestartWidget.restartApp(context);
                    
                    // Show confirmation and suggest manual restart
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Dil Türkçe olarak değiştirildi. Değişikliklerin etkili olması için lütfen uygulamayı yeniden başlatın.'),
                        duration: Duration(seconds: 5),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _forceLocaleChange(String localeCode) {
    // This is a more direct approach to changing the locale
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    
    // Update the locale in the provider
    provider.updateLocale(localeCode);
    
    // Force rebuild of the entire app
    RestartWidget.restartApp(context);
    
    // Show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Locale changed to $localeCode. Please check if translations are working.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
} 