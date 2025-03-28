import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart' as app_model;
import '../models/category.dart' as app_model;
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final app_model.Transaction? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _recurrenceCountController = TextEditingController();
  
  String _transactionType = 'expense';
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;

  @override
  void initState() {
    super.initState();
    
    // Load categories
    Future.microtask(() {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
    
    // If editing, populate the form
    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toString();
      _notesController.text = widget.transaction!.notes;
      _transactionType = widget.transaction!.type;
      _selectedCategoryId = widget.transaction!.categoryId;
      _selectedDate = widget.transaction!.date;
      _isRecurring = widget.transaction!.isRecurring;
      _recurrenceCountController.text = widget.transaction!.recurrenceCount.toString();
    } else {
      _recurrenceCountController.text = '0'; // Default to 0 (indefinite)
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _recurrenceCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction'),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final incomeCategories = categoryProvider.getByType('income');
          final expenseCategories = categoryProvider.getByType('expense');
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction Type Selector
                  const Text(
                    'Transaction Type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'expense',
                        label: Text('Expense'),
                        icon: Icon(Icons.arrow_upward),
                      ),
                      ButtonSegment(
                        value: 'income',
                        label: Text('Income'),
                        icon: Icon(Icons.arrow_downward),
                      ),
                    ],
                    selected: {_transactionType},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _transactionType = newSelection.first;
                        _selectedCategoryId = null; // Reset category when type changes
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Amount Field
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      //prefixIcon: Icon(Icons.attach_money),
                      prefixText: _getCurrencySymbol(Provider.of<SettingsProvider>(context).settings.currency),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Category Dropdown
                  const Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    value: _selectedCategoryId,
                    hint: const Text('Select a category'),
                    items: (_transactionType == 'income' ? incomeCategories : expenseCategories)
                        .map((app_model.Category category) {
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (int? value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Date Picker
                  const Text(
                    'Date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      DatePicker.showDatePicker(
                        context,
                        showTitleActions: true,
                        minTime: DateTime(2000, 1, 1),
                        maxTime: DateTime(2100, 12, 31),
                        currentTime: _selectedDate,
                        onConfirm: (date) {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMMM dd, yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Recurring Switch
                  Row(
                    children: [
                      const Text(
                        'Recurring Monthly',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Switch(
                        value: _isRecurring,
                        onChanged: (value) {
                          setState(() {
                            _isRecurring = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Recurrence Count Field (only visible if recurring is enabled)
                  if (_isRecurring)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'Recurrence Count',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'How many months should this transaction recur? (0 for indefinite)',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _recurrenceCountController,
                          decoration: const InputDecoration(
                            labelText: 'Number of Months',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.repeat),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a number';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            if (int.parse(value) < 0) {
                              return 'Please enter a non-negative number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  
                  // Notes Field
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        widget.transaction == null ? 'Add Transaction' : 'Update Transaction',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  // If you have a delete button, make it red
                  if (widget.transaction != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _deleteTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final notes = _notesController.text;
      final recurrenceCount = int.parse(_recurrenceCountController.text);
      
      final transaction = app_model.Transaction(
        id: widget.transaction?.id,
        amount: amount,
        type: _transactionType,
        categoryId: _selectedCategoryId!,
        date: _selectedDate,
        isRecurring: _isRecurring,
        recurrenceCount: recurrenceCount,
        notes: notes,
      );
      
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      
      if (widget.transaction == null) {
        provider.addTransaction(transaction, settingsProvider: settingsProvider);
      } else {
        provider.updateTransaction(transaction);
      }
      
      // Refresh transactions list
      provider.loadTransactions();
      
      // Refresh upcoming payments and other transaction-related widgets
      Future.microtask(() {
        // This will trigger a rebuild of all widgets that depend on TransactionProvider
        provider.notifyListeners();
      });
      
      Navigator.pop(context);
    }
  }

  void _deleteTransaction() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final provider = Provider.of<TransactionProvider>(context, listen: false);
              provider.deleteTransaction(widget.transaction!.id!);
              
              // Close the dialog and the edit screen
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
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