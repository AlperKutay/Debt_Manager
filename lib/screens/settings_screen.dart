import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/restart_widget.dart';  // Import from utils

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _initialDayController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Load settings when the screen opens
    Future.microtask(() {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      settingsProvider.loadSettings().then((_) {
        _initialDayController.text = settingsProvider.settings.initialDay.toString();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Initial Day Setting
              Text(
                AppLocalizations.of(context).startingDayOfInterval,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).setDefaultDayDescription,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _initialDayController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).initialDay,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final day = int.tryParse(value);
                  if (day != null && day >= 1 && day <= 31) {
                    provider.updateInitialDay(day);
                  }
                },
                validator: (value) {
                  final day = int.tryParse(value ?? '');
                  if (day == null) {
                    return AppLocalizations.of(context).pleaseEnterNumber;
                  }
                  if (day < 1 || day > 31) {
                    return AppLocalizations.of(context).pleaseEnterValidNumber;
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              
              // Currency Setting
              Text(
                AppLocalizations.of(context).currency,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                value: provider.settings.currency,
                items: const [
                  DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                  DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),
                  DropdownMenuItem(value: 'JPY', child: Text('JPY (¥)')),
                  DropdownMenuItem(value: 'TRY', child: Text('TRY (₺)')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    provider.updateCurrency(value);
                  }
                },
              ),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              
              // Theme Setting
              Text(
                AppLocalizations.of(context).themeMode,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.brightness_6),
                ),
                value: provider.settings.themeMode,
                items: [
                  DropdownMenuItem(
                    value: 'system',
                    child: Text(AppLocalizations.of(context).systemTheme),
                  ),
                  DropdownMenuItem(
                    value: 'light',
                    child: Text(AppLocalizations.of(context).lightTheme),
                  ),
                  DropdownMenuItem(
                    value: 'dark',
                    child: Text(AppLocalizations.of(context).darkTheme),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    provider.updateThemeMode(value);
                  }
                },
              ),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              
              // Language Setting
              Text(
                AppLocalizations.of(context).language,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_getLanguageName(context)),
                leading: const Icon(Icons.language),
                trailing: const Icon(Icons.arrow_forward_ios),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () => _showLanguageDialog(context),
              ),
              
              // Debug buttons
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: () {
                  final locale = Localizations.localeOf(context);
                  final appLocale = AppLocalizations.of(context);
                  
                  // Create a list of all translation keys and their values
                  final translations = {
                    'appTitle': appLocale.appTitle,
                    'home': appLocale.home,
                    'language': appLocale.language,
                    'transactions': appLocale.transactions,
                    'income': appLocale.income,
                    'expense': appLocale.expense,
                    // Add more keys as needed
                  };
                  
                  // Show a dialog with all translations
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Translations for ${locale.languageCode}'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: translations.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text('${entry.key}: ${entry.value}'),
                              );
                            }).toList(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(appLocale.close),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Debug All Translations'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _forceLocaleChange('en'),
                    child: Text('Force English'),
                  ),
                  ElevatedButton(
                    onPressed: () => _forceLocaleChange('tr'),
                    child: Text('Force Turkish'),
                  ),
                ],
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
        duration: Duration(seconds: 5),
      ),
    );
  }
} 