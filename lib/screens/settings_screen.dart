import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

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
        title: const Text('Settings'),
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
              const Text(
                'Starting Day of Interval',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set the default day of the month for recurring transactions',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _initialDayController,
                decoration: const InputDecoration(
                  labelText: 'Day (1-31)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
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
                    return 'Please enter a valid number';
                  }
                  if (day < 1 || day > 31) {
                    return 'Day must be between 1 and 31';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              
              // Currency Setting
              const Text(
                'Currency',
                style: TextStyle(
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
              const Text(
                'Theme',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.palette),
                ),
                value: provider.settings.themeMode,
                items: const [
                  DropdownMenuItem(value: 'system', child: Text('System Default')),
                  DropdownMenuItem(value: 'light', child: Text('Light')),
                  DropdownMenuItem(value: 'dark', child: Text('Dark')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    provider.updateThemeMode(value);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
} 