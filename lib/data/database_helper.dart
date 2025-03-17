import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart' as app_model;
import '../models/category.dart' as app_model;
import '../models/settings.dart' as app_model;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('debt_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    // Categories table
    await db.execute('''
    CREATE TABLE ${app_model.Category.tableName} (
      ${app_model.Category.colId} $idType,
      ${app_model.Category.colName} $textType,
      ${app_model.Category.colType} $textType,
      ${app_model.Category.colIcon} $textType
    )
    ''');

    // Transactions table
    await db.execute('''
    CREATE TABLE ${app_model.Transaction.tableName} (
      ${app_model.Transaction.colId} $idType,
      ${app_model.Transaction.colAmount} $doubleType,
      ${app_model.Transaction.colType} $textType,
      ${app_model.Transaction.colCategoryId} $integerType,
      ${app_model.Transaction.colDate} $textType,
      ${app_model.Transaction.colIsRecurring} $integerType,
      ${app_model.Transaction.colRecurrenceCount} $integerType DEFAULT 0,
      ${app_model.Transaction.colNotes} $textType,
      FOREIGN KEY (${app_model.Transaction.colCategoryId}) REFERENCES ${app_model.Category.tableName} (${app_model.Category.colId})
    )
    ''');

    // Settings table
    await db.execute('''
    CREATE TABLE ${app_model.Settings.tableName} (
      ${app_model.Settings.colId} $idType,
      ${app_model.Settings.colInitialDay} $integerType,
      ${app_model.Settings.colCurrency} $textType,
      ${app_model.Settings.colThemeMode} $textType
    )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
    
    // Insert default settings
    await _insertDefaultSettings(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Check if settings table already exists
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='${app_model.Settings.tableName}'");
      
      if (tables.isEmpty) {
        // Only create the table if it doesn't exist
        const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
        const textType = 'TEXT NOT NULL';
        const integerType = 'INTEGER NOT NULL';
        
        // Settings table
        await db.execute('''
        CREATE TABLE ${app_model.Settings.tableName} (
          ${app_model.Settings.colId} $idType,
          ${app_model.Settings.colInitialDay} $integerType,
          ${app_model.Settings.colCurrency} $textType,
          ${app_model.Settings.colThemeMode} $textType
        )
        ''');
        
        // Insert default settings
        await _insertDefaultSettings(db);
      }
    }
    
    if (oldVersion < 3) {
      // Check if recurrence_count column already exists
      var tableInfo = await db.rawQuery("PRAGMA table_info(${app_model.Transaction.tableName})");
      bool columnExists = tableInfo.any((column) => 
        column['name'] == app_model.Transaction.colRecurrenceCount);
      
      if (!columnExists) {
        try {
          await db.execute('''
          ALTER TABLE ${app_model.Transaction.tableName}
          ADD COLUMN ${app_model.Transaction.colRecurrenceCount} INTEGER DEFAULT 0
          ''');
          print('Added recurrence_count column to transactions table');
        } catch (e) {
          print('Error adding recurrence_count column: $e');
        }
      } else {
        print('recurrence_count column already exists');
      }
    }
  }

  Future _insertDefaultCategories(Database db) async {
    // Income categories
    await db.insert(app_model.Category.tableName, {
      app_model.Category.colName: 'Salary',
      app_model.Category.colType: 'income',
      app_model.Category.colIcon: 'money',
    });
    
    await db.insert(app_model.Category.tableName, {
      app_model.Category.colName: 'Freelance',
      app_model.Category.colType: 'income',
      app_model.Category.colIcon: 'work',
    });

    // Expense categories
    await db.insert(app_model.Category.tableName, {
      app_model.Category.colName: 'Rent',
      app_model.Category.colType: 'expense',
      app_model.Category.colIcon: 'home',
    });
    
    await db.insert(app_model.Category.tableName, {
      app_model.Category.colName: 'Loan Payment',
      app_model.Category.colType: 'expense',
      app_model.Category.colIcon: 'credit_card',
    });
    
    await db.insert(app_model.Category.tableName, {
      app_model.Category.colName: 'Bills',
      app_model.Category.colType: 'expense',
      app_model.Category.colIcon: 'receipt',
    });
    
    await db.insert(app_model.Category.tableName, {
      app_model.Category.colName: 'Groceries',
      app_model.Category.colType: 'expense',
      app_model.Category.colIcon: 'shopping_cart',
    });
  }

  Future _insertDefaultSettings(Database db) async {
    await db.insert(app_model.Settings.tableName, {
      app_model.Settings.colInitialDay: 1,
      app_model.Settings.colCurrency: 'USD',
      app_model.Settings.colThemeMode: 'system',
    });
  }

  // CRUD operations for Transaction
  Future<int> insertTransaction(app_model.Transaction transaction) async {
    final db = await instance.database;
    return await db.insert(app_model.Transaction.tableName, transaction.toMap());
  }

  Future<List<app_model.Transaction>> getTransactions() async {
    final db = await instance.database;
    final result = await db.query(app_model.Transaction.tableName);
    return result.map((json) => app_model.Transaction.fromMap(json)).toList();
  }

  Future<List<app_model.Transaction>> getTransactionsByType(String type) async {
    final db = await instance.database;
    final result = await db.query(
      app_model.Transaction.tableName,
      where: '${app_model.Transaction.colType} = ?',
      whereArgs: [type],
    );
    return result.map((json) => app_model.Transaction.fromMap(json)).toList();
  }

  Future<List<app_model.Transaction>> getUpcomingTransactions(DateTime startDate, DateTime endDate) async {
    final db = await instance.database;
    
    // Get all transactions in the date range
    final result = await db.rawQuery('''
      SELECT * FROM ${app_model.Transaction.tableName}
      WHERE ${app_model.Transaction.colDate} >= ? AND ${app_model.Transaction.colDate} < ?
      ORDER BY ${app_model.Transaction.colDate} ASC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    // Also get recurring transactions that might need to be shown in upcoming
    final recurringResult = await db.rawQuery('''
      SELECT * FROM ${app_model.Transaction.tableName}
      WHERE ${app_model.Transaction.colIsRecurring} = 1
      ORDER BY ${app_model.Transaction.colDate} ASC
    ''');
    
    // Convert to Transaction objects
    final transactions = result.map((json) => app_model.Transaction.fromMap(json)).toList();
    final recurringTransactions = recurringResult.map((json) => app_model.Transaction.fromMap(json)).toList();
    
    // For recurring transactions, generate upcoming instances if they're not already in the list
    for (var transaction in recurringTransactions) {
      // Skip if recurrence count is 0 and we already have future instances
      if (transaction.recurrenceCount == 0) {
        continue; // We'll handle indefinite recurrence separately
      }
      
      // Generate upcoming instances based on recurrence count
      for (int i = 1; i <= transaction.recurrenceCount; i++) {
        final nextDate = _calculateNextRecurringDate(transaction.date, i);
        
        // Only add if it's in our date range and not already in the list
        if (nextDate.isAfter(startDate) && 
            nextDate.isBefore(endDate) && 
            !transactions.any((t) => 
                t.categoryId == transaction.categoryId && 
                t.amount == transaction.amount && 
                t.type == transaction.type && 
                t.date.year == nextDate.year && 
                t.date.month == nextDate.month && 
                t.date.day == nextDate.day)) {
          
          // Create a virtual transaction for the upcoming view
          final upcomingTransaction = transaction.copy(
            id: null, // Virtual transaction, no ID yet
            date: nextDate,
            isRecurring: false, // This is an instance, not the recurring definition
          );
          
          transactions.add(upcomingTransaction);
        }
      }
    }
    
    // Sort by date
    transactions.sort((a, b) => a.date.compareTo(b.date));
    
    return transactions;
  }

  DateTime _calculateNextRecurringDate(DateTime baseDate, int monthsAhead) {
    // Calculate the next date
    DateTime nextDate = DateTime(
      baseDate.year,
      baseDate.month + monthsAhead,
      baseDate.day,
    );
    
    // Handle invalid dates (e.g., February 31st)
    if (nextDate.month > (baseDate.month + monthsAhead) % 12) {
      // If the month overflowed, use the last day of the month
      nextDate = DateTime(
        baseDate.year,
        baseDate.month + monthsAhead,
        0, // Last day of the previous month
      );
    }
    
    return nextDate;
  }

  Future<int> updateTransaction(app_model.Transaction transaction) async {
    final db = await instance.database;
    return await db.update(
      app_model.Transaction.tableName,
      transaction.toMap(),
      where: '${app_model.Transaction.colId} = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete(
      app_model.Transaction.tableName,
      where: '${app_model.Transaction.colId} = ?',
      whereArgs: [id],
    );
  }

  // CRUD operations for Category
  Future<List<app_model.Category>> getCategories() async {
    final db = await instance.database;
    final result = await db.query(app_model.Category.tableName);
    return result.map((json) => app_model.Category.fromMap(json)).toList();
  }

  Future<List<app_model.Category>> getCategoriesByType(String type) async {
    final db = await instance.database;
    final result = await db.query(
      app_model.Category.tableName,
      where: '${app_model.Category.colType} = ?',
      whereArgs: [type],
    );
    return result.map((json) => app_model.Category.fromMap(json)).toList();
  }

  Future<int> insertCategory(app_model.Category category) async {
    final db = await instance.database;
    return await db.insert(app_model.Category.tableName, category.toMap());
  }

  Future<int> updateCategory(app_model.Category category) async {
    final db = await instance.database;
    return await db.update(
      app_model.Category.tableName,
      category.toMap(),
      where: '${app_model.Category.colId} = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await instance.database;
    return await db.delete(
      app_model.Category.tableName,
      where: '${app_model.Category.colId} = ?',
      whereArgs: [id],
    );
  }

  // CRUD operations for Settings
  Future<app_model.Settings> getSettings() async {
    try {
      final db = await instance.database;
      final result = await db.query(app_model.Settings.tableName);
      
      if (result.isEmpty) {
        // If no settings found, insert default and return it
        final settings = app_model.Settings();
        await insertSettings(settings);
        return settings;
      }
      
      return app_model.Settings.fromMap(result.first);
    } catch (e) {
      // If there's an error, return default settings
      print('Error getting settings: $e');
      return app_model.Settings();
    }
  }

  Future<int> insertSettings(app_model.Settings settings) async {
    final db = await instance.database;
    return await db.insert(app_model.Settings.tableName, settings.toMap());
  }

  Future<int> updateSettings(app_model.Settings settings) async {
    final db = await instance.database;
    return await db.update(
      app_model.Settings.tableName,
      settings.toMap(),
      where: '${app_model.Settings.colId} = ?',
      whereArgs: [settings.id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Add this method to initialize the database
  Future<void> initialize() async {
    await database;
  }

  Future<List<app_model.Transaction>> getTransactionsForPeriod(DateTime startDate, DateTime endDate) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT * FROM ${app_model.Transaction.tableName}
      WHERE ${app_model.Transaction.colDate} >= ? AND ${app_model.Transaction.colDate} < ?
      ORDER BY ${app_model.Transaction.colDate} ASC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    return result.map((json) => app_model.Transaction.fromMap(json)).toList();
  }
} 