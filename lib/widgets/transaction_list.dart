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

class TransactionList extends StatelessWidget {
  final bool showAppBar;
  final String? filter;
  
  const TransactionList({super.key, this.showAppBar = true, this.filter});

  @override
  Widget build(BuildContext context) {
    // Listen to both transaction provider and language provider
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final language = Provider.of<LanguageProvider>(context).currentLanguage;
    
    if (transactionProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final transactions = filter == null 
        ? transactionProvider.transactions 
        : transactionProvider.transactions.where((t) => t.type == filter).toList();
    
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          AppStrings.get('noTransactionsFound', language: language),
          style: const TextStyle(fontSize: 16),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        
        // Get category name
        String? categoryName;
        if (transaction.categoryId != null) {
          // Check if categories are loaded
          if (categoryProvider.categories.isNotEmpty) {
            try {
              final category = categoryProvider.categories.firstWhere(
                (c) => c.id == transaction.categoryId,
              );
              categoryName = category.name;
            } catch (e) {
              // Category not found
              categoryName = null;
            }
          } else {
            // Categories not loaded yet
            categoryName = null;
          }
        }
        
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
                      builder: (context) => AddTransactionScreen(transaction: transaction),
                    ),
                  );
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
            margin: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isExpense ? Colors.red[100] : Colors.green[100],
                child: Icon(
                  isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isExpense ? Colors.red : Colors.green,
                ),
              ),
              title: Text(
                categoryName ?? AppStrings.get('unknownCategory', language: language),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                DateFormat('MMM dd, yyyy').format(transaction.date),
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: Text(
                '${isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isExpense ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTransactionScreen(transaction: transaction),
                  ),
                );
              },
            ),
          ),
        );
      },
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
} 