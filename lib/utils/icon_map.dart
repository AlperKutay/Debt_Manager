import 'package:flutter/material.dart';

class IconMap {
  static IconData getIcon(String iconName) {
    switch (iconName) {
      case 'money':
        return Icons.attach_money;
      case 'work':
        return Icons.work;
      case 'home':
        return Icons.home;
      case 'credit_card':
        return Icons.credit_card;
      case 'receipt':
        return Icons.receipt;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_gas_station':
        return Icons.local_gas_station;
      case 'directions_car':
        return Icons.directions_car;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'flight':
        return Icons.flight;
      case 'hotel':
        return Icons.hotel;
      case 'sports':
        return Icons.sports;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'local_movies':
        return Icons.local_movies;
      case 'music_note':
        return Icons.music_note;
      case 'book':
        return Icons.book;
      case 'devices':
        return Icons.devices;
      case 'card_giftcard':
        return Icons.card_giftcard;
      default:
        return Icons.help_outline;
    }
  }
} 