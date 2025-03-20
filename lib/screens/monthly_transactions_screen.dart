import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../models/transaction.dart' as app_model;
import '../utils/app_strings.dart';
import '../providers/language_provider.dart';
import '../screens/add_transaction_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MonthlyTransactionsScreen extends StatefulWidget {
  final DateTime periodStart;
  final String monthName;

  const MonthlyTransactionsScreen({
    super.key,
    required this.periodStart,
    required this.monthName,
  });

  @override
  State<MonthlyTransactionsScreen> createState() => _MonthlyTransactionsScreenState();
}

class _MonthlyTransactionsScreenState extends State<MonthlyTransactionsScreen> {
  List<app_model.Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final initialDay = settingsProvider.settings.initialDay;
    
    // Calculate the period end date (next month's initial day)
    final periodEnd = DateTime(
      widget.periodStart.year,
      widget.periodStart.month + 1,
      initialDay,
    );
    
    // Get transactions for this period
    final transactions = await transactionProvider.getTransactionsForPeriod(
      widget.periodStart,
      periodEnd,
    );
    
    setState(() {
      _transactions = transactions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context).currentLanguage;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currencyFormat = _getCurrencyFormat(settingsProvider.settings.currency);
    
    // Calculate totals
    double totalIncome = 0;
    double totalExpense = 0;
    
    for (final transaction in _transactions) {
      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }
    
    final balance = totalIncome - totalExpense;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.monthName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary card
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(
                          AppStrings.get('income', language: language),
                          totalIncome,
                          Colors.green,
                          currencyFormat,
                        ),
                        _buildSummaryItem(
                          AppStrings.get('expense', language: language),
                          totalExpense,
                          Colors.red,
                          currencyFormat,
                        ),
                        _buildSummaryItem(
                          AppStrings.get('balance', language: language),
                          balance,
                          balance >= 0 ? Colors.green : Colors.red,
                          currencyFormat,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Transactions list
                Expanded(
                  child: _transactions.isEmpty
                      ? Center(
                          child: Text(AppStrings.get('noTransactionsFound', language: language)),
                        )
                      : Consumer<CategoryProvider>(
                          builder: (context, categoryProvider, _) {
                            return ListView.builder(
                              itemCount: _transactions.length,
                              itemBuilder: (context, index) {
                                final transaction = _transactions[index];
                                final category = categoryProvider.categories.firstWhere(
                                  (c) => c.id == transaction.categoryId,
                                  orElse: () => categoryProvider.categories.first,
                                );
                                
                                final isExpense = transaction.type == 'expense';
                                
                                return Slidable(
                                  endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddTransactionScreen(
                                                transaction: transaction,
                                              ),
                                            ),
                                          ).then((_) => _loadTransactions());
                                        },
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        icon: Icons.edit,
                                        label: AppStrings.get('edit', language: language),
                                      ),
                                      SlidableAction(
                                        onPressed: (context) {
                                          _showDeleteConfirmationDialog(context, transaction);
                                        },
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                        label: AppStrings.get('delete', language: language),
                                      ),
                                    ],
                                  ),
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: isExpense ? Colors.red.shade100 : Colors.green.shade100,
                                        child: Icon(
                                          isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                                          color: isExpense ? Colors.red : Colors.green,
                                        ),
                                      ),
                                      title: Text(category.name),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(DateFormat('MMM dd, yyyy').format(transaction.date)),
                                          if (transaction.notes.isNotEmpty)
                                            Text(
                                              transaction.notes,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                      trailing: Text(
                                        currencyFormat.format(transaction.amount),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isExpense ? Colors.red : Colors.green,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddTransactionScreen(
                                              transaction: transaction,
                                            ),
                                          ),
                                        ).then((_) => _loadTransactions());
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    double amount,
    Color color,
    NumberFormat currencyFormat,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          currencyFormat.format(amount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, app_model.Transaction transaction) {
    final language = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.get('confirmDelete', language: language)),
        content: Text(AppStrings.get('deleteTransactionConfirm', language: language)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get('cancel', language: language)),
          ),
          TextButton(
            onPressed: () {
              transactionProvider.deleteTransaction(transaction.id!);
              Navigator.pop(context);
              _loadTransactions();
            },
            child: Text(AppStrings.get('delete', language: language)),
          ),
        ],
      ),
    );
  }

  NumberFormat _getCurrencyFormat(String currency) {
    switch (currency) {
      case 'EUR':
        return NumberFormat.currency(symbol: '€');
      case 'GBP':
        return NumberFormat.currency(symbol: '£');
      case 'JPY':
        return NumberFormat.currency(symbol: '¥', decimalDigits: 0);
      case 'TRY':
        return NumberFormat.currency(symbol: '₺');
      case 'USD':
      default:
        return NumberFormat.currency(symbol: '\$');
    }
  }
} 