import 'package:flutter/material.dart';

class Settings {
  static const String tableName = 'settings';
  static const String colId = 'id';
  static const String colInitialDay = 'initial_day';
  static const String colCurrency = 'currency';
  static const String colThemeMode = 'theme_mode';
  static const String colLocale = 'locale';

  final int? id;
  final int initialDay;
  final String currency;
  final String themeMode;
  final String locale;

  Settings({
    this.id,
    this.initialDay = 1, // Default to 1st day of month
    this.currency = 'USD',
    this.themeMode = 'system',
    this.locale = 'en',
  });

  Settings copy({
    int? id,
    int? initialDay,
    String? currency,
    String? themeMode,
    String? locale,
  }) =>
      Settings(
        id: id ?? this.id,
        initialDay: initialDay ?? this.initialDay,
        currency: currency ?? this.currency,
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
      );

  static Settings fromMap(Map<String, dynamic> map) => Settings(
        id: map[colId],
        initialDay: map[colInitialDay],
        currency: map[colCurrency],
        themeMode: map[colThemeMode],
        locale: map[colLocale] ?? 'en',
      );

  Map<String, dynamic> toMap() => {
        colId: id,
        colInitialDay: initialDay,
        colCurrency: currency,
        colThemeMode: themeMode,
        colLocale: locale,
      };
} 