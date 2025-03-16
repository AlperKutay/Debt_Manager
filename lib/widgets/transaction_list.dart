import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../models/transaction.dart' as app_model;
import '../models/category.dart' as app_model;
import '../providers/settings_provider.dart';
import '../screens/add_transaction_screen.dart';

class TransactionList extends StatelessWidget {
  final int? limit;

  const TransactionList({super.key, this.limit});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, CategoryProvider>(
      builder: (context, transactionProvider, categoryProvider, child) {
        if (transactionProvider.isLoading || categoryProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = transactionProvider.transactions;
        final limitedTransactions = limit != null && transactions.length > limit!
            ? transactions.take(limit!).toList()
            : transactions;

        if (limitedTransactions.isEmpty) {
          return const Center(
            child: Text('No transactions yet. Add one!'),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: limit != null
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
              transactionProvider,
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

    // Create the subtitle text
    String subtitleText = dateFormat.format(transaction.date);
    if (transaction.isRecurring) {
      subtitleText += ' · Recurring';
      if (transaction.recurrenceCount > 0) {
        subtitleText += ' (${transaction.recurrenceCount} months)';
      } else {
        subtitleText += ' (indefinite)';
      }
    }

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
          subtitle: Text(subtitleText),
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