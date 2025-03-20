import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/category_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'utils/notification_service.dart';
import 'data/database_helper.dart';
import 'providers/language_provider.dart';
import 'utils/restart_widget.dart';
import 'l10n/app_localizations.dart';
import 'utils/app_strings.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize the database
    await DatabaseHelper.instance.initialize();
    
    // Comment out the notification initialization since the service is missing
    // await NotificationService().initNotification();
    
    // Create providers first
    final transactionProvider = TransactionProvider();
    
    runApp(
      RestartWidget(
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: transactionProvider),
            ChangeNotifierProvider(create: (_) => CategoryProvider()),
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ],
          child: Builder(
            builder: (context) {
              // Set context after the provider is available in the widget tree
              transactionProvider.setContext(context);
              return const MyApp();
            },
          ),
        ),
      ),
    );
  } catch (e) {
    // Handle initialization errors
    print('Error initializing app: $e');
    // Run a minimal error app
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error initializing app: $e'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    // Load settings if not already loaded
    if (settingsProvider.settings.id == null) {
      // Use Future.microtask to avoid calling setState during build
      Future.microtask(() => settingsProvider.loadSettings());
    }
    
    // Get the theme mode from settings
    ThemeMode themeMode = ThemeMode.system;
    switch (settingsProvider.settings.themeMode) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }
    
    return MaterialApp(
      title: AppStrings.get('Debt Manager', language: languageProvider.currentLanguage),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeMode,
      home: const HomeScreen(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('tr', ''),
      ],
      locale: Locale(languageProvider.currentLanguage, ''),
    );
  }
}
