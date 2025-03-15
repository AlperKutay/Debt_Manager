import 'package:flutter/foundation.dart';
import '../data/database_helper.dart';
import '../models/transaction.dart' as app_model;

class TransactionProvider with ChangeNotifier {
  List<app_model.Transaction> _transactions = [];
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
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(app_model.Transaction transaction) async {
    try {
      final id = await DatabaseHelper.instance.insertTransaction(transaction);
      final newTransaction = transaction.copy(id: id);
      _transactions.add(newTransaction);
      
      // If recurring, schedule for next month
      if (transaction.isRecurring) {
        _scheduleRecurringTransaction(newTransaction);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
    }
  }

  Future<void> updateTransaction(app_model.Transaction transaction) async {
    try {
      await DatabaseHelper.instance.updateTransaction(transaction);
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await DatabaseHelper.instance.deleteTransaction(id);
      _transactions.removeWhere((transaction) => transaction.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }

  Future<List<app_model.Transaction>> getUpcomingTransactions() async {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, now.day);
    return await DatabaseHelper.instance.getUpcomingTransactions(now, nextMonth);
  }

  void _scheduleRecurringTransaction(app_model.Transaction transaction) {
    // This is a placeholder for scheduling recurring transactions
    // In a real app, you would use a background service or WorkManager
    // For now, we'll just log it
    final nextMonth = DateTime(
      transaction.date.year,
      transaction.date.month + 1,
      transaction.date.day,
    );
    debugPrint('Scheduled recurring transaction for: $nextMonth');
  }
} 