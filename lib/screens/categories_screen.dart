import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart' as app_model;
import '../l10n/app_localizations.dart';
import '../utils/icon_map.dart';  // We'll create this file

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
        title: Text(AppLocalizations.of(context).categories),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context).expense),
            Tab(text: AppLocalizations.of(context).income),
          ],
        ),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final expenseCategories = categoryProvider.getByType('expense');
          final incomeCategories = categoryProvider.getByType('income');
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryList(expenseCategories, 'expense', categoryProvider),
              _buildCategoryList(incomeCategories, 'income', categoryProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildCategoryList(List<app_model.Category> categories, String type, CategoryProvider provider) {
    if (categories.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context).noTransactions),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: Icon(
              IconMap.getIcon(category.icon),
              color: type == 'expense' ? Colors.red : Colors.green,
            ),
            title: Text(category.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditCategoryDialog(context, category, provider),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteCategoryDialog(context, category, provider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    String selectedType = 'expense';
    String selectedIcon = 'shopping_cart';  // Default icon key
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context).addCategory),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).categoryName,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).categoryType,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(AppLocalizations.of(context).expense),
                            value: 'expense',
                            groupValue: selectedType,
                            onChanged: (value) {
                              setState(() {
                                selectedType = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(AppLocalizations.of(context).income),
                            value: 'income',
                            groupValue: selectedType,
                            onChanged: (value) {
                              setState(() {
                                selectedType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).categoryIcon,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildIconOptionNew('shopping_cart', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                        _buildIconOptionNew('fastfood', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                        _buildIconOptionNew('home', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                        _buildIconOptionNew('directions_car', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                        _buildIconOptionNew('school', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                        _buildIconOptionNew('medical_services', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                        _buildIconOptionNew('sports', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                        _buildIconOptionNew('movie', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context).cancel),
                ),
                TextButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      final provider = Provider.of<CategoryProvider>(context, listen: false);
                      final newCategory = app_model.Category(
                        name: nameController.text,
                        type: selectedType,
                        icon: selectedIcon,
                      );
                      
                      provider.addCategory(newCategory);
                      
                      Navigator.pop(context);
                    }
                  },
                  child: Text(AppLocalizations.of(context).save),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  Widget _buildIconOptionNew(String iconKey, String selectedIcon, Function(String) onSelected) {
    final isSelected = iconKey == selectedIcon;
    
    return GestureDetector(
      onTap: () => onSelected(iconKey),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Icon(
          IconMap.getIcon(iconKey),
          color: isSelected ? Colors.blue : Colors.grey.shade700,
        ),
      ),
    );
  }
  
  void _showEditCategoryDialog(BuildContext context, app_model.Category category, CategoryProvider provider) {
    final nameController = TextEditingController(text: category.name);
    String selectedType = category.type;
    String selectedIcon = category.icon;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context).edit),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).categoryName,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).categoryType,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(AppLocalizations.of(context).expense),
                            value: 'expense',
                            groupValue: selectedType,
                            onChanged: (value) {
                              setState(() {
                                selectedType = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(AppLocalizations.of(context).income),
                            value: 'income',
                            groupValue: selectedType,
                            onChanged: (value) {
                              setState(() {
                                selectedType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).categoryIcon,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildIconOptionNew('shopping_cart', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                        _buildIconOptionNew('fastfood', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                        _buildIconOptionNew('home', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                        _buildIconOptionNew('directions_car', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                        _buildIconOptionNew('school', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                        _buildIconOptionNew('medical_services', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                        _buildIconOptionNew('sports', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                        _buildIconOptionNew('movie', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context).cancel),
                ),
                TextButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      final updatedCategory = category.copy(
                        name: nameController.text,
                        type: selectedType,
                        icon: selectedIcon,
                      );
                      
                      provider.updateCategory(updatedCategory);
                      
                      Navigator.pop(context);
                    }
                  },
                  child: Text(AppLocalizations.of(context).save),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showDeleteCategoryDialog(BuildContext context, app_model.Category category, CategoryProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).confirmDelete),
          content: Text('${AppLocalizations.of(context).deleteTransactionConfirm} "${category.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context).cancel),
            ),
            TextButton(
              onPressed: () {
                provider.deleteCategory(category.id!);
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context).delete),
            ),
          ],
        );
      },
    );
  }
} 