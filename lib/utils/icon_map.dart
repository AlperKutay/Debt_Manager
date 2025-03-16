import 'package:flutter/material.dart';

class IconMap {
  static final Map<String, IconData> _iconMap = {
    'shopping_cart': Icons.shopping_cart,
    'fastfood': Icons.fastfood,
    'home': Icons.home,
    'directions_car': Icons.directions_car,
    'school': Icons.school,
    'medical_services': Icons.medical_services,
    'sports': Icons.sports,
    'movie': Icons.movie,
    'work': Icons.work,
    'attach_money': Icons.attach_money,
    'savings': Icons.savings,
    'card_giftcard': Icons.card_giftcard,
    'category': Icons.category,
  };

  static IconData getIcon(String iconKey) {
    // Try to get the icon from the map
    if (_iconMap.containsKey(iconKey)) {
      return _iconMap[iconKey]!;
    }
    
    // If the iconKey is not in the map, try to parse it as a legacy code point
    try {
      final iconCode = int.parse(iconKey);
      // For backward compatibility, return a predefined icon based on the code point
      switch (iconCode) {
        case 0xe25c:
          return Icons.shopping_cart;
        case 0xe8e5:
          return Icons.fastfood;
        case 0xe8d4:
          return Icons.home;
        case 0xe8d9:
          return Icons.directions_car;
        case 0xe8f8:
          return Icons.school;
        case 0xe8e7:
          return Icons.medical_services;
        case 0xe332:
          return Icons.sports;
        case 0xe8f6:
          return Icons.movie;
        default:
          return Icons.category;
      }
    } catch (e) {
      // If parsing fails, return a default icon
      return Icons.category;
    }
  }
} 