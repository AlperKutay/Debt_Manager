import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';

class CurrentMonthBalanceCard extends StatefulWidget {
  const CurrentMonthBalanceCard({super.key});

  @override
  State<CurrentMonthBalanceCard> createState() => _CurrentMonthBalanceCardState();
}

class _CurrentMonthBalanceCardState extends State<CurrentMonthBalanceCard> {
  double _balance = 0.0;
  double _income = 0.0;
  double _expense = 0.0;
  bool _isLoading = true;
  bool _firstLoad = true;
  TransactionProvider? _transactionProvider;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    // Store a reference to the provider
    _transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    _transactionProvider?.addListener(_onTransactionsChanged);
    
    // Schedule the initial load after the build is complete
    Future.microtask(() {
      if (!_disposed) {
        _loadBalanceData();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only reload on first dependency change to avoid excessive reloads
    if (_firstLoad) {
      _firstLoad = false;
      // No need to call _loadBalanceData here as it's already called in initState
    }
  }

  @override
  void dispose() {
    _disposed = true;
    // Use the stored reference to remove the listener
    _transactionProvider?.removeListener(_onTransactionsChanged);
    super.dispose();
  }

  void _onTransactionsChanged() {
    if (!_disposed) {
      _loadBalanceData();
    }
  }

  Future<void> _loadBalanceData() async {
    if (_disposed) return;
    
    try {
      if (!_disposed && mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      final transactionProvider = _transactionProvider;
      
      if (transactionProvider == null) return;
      
      final initialDay = settingsProvider.settings.initialDay;
      final periodDates = transactionProvider.getCurrentPeriodDates(initialDay);
      
      final startDate = periodDates['start']!;
      final endDate = periodDates['end']!;
      
      final income = await transactionProvider.getIncomeForPeriod(startDate, endDate);
      final expense = await transactionProvider.getExpenseForPeriod(startDate, endDate);
      final balance = income - expense;
      
      if (_disposed || !mounted) return;
      
      setState(() {
        _income = income;
        _expense = expense;
        _balance = balance;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading balance data: $e');
      
      if (_disposed || !mounted) return;
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currencyFormat = _getCurrencyFormat(settingsProvider.settings.currency);
    
    if (_isLoading) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estimated Balance of Current Interval',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(_balance),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _balance >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBalanceItem(
                  context,
                  'Income',
                  _income,
                  Colors.green,
                  Icons.arrow_downward,
                  currencyFormat,
                ),
                _buildBalanceItem(
                  context,
                  'Expense',
                  _expense,
                  Colors.red,
                  Icons.arrow_upward,
                  currencyFormat,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(
    BuildContext context,
    String title,
    double amount,
    Color color,
    IconData icon,
    NumberFormat currencyFormat,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          currencyFormat.format(amount),
          style: TextStyle(
            fontSize: 18,
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