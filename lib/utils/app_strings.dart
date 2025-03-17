class AppStrings {
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Navigation
      'dashboard': 'Dashboard',
      'transactions': 'Transactions',
      'categories': 'Categories',
      'upcoming': 'Upcoming',
      
      // Transaction types
      'income': 'Income',
      'expense': 'Expense',
      
      // Common actions
      'add': 'Add',
      'edit': 'Edit',
      'delete': 'Delete',
      'cancel': 'Cancel',
      'save': 'Save',
      'update': 'Update',
      'confirm': 'Confirm',
      
      // Transaction screen
      'addTransaction': 'Add Transaction',
      'updateTransaction': 'Update Transaction',
      'amount': 'Amount',
      'category': 'Category',
      'date': 'Date',
      'notes': 'Notes (Optional)',
      'recurringMonthly': 'Recurring Monthly',
      'recurrenceCount': 'Recurrence Count',
      'recurrenceHelp': 'How many months should this transaction recur? (0 for indefinite)',
      'selectCategory': 'Select a category',
      
      // Categories screen
      'addCategory': 'Add Category',
      'updateCategory': 'Update Category',
      'categoryName': 'Category Name',
      'categoryType': 'Category Type',
      'selectIcon': 'Select Icon',
      'noCategoriesFound': 'No categories found',
      
      // Settings screen
      'settings': 'Settings',
      'Starting Day of Each Interval': 'Starting Day of Each Interval',
      'Set the default day of the month for recurring transactions': 'Set the default day of the month for recurring transactions',
      'currency': 'Currency',
      'language': 'Language',
      'theme': 'Theme',
      'systemDefault': 'System Default',
      'light': 'Light',
      'dark': 'Dark',
      'languageChangeMessage': 'Language change will take effect after restarting the app',
      
      // Confirmation dialogs
      'confirmDelete': 'Confirm Delete',
      'deleteTransactionConfirm': 'Are you sure you want to delete this transaction?',
      'deleteCategoryConfirm': 'Are you sure you want to delete this category? This will not delete associated transactions.',
      
      // New additions
      'English': 'English',
      'Turkish': 'Turkish (Türkçe)',
      'unknownCategory': 'Unknown Category',
      'noTransactionsFound': 'No transactions found',
    },
    'tr': {
      // Navigation
      'dashboard': 'Gösterge Paneli',
      'transactions': 'İşlemler',
      'categories': 'Kategoriler',
      'upcoming': 'Yaklaşan',
      
      // Transaction types
      'income': 'Gelir',
      'expense': 'Gider',
      
      // Common actions
      'add': 'Ekle',
      'edit': 'Düzenle',
      'delete': 'Sil',
      'cancel': 'İptal',
      'save': 'Kaydet',
      'update': 'Güncelle',
      'confirm': 'Onayla',
      
      // Transaction screen
      'addTransaction': 'İşlem Ekle',
      'updateTransaction': 'İşlemi Güncelle',
      'amount': 'Tutar',
      'category': 'Kategori',
      'date': 'Tarih',
      'notes': 'Notlar (İsteğe bağlı)',
      'recurringMonthly': 'Aylık Tekrarlanan',
      'recurrenceCount': 'Tekrarlama Sayısı',
      'recurrenceHelp': 'Bu işlem kaç ay tekrarlanmalı? (Süresiz için 0)',
      'selectCategory': 'Bir kategori seçin',
      
      // Categories screen
      'addCategory': 'Kategori Ekle',
      'updateCategory': 'Kategoriyi Güncelle',
      'categoryName': 'Kategori Adı',
      'categoryType': 'Kategori Türü',
      'selectIcon': 'Simge Seç',
      'noCategoriesFound': 'Kategori bulunamadı',
      
      // Settings screen
      'settings': 'Ayarlar',
      'startingDay': 'Aralık Başlangıç Günü',
      'startingDayHelp': 'Tekrarlanan işlemler için ayın varsayılan gününü ayarlayın',
      'currency': 'Para Birimi',
      'language': 'Dil',
      'theme': 'Tema',
      'systemDefault': 'Sistem Varsayılanı',
      'light': 'Açık',
      'dark': 'Koyu',
      'languageChangeMessage': 'Dil değişikliği uygulama yeniden başlatıldıktan sonra geçerli olacaktır',
      
      // Confirmation dialogs
      'confirmDelete': 'Silmeyi Onayla',
      'deleteTransactionConfirm': 'Bu işlemi silmek istediğinizden emin misiniz?',
      'deleteCategoryConfirm': 'Bu kategoriyi silmek istediğinizden emin misiniz? Bu, ilişkili işlemleri silmeyecektir.',
      
      // New additions
      'English': 'İngilizce',
      'Turkish': 'Türkçe',
      'Debt Manager': 'Borç Yöneticisi',
      'Current Month': 'Mevcut Ay',
      'Upcoming Payments': 'Yaklaşan Ödemeler',
      'Starting Day of Each Interval': 'Her Aralığın Başlangıç Günü',
      'Day 1': 'Gün 1',
      'Day 2': 'Gün 2',
      'Day 3': 'Gün 3',
      'Day 4': 'Gün 4',
      'Day 5': 'Gün 5',
      'Day 6': 'Gün 6',
      'Day 7': 'Gün 7',
      'Day 8': 'Gün 8',
      'Day 9': 'Gün 9',
      'Day 10': 'Gün 10',
      'Day 11': 'Gün 11',
      'Day 12': 'Gün 12',
      'Day 13': 'Gün 13',
      'Day 14': 'Gün 14',
      'Day 15': 'Gün 15',
      'Day 16': 'Gün 16',
      'Day 17': 'Gün 17',
      'Day 18': 'Gün 18',
      'Day 19': 'Gün 19',
      'Day 20': 'Gün 20',
      'Day 21': 'Gün 21',
      'Day 22': 'Gün 22',
      'Day 23': 'Gün 23',
      'Day 24': 'Gün 24',
      'Day 25': 'Gün 25',
      'Day 26': 'Gün 26',
      'Day 27': 'Gün 27',
      'Day 28': 'Gün 28',
      'unknownCategory': 'Bilinmeyen Kategori',
      'noTransactionsFound': 'İşlem bulunamadı',
    },
  };

  static String get(String key, {String language = 'en'}) {
    if (_localizedValues.containsKey(language) && 
        _localizedValues[language]!.containsKey(key)) {
      return _localizedValues[language]![key]!;
    }
    
    // Fallback to English
    if (_localizedValues['en']!.containsKey(key)) {
      return _localizedValues['en']![key]!;
    }
    
    // If all else fails, return the key itself
    return key;
  }
} 