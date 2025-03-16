import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class LocalizedText extends StatelessWidget {
  final String textKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const LocalizedText(
    this.textKey, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the localized text using the key
    final localizedText = _getLocalizedText(context, textKey);
    
    return Text(
      localizedText,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  String _getLocalizedText(BuildContext context, String key) {
    final appLocalizations = AppLocalizations.of(context);
    
    // Use reflection to get the property value
    switch (key) {
      case 'home': return appLocalizations.home;
      case 'transactions': return appLocalizations.transactions;
      case 'income': return appLocalizations.income;
      case 'expense': return appLocalizations.expense;
      case 'balance': return appLocalizations.balance;
      case 'addTransaction': return appLocalizations.addTransaction;
      case 'categories': return appLocalizations.categories;
      case 'settings': return appLocalizations.settings;
      // Add more cases for all your translation keys
      default: return key; // Return the key itself if not found
    }
  }
} 