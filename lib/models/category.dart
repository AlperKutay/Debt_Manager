class Category {
  static const String tableName = 'categories';
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colType = 'type'; // 'income' or 'expense'
  static const String colIcon = 'icon';

  final int? id;
  final String name;
  final String type;
  final String icon;

  Category({
    this.id,
    required this.name,
    required this.type,
    required this.icon,
  });

  Category copy({
    int? id,
    String? name,
    String? type,
    String? icon,
  }) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        icon: icon ?? this.icon,
      );

  static Category fromMap(Map<String, dynamic> map) => Category(
        id: map[colId],
        name: map[colName],
        type: map[colType],
        icon: map[colIcon],
      );

  Map<String, dynamic> toMap() => {
        colName: name,
        colType: type,
        colIcon: icon,
      };
} 