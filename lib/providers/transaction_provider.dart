import 'package:flutter/foundation.dart';
import '../data/database_helper.dart';
import '../models/transaction.dart' as app_model;
import 'settings_provider.dart';
import '../models/category.dart' as app_model_category;

class TransactionProvider with ChangeNotifier {
  List<app_model.Transaction> _transactions = [];
  List<app_model_category.Category> _categories = [];
  bool _isLoading = false;

  List<app_model.Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  double get totalIncome {
    return _transactions
        .where((transaction) => transaction.type == 'income')
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double get totalExpense {
    return _transactions
        .where((transaction) => transaction.type == 'expense')
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double get balance => totalIncome - totalExpense;

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await DatabaseHelper.instance.getTransactions();
      _categories = await DatabaseHelper.instance.getCategories();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(app_model.Transaction transaction, {SettingsProvider? settingsProvider}) async {
    try {
      final id = await DatabaseHelper.instance.insertTransaction(transaction);
      
      // If it's a recurring transaction, create future transactions
      if (transaction.isRecurring && settingsProvider != null) {
        await _createRecurringTransactions(transaction.copy(id: id), settingsProvider);
      }
      
      await loadTransactions();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
    }
  }

  Future<void> updateTransaction(app_model.Transaction transaction) async {
    try {
      await DatabaseHelper.instance.updateTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await DatabaseHelper.instance.deleteTransaction(id);
      await loadTransactions();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }

  List<app_model.Transaction> getUpcomingTransactions() {
    final now = DateTime.now();
    
    return _transactions.where((t) {
      return t.date.isAfter(now);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<List<app_model.Transaction>> getUpcomingTransactionsAsync() async {
    return getUpcomingTransactions();
  }

  void _scheduleRecurringTransaction(app_model.Transaction transaction, SettingsProvider? settingsProvider) async {
    // Get the initial day setting if available
    final initialDay = settingsProvider?.settings.initialDay ?? 1;
    
    // If recurrenceCount is 0, it's indefinite
    // If it's greater than 0, we need to create that many recurring transactions
    if (transaction.recurrenceCount > 0) {
      // Create future transactions for the specified number of months
      for (int i = 1; i <= transaction.recurrenceCount; i++) {
        await _createFutureTransaction(transaction, initialDay, i);
      }
      
      // Reload transactions to show the newly created recurring transactions
      await loadTransactions();
    } else if (transaction.recurrenceCount == 0) {
      // For indefinite recurrence, we'll just log it for now
      // In a real app, you might want to use a background service or scheduled tasks
      debugPrint('Transaction set to recur indefinitely');
    }
  }

  Future<void> _createFutureTransaction(app_model.Transaction transaction, int initialDay, int monthsAhead) async {
    try {
      // Calculate the future date
      DateTime futureDate;
      
      if (transaction.date.day == initialDay) {
        // If the transaction is already on the initial day, just add months
        futureDate = DateTime(
          transaction.date.year,
          transaction.date.month + monthsAhead,
          initialDay,
        );
      } else {
        // Otherwise, use the initial day for future months
        futureDate = DateTime(
          transaction.date.year,
          transaction.date.month + monthsAhead,
          initialDay,
        );
      }
      
      // Handle invalid dates (e.g., February 31st)
      if (futureDate.month > (transaction.date.month + monthsAhead) % 12) {
        // If the month overflowed, use the last day of the month
        futureDate = DateTime(
          transaction.date.year,
          transaction.date.month + monthsAhead,
          0, // Last day of the previous month
        );
      }
      
      // Create a new transaction with the future date
      final futureTransaction = transaction.copy(
        id: null, // New transaction will get a new ID
        date: futureDate,
        isRecurring: false, // Future transactions are not recurring themselves
        recurrenceCount: 0,
      );
      
      // Insert the future transaction
      await DatabaseHelper.instance.insertTransaction(futureTransaction);
      debugPrint('Created future transaction for: $futureDate');
    } catch (e) {
      debugPrint('Error creating future transaction: $e');
    }
  }

  Future<List<app_model.Transaction>> getTransactionsForPeriod(DateTime startDate, DateTime endDate) async {
    try {
      return await DatabaseHelper.instance.getTransactionsForPeriod(startDate, endDate);
    } catch (e) {
      debugPrint('Error getting transactions for period: $e');
      return [];
    }
  }

  Future<double> getIncomeForPeriod(DateTime startDate, DateTime endDate) async {
    final transactions = await getTransactionsForPeriod(startDate, endDate);
    double total = 0.0;
    for (var transaction in transactions) {
      if (transaction.type == 'income') {
        total += transaction.amount;
      }
    }
    return total;
  }

  Future<double> getExpenseForPeriod(DateTime startDate, DateTime endDate) async {
    final transactions = await getTransactionsForPeriod(startDate, endDate);
    double total = 0.0;
    for (var transaction in transactions) {
      if (transaction.type == 'expense') {
        total += transaction.amount;
      }
    }
    return total;
  }

  Future<double> getBalanceForPeriod(DateTime startDate, DateTime endDate) async {
    final income = await getIncomeForPeriod(startDate, endDate);
    final expense = await getExpenseForPeriod(startDate, endDate);
    return income - expense;
  }

  Map<String, DateTime> getCurrentPeriodDates(int initialDay) {
    final now = DateTime.now();
    DateTime currentMonthStart;
    DateTime nextMonthStart;
    
    // If today is before the initial day of this month, the period starts from last month's initial day
    if (now.day < initialDay) {
      currentMonthStart = DateTime(now.year, now.month - 1, initialDay);
      nextMonthStart = DateTime(now.year, now.month, initialDay);
    } else {
      // Otherwise, the period starts from this month's initial day
      currentMonthStart = DateTime(now.year, now.month, initialDay);
      nextMonthStart = DateTime(now.year, now.month + 1, initialDay);
    }
    
    return {
      'start': currentMonthStart,
      'end': nextMonthStart,
    };
  }

  Future<void> _createRecurringTransactions(app_model.Transaction transaction, SettingsProvider settingsProvider) async {
    final recurrenceCount = transaction.recurrenceCount;
    final initialDay = settingsProvider.settings.initialDay;
    
    // If recurrenceCount is 0, it means indefinite, so we'll create 12 months of transactions
    final count = recurrenceCount == 0 ? 12 : recurrenceCount;
    
    for (int i = 1; i <= count; i++) {
      final nextDate = DateTime(
        transaction.date.year,
        transaction.date.month + i,
        initialDay,
      );
      
      final recurringTransaction = transaction.copy(
        id: null, // New transaction will get a new ID
        date: nextDate,
        isRecurring: false, // These are the generated transactions, not recurring themselves
        recurrenceCount: 0,
      );
      
      await DatabaseHelper.instance.insertTransaction(recurringTransaction);
    }
  }

  List<app_model.Transaction> getCurrentMonthTransactions() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return _transactions.where((t) {
      return t.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) && 
             t.date.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
  }

  double getTotalIncome() {
    final currentMonthTransactions = getCurrentMonthTransactions();
    return currentMonthTransactions
        .where((t) => t.type == 'income')
        .fold(0, (sum, t) => sum + t.amount);
  }

  double getTotalExpense() {
    final currentMonthTransactions = getCurrentMonthTransactions();
    return currentMonthTransactions
        .where((t) => t.type == 'expense')
        .fold(0, (sum, t) => sum + t.amount);
  }

  String getCategoryName(int categoryId) {
    try {
      final category = _categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => app_model_category.Category(name: 'Unknown', type: 'expense', icon: '0xe25c'),
      );
      return category.name;
    } catch (e) {
      debugPrint('Error getting category name: $e');
      return 'Unknown';
    }
  }
} 