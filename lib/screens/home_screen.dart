import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../models/transaction.dart' as app_model;
import 'add_transaction_screen.dart';
import 'transactions_screen.dart';
import 'categories_screen.dart';
import 'settings_screen.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    // Load transactions when the screen opens
    Future.microtask(() {
      Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
      Provider.of<SettingsProvider>(context, listen: false).loadSettings();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeTab(),
      const TransactionsScreen(),
      const CategoriesScreen(),
      const SettingsScreen(),
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).appTitle),
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context).home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: AppLocalizations.of(context).transactions,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.category),
            label: AppLocalizations.of(context).categories,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: AppLocalizations.of(context).settings,
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTransactionScreen(),
                  ),
                ).then((_) {
                  // Refresh transactions when returning from add screen
                  Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
                });
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
  
  Widget _buildHomeTab() {
    return Consumer2<TransactionProvider, SettingsProvider>(
      builder: (context, transactionProvider, settingsProvider, child) {
        if (transactionProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final currentMonthTransactions = transactionProvider.getCurrentMonthTransactions();
        final upcomingTransactions = transactionProvider.getUpcomingTransactions();
        
        final totalIncome = transactionProvider.getTotalIncome();
        final totalExpense = transactionProvider.getTotalExpense();
        final balance = totalIncome - totalExpense;
        
        final currencySymbol = _getCurrencySymbol(settingsProvider.settings.currency);
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: AppLocalizations.of(context).income,
                      amount: totalIncome,
                      currencySymbol: currencySymbol,
                      color: Colors.green,
                      icon: Icons.arrow_downward,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      title: AppLocalizations.of(context).expense,
                      amount: totalExpense,
                      currencySymbol: currencySymbol,
                      color: Colors.red,
                      icon: Icons.arrow_upward,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                title: AppLocalizations.of(context).balance,
                amount: balance,
                currencySymbol: currencySymbol,
                color: balance >= 0 ? Colors.blue : Colors.red,
                icon: Icons.account_balance_wallet,
                fullWidth: true,
              ),
              
              const SizedBox(height: 24),
              
              // Current Month Transactions
              Text(
                AppLocalizations.of(context).currentMonth,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              if (currentMonthTransactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(AppLocalizations.of(context).noTransactions),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: currentMonthTransactions.length > 5 ? 5 : currentMonthTransactions.length,
                  itemBuilder: (context, index) {
                    return _buildTransactionItem(
                      currentMonthTransactions[index],
                      currencySymbol,
                      transactionProvider,
                    );
                  },
                ),
              
              if (currentMonthTransactions.length > 5)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1; // Switch to transactions tab
                    });
                  },
                  child: Text(AppLocalizations.of(context).viewAll),
                ),
              
              const SizedBox(height: 24),
              
              // Upcoming Payments
              Text(
                AppLocalizations.of(context).upcomingPayments,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              if (upcomingTransactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(AppLocalizations.of(context).noTransactions),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: upcomingTransactions.length > 5 ? 5 : upcomingTransactions.length,
                  itemBuilder: (context, index) {
                    return _buildTransactionItem(
                      upcomingTransactions[index],
                      currencySymbol,
                      transactionProvider,
                    );
                  },
                ),
              
              if (upcomingTransactions.length > 5)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1; // Switch to transactions tab
                    });
                  },
                  child: Text(AppLocalizations.of(context).viewAll),
                ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required String currencySymbol,
    required Color color,
    required IconData icon,
    bool fullWidth = false,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: fullWidth ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: fullWidth ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: fullWidth ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(icon, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$currencySymbol ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: fullWidth ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTransactionItem(
    app_model.Transaction transaction,
    String currencySymbol,
    TransactionProvider provider,
  ) {
    final categoryName = provider.getCategoryName(transaction.categoryId);
    final isExpense = transaction.type == 'expense';
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isExpense ? Colors.red : Colors.green,
          child: Icon(
            isExpense ? Icons.arrow_upward : Icons.arrow_downward,
            color: Colors.white,
          ),
        ),
        title: Text(categoryName),
        subtitle: Text(DateFormat('MMM dd, yyyy').format(transaction.date)),
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
            provider.loadTransactions();
          });
        },
      ),
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