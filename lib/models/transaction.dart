class Transaction {
  static const String tableName = 'transactions';
  static const String colId = 'id';
  static const String colAmount = 'amount';
  static const String colType = 'type'; // 'income' or 'expense'
  static const String colCategoryId = 'category_id';
  static const String colDate = 'date';
  static const String colIsRecurring = 'is_recurring';
  static const String colNotes = 'notes';

  final int? id;
  final double amount;
  final String type;
  final int categoryId;
  final DateTime date;
  final bool isRecurring;
  final String notes;

  Transaction({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    required this.isRecurring,
    this.notes = '',
  });

  Transaction copy({
    int? id,
    double? amount,
    String? type,
    int? categoryId,
    DateTime? date,
    bool? isRecurring,
    String? notes,
  }) =>
      Transaction(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        categoryId: categoryId ?? this.categoryId,
        date: date ?? this.date,
        isRecurring: isRecurring ?? this.isRecurring,
        notes: notes ?? this.notes,
      );

  static Transaction fromMap(Map<String, dynamic> map) => Transaction(
        id: map[colId],
        amount: map[colAmount],
        type: map[colType],
        categoryId: map[colCategoryId],
        date: DateTime.parse(map[colDate]),
        isRecurring: map[colIsRecurring] == 1,
        notes: map[colNotes],
      );

  Map<String, dynamic> toMap() => {
        colAmount: amount,
        colType: type,
        colCategoryId: categoryId,
        colDate: date.toIso8601String(),
        colIsRecurring: isRecurring ? 1 : 0,
        colNotes: notes,
      };
} 