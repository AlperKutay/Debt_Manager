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
import '../providers/language_provider.dart';
import '../utils/app_strings.dart';

class UpcomingPayments extends StatelessWidget {
  final int? limit;

  const UpcomingPayments({super.key, this.limit});

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context).currentLanguage;
    
    return FutureBuilder<List<app_model.Transaction>>(
      future: Provider.of<TransactionProvider>(context, listen: false)
          .getUpcomingTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final upcomingTransactions = snapshot.data ?? [];
        
        // Filter transactions if needed (e.g., only show expenses)
        // final filteredTransactions = upcomingTransactions.where((t) => t.type == 'expense').toList();
        
        final limitedTransactions = limit != null && upcomingTransactions.length > limit!
            ? upcomingTransactions.take(limit!).toList()
            : upcomingTransactions;

        if (limitedTransactions.isEmpty) {
          return Center(
            child: Text(AppStrings.get('No upcoming payments', language: language)),
          );
        }

        return Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
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
                    name: AppStrings.get('unknownCategory', language: language),
                    type: transaction.type,
                    icon: 'help',
                  ),
                );

                return _buildPaymentItem(context, transaction, category);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentItem(
    BuildContext context,
    app_model.Transaction transaction,
    app_model.Category category,
  ) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final language = Provider.of<LanguageProvider>(context).currentLanguage;
    
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = _getCurrencyFormat(settingsProvider.settings.currency);
    final isIncome = transaction.type == 'income';
    
    // Create the subtitle text
    String subtitleText = dateFormat.format(transaction.date);
    if (transaction.isRecurring) {
      subtitleText += ' · ${AppStrings.get('Recurring', language: language)}';
      if (transaction.recurrenceCount > 0) {
        subtitleText += ' (${transaction.recurrenceCount} ${AppStrings.get('months', language: language)})';
      } else {
        subtitleText += ' (${AppStrings.get('indefinite', language: language)})';
      }
    }
    
    // Calculate days until this transaction
    final daysUntil = transaction.date.difference(DateTime.now()).inDays;
    String daysText = daysUntil == 0 ? AppStrings.get('Today', language: language) : 
                      daysUntil == 1 ? AppStrings.get('Tomorrow', language: language) : 
                      '${AppStrings.get('In', language: language)} $daysUntil ${AppStrings.get('days', language: language)}';
    
    subtitleText += ' · $daysText';
    
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTransactionScreen(transaction: transaction),
                ),
              ).then((_) {
                // This will refresh the upcoming payments list
                transactionProvider.loadTransactions();
              });
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: AppStrings.get('edit', language: language),
          ),
          SlidableAction(
            onPressed: (context) {
              _showDeleteConfirmationDialog(context, transaction.id!, transactionProvider);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: AppStrings.get('delete', language: language),
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTransactionScreen(transaction: transaction),
              ),
            ).then((_) {
              // This will refresh the upcoming payments list
              transactionProvider.loadTransactions();
            });
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int transactionId, TransactionProvider provider) {
    final language = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
    
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
              provider.deleteTransaction(transactionId);
              Navigator.pop(context);
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