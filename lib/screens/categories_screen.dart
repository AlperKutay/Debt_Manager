import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart' as app_model;
import '../utils/icon_map.dart';
import 'add_category_screen.dart';
import '../utils/app_strings.dart';
import '../providers/language_provider.dart';

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
    final language = Provider.of<LanguageProvider>(context).currentLanguage;
    
    return Scaffold(
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final incomeCategories = categoryProvider.getByType('income');
          final expenseCategories = categoryProvider.getByType('expense');
          
          return Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: AppStrings.get('income', language: language)),
                  Tab(text: AppStrings.get('expense', language: language)),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCategoryListWithAddButton(incomeCategories, 'income'),
                    _buildCategoryListWithAddButton(expenseCategories, 'expense'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryListWithAddButton(List<app_model.Category> categories, String type) {
    final language = Provider.of<LanguageProvider>(context).currentLanguage;
    
    return Column(
      children: [
        Expanded(
          child: categories.isEmpty
              ? Center(
                  child: Text(AppStrings.get('noCategoriesFound', language: language)),
                )
              : ListView.builder(
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
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddCategoryScreen(
                      type: type,
                    ),
                  ),
                ).then((_) {
                  // Refresh categories when returning from add screen
                  Provider.of<CategoryProvider>(context, listen: false).loadCategories();
                });
              },
              icon: const Icon(Icons.add),
              label: Text(AppStrings.get('addCategory', language: language)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 