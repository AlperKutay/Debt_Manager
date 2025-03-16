import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_list.dart';
import '../widgets/upcoming_payments.dart';
import '../widgets/current_month_transactions.dart';
import 'add_transaction_screen.dart';
import 'settings_screen.dart';
import 'package:intl/intl.dart';
import '../widgets/current_month_balance_card.dart';

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
    // Load transactions when the app starts
    Future.microtask(() {
      Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Upcoming',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const TransactionList();
      case 2:
        return const UpcomingPayments();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Get the initial day from settings
        final initialDay = Provider.of<SettingsProvider>(context).settings.initialDay;
        
        // Calculate the current month's start and end dates
        final now = DateTime.now();
        DateTime currentMonthStart;
        DateTime nextMonthStart;
        
        // If today is before the initial day of this month, the period starts from last month's initial day
        if (now.day < initialDay) {
          currentMonthStart = DateTime(now.year, now.month - 1, initialDay);
          nextMonthStart = DateTime(now.year, now.month, initialDay);
        } else {
          // Otherwise, the period starts from this month's initial day
          currentMonthStart = DateTime(now.year, now.month, initialDay);
          nextMonthStart = DateTime(now.year, now.month + 1, initialDay);
        }
        
        final dateFormat = DateFormat('MMM dd');
        final dateRangeText = '${dateFormat.format(currentMonthStart)} - ${dateFormat.format(nextMonthStart.subtract(const Duration(days: 1)))}';
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CurrentMonthBalanceCard(),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Month',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dateRangeText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const CurrentMonthTransactions(limit: 5),
              const SizedBox(height: 24),
              const Text(
                'Upcoming Payments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const UpcomingPayments(limit: 3),
            ],
          ),
        );
      },
    );
  }
} 