import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart' as app_model;
import '../utils/icon_map.dart';
import 'add_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load categories when the screen opens
    Future.microtask(() {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Income'),
            Tab(text: 'Expense'),
          ],
        ),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final incomeCategories = categoryProvider.getByType('income');
          final expenseCategories = categoryProvider.getByType('expense');
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryList(incomeCategories, 'income'),
              _buildCategoryList(expenseCategories, 'expense'),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCategoryScreen(
                type: _tabController.index == 0 ? 'income' : 'expense',
              ),
            ),
          ).then((_) {
            // Refresh categories when returning from add screen
            Provider.of<CategoryProvider>(context, listen: false).loadCategories();
          });
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryList(List<app_model.Category> categories, String type) {
    if (categories.isEmpty) {
      return Center(
        child: Text('No ${type} categories found'),
      );
    }
    
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: type == 'income' ? Colors.green.shade100 : Colors.red.shade100,
            child: Icon(
              IconMap.getIcon(category.icon),
              color: type == 'income' ? Colors.green : Colors.red,
            ),
          ),
          title: Text(category.name),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCategoryScreen(
                    category: category,
                  ),
                ),
              ).then((_) {
                // Refresh categories when returning from edit screen
                Provider.of<CategoryProvider>(context, listen: false).loadCategories();
              });
            },
          ),
        );
      },
    );
  }
} 