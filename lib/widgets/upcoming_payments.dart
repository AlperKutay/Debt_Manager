import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../models/transaction.dart' as app_model;
import '../models/category.dart' as app_model;
import '../providers/settings_provider.dart';

class UpcomingPayments extends StatelessWidget {
  final int? limit;

  const UpcomingPayments({super.key, this.limit});

  @override
  Widget build(BuildContext context) {
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
          return const Center(
            child: Text('No upcoming payments'),
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
                    name: 'Unknown',
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
    
    // Calculate days until this transaction
    final daysUntil = transaction.date.difference(DateTime.now()).inDays;
    String daysText = daysUntil == 0 ? 'Today' : 
                      daysUntil == 1 ? 'Tomorrow' : 
                      'In $daysUntil days';
    
    subtitleText += ' · $daysText';
    
    return Card(
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