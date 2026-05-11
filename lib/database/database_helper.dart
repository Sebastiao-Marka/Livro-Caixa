import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/category_model.dart';
import 'models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Nomes das tabelas
  static const String tableTransactions = 'transactions';
  static const String tableCategories = 'categories';

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  // Singleton instance getter
  static DatabaseHelper get instance => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'zabe.db');
    return await openDatabase(
      path,
      version: 2, // Incrementado a versão para adicionar tabela de categorias
      onCreate: (db, version) async {
        // Criar tabela de transações
        await db.execute('''
          CREATE TABLE $tableTransactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            description TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            dateMillis INTEGER NOT NULL,
            isIncome INTEGER NOT NULL,
            category TEXT NOT NULL,
            store_id INTEGER
          )
        ''');

        // Criar tabela de categorias
        await db.execute('''
          CREATE TABLE $tableCategories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            icon TEXT NOT NULL,
            color TEXT NOT NULL,
            isIncome INTEGER NOT NULL
          )
        ''');

        // Inserir categorias padrão
        await _insertDefaultCategories(db);

        // Inserir dados de exemplo para transações
        await _insertExampleTransactions(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Criar tabela de categorias se não existir
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $tableCategories(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL UNIQUE,
              icon TEXT NOT NULL,
              color TEXT NOT NULL,
              isIncome INTEGER NOT NULL
            )
          ''');

          // Inserir categorias padrão
          await _insertDefaultCategories(db);
        }
      },
    );
  }

  Future<void> _insertDefaultCategories(Database db) async {
    // Categorias de entrada
    final incomeCategories = [
      {'name': 'Vendas', 'icon': '💰', 'color': '#4CAF50', 'isIncome': 1},
      {'name': 'Serviços', 'icon': '⚙️', 'color': '#2196F3', 'isIncome': 1},
      {'name': 'Produtos', 'icon': '📦', 'color': '#FF9800', 'isIncome': 1},
      {'name': 'Comissões', 'icon': '💵', 'color': '#9C27B0', 'isIncome': 1},
      {
        'name': 'Outras Entradas',
        'icon': '📈',
        'color': '#607D8B',
        'isIncome': 1,
      },
    ];

    // Categorias de saída
    final expenseCategories = [
      {'name': 'Compras', 'icon': '🛒', 'color': '#F44336', 'isIncome': 0},
      {'name': 'Aluguel', 'icon': '🏠', 'color': '#FF5722', 'isIncome': 0},
      {'name': 'Salários', 'icon': '👥', 'color': '#E91E63', 'isIncome': 0},
      {'name': 'Marketing', 'icon': '📢', 'color': '#00BCD4', 'isIncome': 0},
      {'name': 'Impostos', 'icon': '📋', 'color': '#795548', 'isIncome': 0},
      {'name': 'Manutenção', 'icon': '🔧', 'color': '#3F51B5', 'isIncome': 0},
      {
        'name': 'Outras Saídas',
        'icon': '📉',
        'color': '#9E9E9E',
        'isIncome': 0,
      },
    ];

    for (var category in incomeCategories) {
      await db.insert(
        tableCategories,
        category,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    for (var category in expenseCategories) {
      await db.insert(
        tableCategories,
        category,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> _insertExampleTransactions(Database db) async {
    final now = DateTime.now();

    // Exemplo de transações para os últimos meses
    for (int i = 0; i < 6; i++) {
      final date = DateTime(now.year, now.month - i, 15);

      // Entrada
      await db.insert(tableTransactions, {
        'description': 'Vendas ${_getMonthAbbreviation(date.month)}',
        'amount': 8000.0 + (i * 500),
        'date': date.toIso8601String(),
        'dateMillis': date.millisecondsSinceEpoch,
        'isIncome': 1,
        'category': 'Vendas',
        'store_id': 1,
      });

      // Saída
      await db.insert(tableTransactions, {
        'description': 'Despesas ${_getMonthAbbreviation(date.month)}',
        'amount': 4000.0 + (i * 300),
        'date': date.toIso8601String(),
        'dateMillis': date.millisecondsSinceEpoch,
        'isIncome': 0,
        'category': 'Compras',
        'store_id': 1,
      });
    }
  }

  // ==================== MÉTODOS DE TRANSAÇÃO ====================

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert(
      tableTransactions,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TransactionModel>> getTransactions({bool? isIncome}) async {
    final db = await database;

    List<Map<String, dynamic>> maps;
    if (isIncome != null) {
      maps = await db.query(
        tableTransactions,
        where: 'isIncome = ?',
        whereArgs: [isIncome ? 1 : 0],
        orderBy: 'dateMillis DESC',
      );
    } else {
      maps = await db.query(tableTransactions, orderBy: 'dateMillis DESC');
    }

    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  Future<List<TransactionModel>> getTransactionsByPeriod(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;

    final startMillis = DateTime(
      start.year,
      start.month,
      start.day,
    ).millisecondsSinceEpoch;
    final endMillis = DateTime(
      end.year,
      end.month,
      end.day,
      23,
      59,
      59,
    ).millisecondsSinceEpoch;

    final List<Map<String, dynamic>> maps = await db.query(
      tableTransactions,
      where: 'dateMillis BETWEEN ? AND ?',
      whereArgs: [startMillis, endMillis],
      orderBy: 'dateMillis ASC',
    );

    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.update(
      tableTransactions,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(tableTransactions, where: 'id = ?', whereArgs: [id]);
  }

  // ==================== MÉTODOS DE CATEGORIA ====================

  Future<int> insertCategory(CategoryModel category) async {
    final db = await database;
    return await db.insert(
      tableCategories,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CategoryModel>> getCategories({bool? isIncome}) async {
    final db = await database;

    List<Map<String, dynamic>> maps;
    if (isIncome != null) {
      maps = await db.query(
        tableCategories,
        where: 'isIncome = ?',
        whereArgs: [isIncome ? 1 : 0],
        orderBy: 'name ASC',
      );
    } else {
      maps = await db.query(tableCategories, orderBy: 'name ASC');
    }

    return List.generate(maps.length, (i) => CategoryModel.fromMap(maps[i]));
  }

  Future<CategoryModel?> getCategoryById(int id) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return CategoryModel.fromMap(maps.first);
    }
    return null;
  }

  Future<CategoryModel?> getCategoryByName(String name) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      tableCategories,
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return CategoryModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateCategory(CategoryModel category) async {
    final db = await database;
    return await db.update(
      tableCategories,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(tableCategories, where: 'id = ?', whereArgs: [id]);
  }

  // ==================== MÉTODOS DE ESTATÍSTICAS ====================

  Future<Map<String, Map<String, double>>> getWeeklyStats() async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final transactions = await getTransactionsByPeriod(
      firstDayOfMonth,
      lastDayOfMonth,
    );

    Map<String, Map<String, double>> weeklyStats = {};

    for (var transaction in transactions) {
      int weekOfMonth = ((transaction.date.day - 1) ~/ 7) + 1;
      String weekKey = 'Semana $weekOfMonth';

      if (!weeklyStats.containsKey(weekKey)) {
        weeklyStats[weekKey] = {'incomes': 0.0, 'expenses': 0.0};
      }

      if (transaction.isIncome) {
        weeklyStats[weekKey]!['incomes'] =
            (weeklyStats[weekKey]!['incomes'] ?? 0) + transaction.amount;
      } else {
        weeklyStats[weekKey]!['expenses'] =
            (weeklyStats[weekKey]!['expenses'] ?? 0) + transaction.amount;
      }
    }

    // Ordenar por semana
    final sortedStats = <String, Map<String, double>>{};
    for (int i = 1; i <= 5; i++) {
      String weekKey = 'Semana $i';
      if (weeklyStats.containsKey(weekKey)) {
        sortedStats[weekKey] = weeklyStats[weekKey]!;
      }
    }

    return sortedStats;
  }

  Future<Map<String, Map<String, double>>> getMonthlyStats() async {
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);

    final transactions = await getTransactionsByPeriod(sixMonthsAgo, now);

    Map<String, Map<String, double>> monthlyStats = {};

    for (var transaction in transactions) {
      String monthKey = _getMonthAbbreviation(transaction.date.month);

      if (!monthlyStats.containsKey(monthKey)) {
        monthlyStats[monthKey] = {'incomes': 0.0, 'expenses': 0.0};
      }

      if (transaction.isIncome) {
        monthlyStats[monthKey]!['incomes'] =
            (monthlyStats[monthKey]!['incomes'] ?? 0) + transaction.amount;
      } else {
        monthlyStats[monthKey]!['expenses'] =
            (monthlyStats[monthKey]!['expenses'] ?? 0) + transaction.amount;
      }
    }

    // Ordenar por mês
    final Map<String, Map<String, double>> sortedStats = {};
    final months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];

    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i);
      final monthKey = _getMonthAbbreviation(date.month);

      if (monthlyStats.containsKey(monthKey)) {
        sortedStats[monthKey] = monthlyStats[monthKey]!;
      } else {
        sortedStats[monthKey] = {'incomes': 0.0, 'expenses': 0.0};
      }
    }

    return sortedStats;
  }

  Future<Map<String, double>> getTotalStats() async {
    final db = await database;

    final incomesResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM $tableTransactions WHERE isIncome = 1',
    );
    final expensesResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM $tableTransactions WHERE isIncome = 0',
    );

    final double totalIncomes =
        (incomesResult.first['total'] as num?)?.toDouble() ?? 0.0;
    final double totalExpenses =
        (expensesResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return {
      'incomes': totalIncomes,
      'expenses': totalExpenses,
      'balance': totalIncomes - totalExpenses,
    };
  }

  Future<double> getTotalBalance() async {
    final stats = await getTotalStats();
    return stats['balance'] ?? 0;
  }

  Future<double> getCurrentBalance() async {
    final now = DateTime.now();
    final thirtyDaysAgo = DateTime(now.year, now.month, now.day - 29);
    final transactions = await getTransactionsByPeriod(thirtyDaysAgo, now);

    double balance = 0;
    for (var transaction in transactions) {
      if (transaction.isIncome) {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }
    return balance;
  }

  Future<double> getRecentIncomes() async {
    final now = DateTime.now();
    final thirtyDaysAgo = DateTime(now.year, now.month, now.day - 29);
    final transactions = await getTransactionsByPeriod(thirtyDaysAgo, now);

    double incomes = 0;
    for (var transaction in transactions) {
      if (transaction.isIncome) {
        incomes += transaction.amount;
      }
    }
    return incomes;
  }

  Future<double> getRecentExpenses() async {
    final now = DateTime.now();
    final thirtyDaysAgo = DateTime(now.year, now.month, now.day - 29);
    final transactions = await getTransactionsByPeriod(thirtyDaysAgo, now);

    double expenses = 0;
    for (var transaction in transactions) {
      if (!transaction.isIncome) {
        expenses += transaction.amount;
      }
    }
    return expenses;
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    return months[month - 1];
  }
}
