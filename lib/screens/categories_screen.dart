import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/segmented_control.dart';
import '../widgets/category_tile.dart';
import '../core/routes/app_routes.dart';
import '../database/crud/category_crud.dart';
import '../database/models/category_model.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _selectedTypeIndex = 0; // 0 para Entradas, 1 para Saídas
  late Future<List<CategoryModel>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    setState(() {
      _categoriesFuture = CategoryCrud().getCategories(
        isIncome: _selectedTypeIndex == 0,
      );
    });
  }

  Future<void> _deleteCategory(int id) async {
    await CategoryCrud().deleteCategory(id);
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final bool isIncome = _selectedTypeIndex == 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Categorias',
              subtitle: 'Organize seus lançamentos',
              trailing: FloatingActionButton(
                mini: true,
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, AppRoutes.formCategory);
                  if (result == true) {
                    _loadCategories();
                  }
                },
                elevation: 0,
                child: const Icon(Icons.add),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: CustomSegmentedControl(
                options: const ['Entradas', 'Saídas'],
                selectedIndex: _selectedTypeIndex,
                onValueChanged: (index) {
                  setState(() {
                    _selectedTypeIndex = index;
                    _loadCategories();
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List<CategoryModel>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma categoria encontrada.'),
                    );
                  }

                  final categories = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return CategoryTile(
                        title: category.name,
                        isIncome: category.isIncome,
                        onDelete: () => _deleteCategory(category.id!),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
