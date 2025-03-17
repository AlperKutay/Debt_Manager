class Settings {
  static const String tableName = 'settings';
  static const String colId = 'id';
  static const String colInitialDay = 'initial_day';
  static const String colCurrency = 'currency';
  static const String colThemeMode = 'theme_mode';

  final int? id;
  final int initialDay;
  final String currency;
  final String themeMode;

  Settings({
    this.id,
    this.initialDay = 1, // Default to 1st day of month
    this.currency = 'USD',
    this.themeMode = 'system',
  });

  Settings copy({
    int? id,
    int? initialDay,
    String? currency,
    String? themeMode,
  }) =>
      Settings(
        id: id ?? this.id,
        initialDay: initialDay ?? this.initialDay,
        currency: currency ?? this.currency,
        themeMode: themeMode ?? this.themeMode,
      );

  static Settings fromMap(Map<String, dynamic> map) => Settings(
        id: map[colId],
        initialDay: map[colInitialDay],
        currency: map[colCurrency],
        themeMode: map[colThemeMode],
      );

  Map<String, dynamic> toMap() => {
        colInitialDay: initialDay,
        colCurrency: currency,
        colThemeMode: themeMode,
      };
} 