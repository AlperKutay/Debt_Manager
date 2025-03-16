import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Add your translations here
  String get appTitle => _getText('appTitle');
  String get home => _getText('home');
  String get language => _getText('language');
  String get transactions => _getText('transactions');
  String get income => _getText('income');
  String get expense => _getText('expense');
  String get balance => _getText('balance');
  String get addTransaction => _getText('addTransaction');
  String get categories => _getText('categories');
  String get settings => _getText('settings');
  String get amount => _getText('amount');
  String get date => _getText('date');
  String get category => _getText('category');
  String get description => _getText('description');
  String get save => _getText('save');
  String get cancel => _getText('cancel');
  String get delete => _getText('delete');
  String get edit => _getText('edit');
  String get currentMonth => _getText('currentMonth');
  String get upcomingPayments => _getText('upcomingPayments');
  String get noTransactions => _getText('noTransactions');
  String get totalIncome => _getText('totalIncome');
  String get totalExpense => _getText('totalExpense');
  String get netBalance => _getText('netBalance');
  String get selectCategory => _getText('selectCategory');
  String get addCategory => _getText('addCategory');
  String get categoryName => _getText('categoryName');
  String get categoryType => _getText('categoryType');
  String get categoryIcon => _getText('categoryIcon');
  String get themeMode => _getText('themeMode');
  String get lightTheme => _getText('lightTheme');
  String get darkTheme => _getText('darkTheme');
  String get systemTheme => _getText('systemTheme');
  String get currency => _getText('currency');
  String get initialDay => _getText('initialDay');
  String get recurrence => _getText('recurrence');
  String get daily => _getText('daily');
  String get weekly => _getText('weekly');
  String get monthly => _getText('monthly');
  String get yearly => _getText('yearly');
  String get notes => _getText('notes');
  String get confirmDelete => _getText('confirmDelete');
  String get deleteTransactionConfirm => _getText('deleteTransactionConfirm');
  String get yes => _getText('yes');
  String get no => _getText('no');
  String get transactionType => _getText('transactionType');
  String get startingDayOfInterval => _getText('startingDayOfInterval');
  String get setDefaultDayDescription => _getText('setDefaultDayDescription');
  String get close => _getText('close');
  String get pleaseSelectCategory => _getText('pleaseSelectCategory');
  String get recurringMonthly => _getText('recurringMonthly');
  String get recurrenceCount => _getText('recurrenceCount');
  String get recurrenceCountDescription => _getText('recurrenceCountDescription');
  String get pleaseEnterNumber => _getText('pleaseEnterNumber');
  String get pleaseEnterValidNumber => _getText('pleaseEnterValidNumber');
  String get pleaseEnterNonNegativeNumber => _getText('pleaseEnterNonNegativeNumber');
  String get updateTransaction => _getText('updateTransaction');
  String get viewAll => _getText('viewAll');

  String _getText(String key) {
    print("Getting text for key: $key with locale: ${locale.languageCode}");
    
    switch (locale.languageCode) {
      case 'tr':
        final value = _trValues[key];
        print("Turkish value for '$key': $value");
        return value ?? key;
      default:
        final value = _enValues[key];
        print("English value for '$key': $value");
        return value ?? key;
    }
  }

  // English translations
  static const Map<String, String> _enValues = {
    'appTitle': 'Debt Manager',
    'home': 'Home',
    'language': 'Language',
    'transactions': 'Transactions',
    'income': 'Income',
    'expense': 'Expense',
    'balance': 'Balance',
    'addTransaction': 'Add Transaction',
    'categories': 'Categories',
    'settings': 'Settings',
    'amount': 'Amount',
    'date': 'Date',
    'category': 'Category',
    'description': 'Description',
    'save': 'Save',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'edit': 'Edit',
    'currentMonth': 'Current Month',
    'upcomingPayments': 'Upcoming Payments',
    'noTransactions': 'No transactions found',
    'totalIncome': 'Total Income',
    'totalExpense': 'Total Expense',
    'netBalance': 'Net Balance',
    'selectCategory': 'Select Category',
    'addCategory': 'Add Category',
    'categoryName': 'Category Name',
    'categoryType': 'Category Type',
    'categoryIcon': 'Category Icon',
    'themeMode': 'Theme Mode',
    'lightTheme': 'Light',
    'darkTheme': 'Dark',
    'systemTheme': 'System',
    'currency': 'Currency',
    'initialDay': 'Month Start Day',
    'recurrence': 'Recurrence',
    'daily': 'Daily',
    'weekly': 'Weekly',
    'monthly': 'Monthly',
    'yearly': 'Yearly',
    'notes': 'Notes',
    'confirmDelete': 'Confirm Delete',
    'deleteTransactionConfirm': 'Are you sure you want to delete this transaction?',
    'yes': 'Yes',
    'no': 'No',
    'transactionType': 'Transaction Type',
    'startingDayOfInterval': 'Starting Day of Interval',
    'setDefaultDayDescription': 'Set the default day of the month for recurring transactions',
    'close': 'Close',
    'pleaseSelectCategory': 'Please select a category',
    'recurringMonthly': 'Recurring Monthly',
    'recurrenceCount': 'Recurrence Count',
    'recurrenceCountDescription': 'How many months should this transaction recur? (0 for indefinite)',
    'pleaseEnterNumber': 'Please enter a number',
    'pleaseEnterValidNumber': 'Please enter a valid number',
    'pleaseEnterNonNegativeNumber': 'Please enter a non-negative number',
    'updateTransaction': 'Update Transaction',
    'viewAll': 'View All',
  };

  // Turkish translations
  static const Map<String, String> _trValues = {
    'appTitle': 'Borç Yöneticisi',
    'home': 'Ana Sayfa',
    'language': 'Dil',
    'transactions': 'İşlemler',
    'income': 'Gelir',
    'expense': 'Gider',
    'balance': 'Bakiye',
    'addTransaction': 'İşlem Ekle',
    'categories': 'Kategoriler',
    'settings': 'Ayarlar',
    'amount': 'Tutar',
    'date': 'Tarih',
    'category': 'Kategori',
    'description': 'Açıklama',
    'save': 'Kaydet',
    'cancel': 'İptal',
    'delete': 'Sil',
    'edit': 'Düzenle',
    'currentMonth': 'Bu Ay',
    'upcomingPayments': 'Yaklaşan Ödemeler',
    'noTransactions': 'İşlem bulunamadı',
    'totalIncome': 'Toplam Gelir',
    'totalExpense': 'Toplam Gider',
    'netBalance': 'Net Bakiye',
    'selectCategory': 'Kategori Seç',
    'addCategory': 'Kategori Ekle',
    'categoryName': 'Kategori Adı',
    'categoryType': 'Kategori Türü',
    'categoryIcon': 'Kategori İkonu',
    'themeMode': 'Tema Modu',
    'lightTheme': 'Açık',
    'darkTheme': 'Koyu',
    'systemTheme': 'Sistem',
    'currency': 'Para Birimi',
    'initialDay': 'Ay Başlangıç Günü',
    'recurrence': 'Tekrarlama',
    'daily': 'Günlük',
    'weekly': 'Haftalık',
    'monthly': 'Aylık',
    'yearly': 'Yıllık',
    'notes': 'Notlar',
    'confirmDelete': 'Silmeyi Onayla',
    'deleteTransactionConfirm': 'Bu işlemi silmek istediğinizden emin misiniz?',
    'yes': 'Evet',
    'no': 'Hayır',
    'transactionType': 'İşlem Türü',
    'startingDayOfInterval': 'Aralık Başlangıç Günü',
    'setDefaultDayDescription': 'Tekrarlanan işlemler için ayın varsayılan gününü ayarlayın',
    'close': 'Kapat',
    'pleaseSelectCategory': 'Lütfen bir kategori seçin',
    'recurringMonthly': 'Aylık Tekrarlama',
    'recurrenceCount': 'Tekrarlama Sayısı',
    'recurrenceCountDescription': 'Bu işlem kaç ay tekrarlanmalı? (Süresiz için 0)',
    'pleaseEnterNumber': 'Lütfen bir sayı girin',
    'pleaseEnterValidNumber': 'Lütfen geçerli bir sayı girin',
    'pleaseEnterNonNegativeNumber': 'Lütfen negatif olmayan bir sayı girin',
    'updateTransaction': 'İşlemi Güncelle',
    'viewAll': 'Tümünü Görüntüle',
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    print("Checking if locale is supported: ${locale.languageCode}");
    return ['en', 'tr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    print("Loading AppLocalizations for locale: ${locale.languageCode}");
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
} 