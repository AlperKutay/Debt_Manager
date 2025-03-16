import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../models/transaction.dart' as app_model;
import '../models/category.dart' as app_model;
import '../screens/add_transaction_screen.dart';

class CurrentMonthTransactions extends StatefulWidget {
  final int? limit;

  const CurrentMonthTransactions({super.key, this.limit});

  @override
  State<CurrentMonthTransactions> createState() => _CurrentMonthTransactionsState();
}

class _CurrentMonthTransactionsState extends State<CurrentMonthTransactions> {
  late Future<List<app_model.Transaction>> _transactionsFuture;
  
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload transactions when dependencies change (like settings)
    _loadTransactions();
  }
  
  void _loadTransactions() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final initialDay = settingsProvider.settings.initialDay;
    
    // Calculate the current month's start and end dates based on the initial day
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
    
    _transactionsFuture = Provider.of<TransactionProvider>(context, listen: false)
        .getTransactionsForPeriod(currentMonthStart, nextMonthStart);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<app_model.Transaction>>(
      future: _transactionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final transactions = snapshot.data ?? [];
        final limitedTransactions = widget.limit != null && transactions.length > widget.limit!
            ? transactions.take(widget.limit!).toList()
            : transactions;

        if (limitedTransactions.isEmpty) {
          return const Center(
            child: Text('No transactions for the current month'),
          );
        }

        return Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
            return ListView.builder(
              shrinkWrap: true,
              physics: widget.limit != null
                  ? const NeverScrollableScrollPhysics()
                  : null,
              itemCount: limitedTransactions.length,
              itemBuilder: (context, index) {
                final transaction = limitedTransactions[index];
                final category = categoryProvider.categories.firstWhere(
                  (c) => c.id == transaction.categoryId,
                  orElse: () => app_model.Category(
                    name: 'Unknown',
                    type: transaction.type,
                    icon: 'help',
                  ),
                );

                return _buildTransactionItem(
                  context,
                  transaction,
                  category,
                  Provider.of<TransactionProvider>(context, listen: false),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    app_model.Transaction transaction,
    app_model.Category category,
    TransactionProvider provider,
  ) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = _getCurrencyFormat(settingsProvider.settings.currency);
    final isIncome = transaction.type == 'income';

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              // Navigate to edit transaction screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTransactionScreen(
                    transaction: transaction,
                  ),
                ),
              );
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) {
              provider.deleteTransaction(transaction.id!);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
          title: Text(category.name),
          subtitle: Text(
            '${dateFormat.format(transaction.date)}${transaction.isRecurring ? ' · Recurring' : ''}',
          ),
          trailing: Text(
            currencyFormat.format(transaction.amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
          onTap: () {
            // Show transaction details
          },
        ),
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