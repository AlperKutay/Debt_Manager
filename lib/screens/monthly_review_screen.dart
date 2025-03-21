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
      final date = transaction.date;
      
      // Determine which period this transaction belongs to
      DateTime periodStart;
      if (date.day < initialDay) {
        // If the transaction date is before the initial day, it belongs to the previous month's period
        periodStart = DateTime(date.year, date.month - 1, initialDay);
      } else {
        // Otherwise, it belongs to the current month's period
        periodStart = DateTime(date.year, date.month, initialDay);
      }
      
      final monthKey = '${periodStart.year}-${periodStart.month.toString().padLeft(2, '0')}';
      
      // Initialize the month data if it doesn't exist
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
    
    // Convert to a list and calculate balance for each month
    final monthsList = monthlyTotals.entries.map((entry) {
      final data = entry.value;
      data['balance'] = data['income'] - data['expense'];
      data['monthKey'] = entry.key;
      return data;
    }).toList();
    
    // Sort by date (oldest first)
    monthsList.sort((a, b) => (a['periodStart'] as DateTime).compareTo(b['periodStart'] as DateTime));
    
    // First month has no savings from previous month
    if (monthsList.isNotEmpty) {
      monthsList[0]['savings'] = 0.0;
    }
    
    // Calculate savings (previous month's balance + savings)
    for (int i = 1; i < monthsList.length; i++) {
      // Current month's savings is the previous month's balance + previous month's savings
      final previousBalance = monthsList[i-1]['balance'] as double;
      final previousSavings = monthsList[i-1]['savings'] as double;
      monthsList[i]['savings'] = previousBalance + previousSavings;
    }
    
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
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currencyFormat = _getCurrencyFormat(settingsProvider.settings.currency);
    
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: _monthlyData.isEmpty
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
                        final savings = monthData['savings'] as double? ?? 0.0;
                        
                        // Format the month name
                        final monthName = DateFormat('MMMM yyyy').format(periodStart);
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MonthlyTransactionsScreen(
                                    periodStart: periodStart,
                                    monthName: monthName,
                                    savings: savings,
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
                                      _buildFinancialItem(
                                        AppStrings.get('savings', language: language),
                                        savings,
                                        Colors.blue,
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
          _formatCurrency(amount, currencyFormat),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // New method to format currency without decimal places for whole numbers
  String _formatCurrency(double amount, NumberFormat currencyFormat) {
    // Check if the amount is a whole number
    if (amount == amount.roundToDouble()) {
      // Create a new formatter without decimal places
      final wholeNumberFormat = NumberFormat.currency(
        symbol: currencyFormat.currencySymbol,
        decimalDigits: 0,
      );
      return wholeNumberFormat.format(amount);
    } else {
      // Use the original formatter for non-whole numbers
      return currencyFormat.format(amount);
    }
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