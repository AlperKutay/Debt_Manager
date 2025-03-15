import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart' as app_model;
import '../models/category.dart' as app_model;

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
      version: 1,
      onCreate: _createDB,
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
      ${app_model.Transaction.colNotes} $textType,
      FOREIGN KEY (${app_model.Transaction.colCategoryId}) REFERENCES ${app_model.Category.tableName} (${app_model.Category.colId})
    )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
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

  Future<List<app_model.Transaction>> getUpcomingTransactions(DateTime fromDate, DateTime toDate) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT * FROM ${app_model.Transaction.tableName}
      WHERE ${app_model.Transaction.colDate} BETWEEN ? AND ?
      ORDER BY ${app_model.Transaction.colDate} ASC
    ''', [fromDate.toIso8601String(), toDate.toIso8601String()]);
    
    return result.map((json) => app_model.Transaction.fromMap(json)).toList();
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

  Future close() async {
    final db = await instance.database;
    db.close();
  }
} 