import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/category_model.dart';

class CategoryCrud {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertCategory(CategoryModel category) async {
    final db = await _dbHelper.database;
    return await db.insert(
      DatabaseHelper.tableCategories,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CategoryModel>> getCategories({bool? isIncome}) async {
    final db = await _dbHelper.database;

    List<Map<String, dynamic>> maps;
    if (isIncome != null) {
      maps = await db.query(
        DatabaseHelper.tableCategories,
        where: 'isIncome = ?',
        whereArgs: [isIncome ? 1 : 0],
        orderBy: 'name ASC',
      );
    } else {
      maps = await db.query(
        DatabaseHelper.tableCategories,
        orderBy: 'name ASC',
      );
    }

    return List.generate(maps.length, (i) {
      return CategoryModel.fromMap(maps[i]);
    });
  }

  Future<int> updateCategory(CategoryModel category) async {
    final db = await _dbHelper.database;
    return await db.update(
      DatabaseHelper.tableCategories,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseHelper.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
