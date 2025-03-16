import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../models/transaction.dart' as app_model;
import 'add_transaction_screen.dart';
import '../l10n/app_localizations.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  void initState() {
    super.initState();
    // Load transactions when the screen opens
    Future.microtask(() {
      Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, SettingsProvider>(
      builder: (context, transactionProvider, settingsProvider, child) {
        if (transactionProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = transactionProvider.transactions;
        final currencySymbol = _getCurrencySymbol(settingsProvider.settings.currency);

        if (transactions.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context).noTransactions),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            final categoryName = transactionProvider.getCategoryName(transaction.categoryId);
            final isExpense = transaction.type == 'expense';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isExpense ? Colors.red : Colors.green,
                  child: Icon(
                    isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.white,
                  ),
                ),
                title: Text(categoryName),
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
                  '$currencySymbol ${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isExpense ? Colors.red : Colors.green,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTransactionScreen(transaction: transaction),
                    ),
                  ).then((_) {
                    // Refresh transactions when returning from edit screen
                    transactionProvider.loadTransactions();
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'TRY':
        return '₺';
      case 'USD':
      default:
        return '\$';
    }
  }
} 