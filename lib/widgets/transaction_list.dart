import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../models/transaction.dart' as app_model;
import '../models/category.dart' as app_model;

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
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final isIncome = transaction.type == 'income';

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              // Edit transaction
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
} 