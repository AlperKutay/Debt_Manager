import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_strings.dart';
import '../providers/language_provider.dart';
import 'monthly_transactions_screen.dart';

class MonthlyReviewScreen extends StatefulWidget {
  const MonthlyReviewScreen({super.key});

  @override
  State<MonthlyReviewScreen> createState() => _MonthlyReviewScreenState();
}

class _MonthlyReviewScreenState extends State<MonthlyReviewScreen> {
  List<Map<String, dynamic>> _monthlyData = [];
  bool _isLoading = true;
  late TransactionProvider _transactionProvider;
  late SettingsProvider _settingsProvider;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_initialized) {
      _initialized = true;
      _transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      
      // Process existing data without loading
      _processMonthlyData();
      
      // Then schedule a refresh for after the build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshData();
      });
    }
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    // Load transactions first
    await _transactionProvider.loadTransactions();
    
    // Then process the data
    await _processMonthlyData();
  }

  Future<void> _processMonthlyData() async {
    if (!mounted) return;
    
    final initialDay = _settingsProvider.settings.initialDay;
    final transactions = _transactionProvider.transactions;
    
    // Group transactions by month
    final Map<String, Map<String, dynamic>> monthlyTotals = {};
    
    for (final transaction in transactions) {
      // Determine which month period this transaction belongs to
      final date = transaction.date;
      DateTime periodStart;
      
      // If the day is before the initial day, it belongs to the previous month's period
      if (date.day < initialDay) {
        periodStart = DateTime(date.year, date.month - 1, initialDay);
      } else {
        periodStart = DateTime(date.year, date.month, initialDay);
      }
      
      // Create a key for this month period (e.g., "2023-03")
      final monthKey = DateFormat('yyyy-MM').format(periodStart);
      
      // Initialize this month in our map if it doesn't exist
      if (!monthlyTotals.containsKey(monthKey)) {
        monthlyTotals[monthKey] = {
          'periodStart': periodStart,
          'income': 0.0,
          'expense': 0.0,
        };
      }
      
      // Add the transaction amount to the appropriate total
      if (transaction.type == 'income') {
        monthlyTotals[monthKey]!['income'] += transaction.amount;
      } else {
        monthlyTotals[monthKey]!['expense'] += transaction.amount;
      }
    }
    
    // Convert to a list and sort by date
    final monthsList = monthlyTotals.entries.map((entry) {
      final data = entry.value;
      data['balance'] = data['income'] - data['expense'];
      data['monthKey'] = entry.key;
      return data;
    }).toList();
    
    // Sort by date (oldest first)
    monthsList.sort((a, b) => (a['periodStart'] as DateTime).compareTo(b['periodStart'] as DateTime));
    
    if (mounted) {
      setState(() {
        _monthlyData = monthsList;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context).currentLanguage;
    final currencyFormat = _getCurrencyFormat(_settingsProvider.settings.currency);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('monthlyReview', language: language)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _monthlyData.isEmpty
                ? Center(
                    child: Text(AppStrings.get('noTransactionsFound', language: language)),
                  )
                : ListView.builder(
                    itemCount: _monthlyData.length,
                    itemBuilder: (context, index) {
                      final monthData = _monthlyData[index];
                      final periodStart = monthData['periodStart'] as DateTime;
                      final income = monthData['income'] as double;
                      final expense = monthData['expense'] as double;
                      final balance = monthData['balance'] as double;
                      
                      // Format the month name (e.g., "March 2023")
                      final monthName = DateFormat('MMMM yyyy').format(periodStart);
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: InkWell(
                          onTap: () {
                            // Navigate to detailed view for this month
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MonthlyTransactionsScreen(
                                  periodStart: periodStart,
                                  monthName: monthName,
                                ),
                              ),
                            ).then((_) => _refreshData());
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  monthName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildFinancialItem(
                                      AppStrings.get('income', language: language),
                                      income,
                                      Colors.green,
                                      currencyFormat,
                                    ),
                                    _buildFinancialItem(
                                      AppStrings.get('expense', language: language),
                                      expense,
                                      Colors.red,
                                      currencyFormat,
                                    ),
                                    _buildFinancialItem(
                                      AppStrings.get('balance', language: language),
                                      balance,
                                      balance >= 0 ? Colors.green : Colors.red,
                                      currencyFormat,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildFinancialItem(
    String title,
    double amount,
    Color color,
    NumberFormat currencyFormat,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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