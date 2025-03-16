import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/category_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'utils/notification_service.dart';
import 'data/database_helper.dart';
import 'l10n/app_localizations.dart';
import 'utils/restart_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database first
  await DatabaseHelper.instance.initialize();
  
  await NotificationService().initNotification();
  
  runApp(
    RestartWidget(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        // Load settings if not already loaded
        if (settingsProvider.settings.id == null) {
          Future.microtask(() => settingsProvider.loadSettings());
        }
        
        // Get the current locale
        final String currentLocale = settingsProvider.settings.locale;
        print("Building MaterialApp with locale: $currentLocale");
        
        // Create a new locale object each time to force rebuild
        final appLocale = Locale(currentLocale);
        print("Created Locale object: $appLocale");
        
        return MaterialApp(
          title: 'Borç Yöneticisi',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          themeMode: _getThemeMode(settingsProvider.settings.themeMode),
          home: const HomeScreen(),
          
          // Add localization support
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('tr', ''), // Turkish
          ],
          locale: appLocale,
        );
      },
    );
  }
  
  ThemeMode _getThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
