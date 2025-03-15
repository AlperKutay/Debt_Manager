import 'package:flutter/foundation.dart';
import '../data/database_helper.dart';
import '../models/category.dart' as app_model;

class CategoryProvider with ChangeNotifier {
  List<app_model.Category> _categories = [];
  bool _isLoading = false;

  List<app_model.Category> get categories => _categories;
  bool get isLoading => _isLoading;

  List<app_model.Category> getByType(String type) {
    return _categories.where((category) => category.type == type).toList();
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await DatabaseHelper.instance.getCategories();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(app_model.Category category) async {
    try {
      final id = await DatabaseHelper.instance.insertCategory(category);
      _categories.add(category.copy(id: id));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding category: $e');
    }
  }

  Future<void> updateCategory(app_model.Category category) async {
    try {
      await DatabaseHelper.instance.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await DatabaseHelper.instance.deleteCategory(id);
      _categories.removeWhere((category) => category.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting category: $e');
    }
  }
} 