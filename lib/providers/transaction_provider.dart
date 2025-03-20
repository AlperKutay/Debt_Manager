import 'package:flutter/foundation.dart';
import '../data/database_helper.dart';
import '../models/transaction.dart' as app_model;
import 'settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class TransactionProvider with ChangeNotifier {
  List<app_model.Transaction> _transactions = [];
  bool _isLoading = false;
  BuildContext? _context;

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
      final newTransaction = transaction.copy(id: id);
      _transactions.add(newTransaction);
      
      // If recurring, schedule for next month
      if (transaction.isRecurring) {
        _scheduleRecurringTransaction(newTransaction, settingsProvider);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
    }
  }

  Future<void> updateTransaction(app_model.Transaction transaction) async {
    try {
      // Get the original transaction before updating
      final originalTransaction = _transactions.firstWhere(
        (t) => t.id == transaction.id,
        orElse: () => transaction,
      );
      
      // Update the transaction in the database
      await DatabaseHelper.instance.updateTransaction(transaction);
      
      // Find and update the transaction in our local list
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
      }
      
      // Handle changes in recurring settings
      if (transaction.isRecurring) {
        // If recurrence count increased or it's newly set to recurring
        if (!originalTransaction.isRecurring || 
            transaction.recurrenceCount > originalTransaction.recurrenceCount) {
          
          // Delete any existing future recurring instances
          await _deleteFutureRecurringInstances(transaction.id!);
          
          // Create new recurring instances based on updated settings
          if (_context != null) {
            final settingsProvider = Provider.of<SettingsProvider>(_context!, listen: false);
            _scheduleRecurringTransaction(transaction, settingsProvider);
          }
        }
      } else if (originalTransaction.isRecurring && !transaction.isRecurring) {
        // If transaction was recurring but is no longer recurring
        await _deleteFutureRecurringInstances(transaction.id!);
      }
      
      // Reload all transactions to ensure everything is in sync
      await loadTransactions();
      
      // Explicitly notify listeners to ensure all widgets update
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await DatabaseHelper.instance.deleteTransaction(id);
      _transactions.removeWhere((transaction) => transaction.id == id);
      
      // Reload all transactions to ensure everything is in sync
      await loadTransactions();
      
      // Explicitly notify listeners to ensure all widgets update
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }

  Future<List<app_model.Transaction>> getUpcomingTransactions() async {
    try {
      final now = DateTime.now();
      final threeMonthsLater = DateTime(now.year, now.month + 3, now.day);
      return await DatabaseHelper.instance.getUpcomingTransactions(now, threeMonthsLater);
    } catch (e) {
      debugPrint('Error getting upcoming transactions: $e');
      return [];
    }
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
      
      // Use the same day of month as the original transaction
      futureDate = DateTime(
        transaction.date.year,
        transaction.date.month + monthsAhead,
        transaction.date.day,
      );
      
      // Handle invalid dates (e.g., February 31st)
      if (futureDate.month > (transaction.date.month + monthsAhead) % 12) {
        // If the month overflowed, use the last day of the month
        futureDate = DateTime(
          transaction.date.year,
          transaction.date.month + monthsAhead + 1,
          0, // Last day of the previous month
        );
      }
      
      // Create a new transaction with the future date
      final futureTransaction = transaction.copy(
        id: null, // New transaction will get a new ID
        date: futureDate,
        isRecurring: false, // Future transactions are not recurring themselves
        recurrenceCount: 0,
        // Add a reference to the original transaction in the notes
        notes: transaction.notes + (transaction.notes.isEmpty ? '' : ' ') + 
               'Recurring from ID: ${transaction.id}',
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

  // Add these methods to calculate balance for a specific period
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

  // Helper method to get the current period dates based on initial day
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

  void refreshCategoryNames() {
    notifyListeners();
  }

  // Add this method to delete future recurring instances
  Future<void> _deleteFutureRecurringInstances(int originalTransactionId) async {
    try {
      // Get all transactions that were created as recurring instances
      final now = DateTime.now();
      final futureTransactions = _transactions.where((t) => 
        t.notes.contains('Recurring from ID: $originalTransactionId') && 
        t.date.isAfter(now)
      ).toList();
      
      // Delete each future recurring instance
      for (final transaction in futureTransactions) {
        if (transaction.id != null) {
          await DatabaseHelper.instance.deleteTransaction(transaction.id!);
        }
      }
      
      debugPrint('Deleted future recurring instances for transaction ID: $originalTransactionId');
    } catch (e) {
      debugPrint('Error deleting future recurring instances: $e');
    }
  }

  // Add this method to set the context
  void setContext(BuildContext context) {
    _context = context;
  }
} 