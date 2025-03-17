import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart' as app_model;
import '../utils/icon_map.dart';

class AddCategoryScreen extends StatefulWidget {
  final app_model.Category? category;
  final String? type;

  const AddCategoryScreen({super.key, this.category, this.type});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String _categoryType = 'expense';
  String _selectedIcon = 'help_outline';
  
  final List<String> _availableIcons = [
    'money',
    'work',
    'home',
    'credit_card',
    'receipt',
    'shopping_cart',
    'restaurant',
    'local_gas_station',
    'directions_car',
    'local_hospital',
    'school',
    'flight',
    'hotel',
    'sports',
    'fitness_center',
    'local_movies',
    'music_note',
    'book',
    'devices',
    'card_giftcard',
  ];

  @override
  void initState() {
    super.initState();
    
    // If editing, populate the form
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _categoryType = widget.category!.type;
      _selectedIcon = widget.category!.icon;
    } else if (widget.type != null) {
      _categoryType = widget.type!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Type Selector
              const Text(
                'Category Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'expense',
                    label: Text('Expense'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment(
                    value: 'income',
                    label: Text('Income'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                ],
                selected: {_categoryType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _categoryType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Icon Selector
              const Text(
                'Select Icon',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _availableIcons.length,
                  itemBuilder: (context, index) {
                    final iconName = _availableIcons[index];
                    final isSelected = _selectedIcon == iconName;
                    
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIcon = iconName;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.2) : null,
                          border: Border.all(
                            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          IconMap.getIcon(iconName),
                          color: isSelected ? Theme.of(context).primaryColor : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    widget.category == null ? 'Add Category' : 'Update Category',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              
              // Delete Button (only for editing)
              if (widget.category != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _deleteCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Delete Category',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      
      final category = app_model.Category(
        id: widget.category?.id,
        name: name,
        type: _categoryType,
        icon: _selectedIcon,
      );
      
      final provider = Provider.of<CategoryProvider>(context, listen: false);
      
      if (widget.category == null) {
        provider.addCategory(category);
      } else {
        provider.updateCategory(category);
      }
      
      Navigator.pop(context);
    }
  }

  void _deleteCategory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this category? This will not delete associated transactions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final provider = Provider.of<CategoryProvider>(context, listen: false);
              provider.deleteCategory(widget.category!.id!);
              
              // Close the dialog and the edit screen
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 