import 'package:flutter/material.dart';
import '../utils/icon_map.dart';

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

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      icon: map['icon'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
    };
  }

  // Helper method to get the IconData from the icon string
  IconData getIconData() {
    return IconMap.getIcon(icon);
  }
} 