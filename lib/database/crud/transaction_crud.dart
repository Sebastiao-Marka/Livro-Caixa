import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/transaction_model.dart';

class TransactionCrud {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Insert a new transaction
  Future<int> insertTransaction(TransactionModel transaction) async {
    try {
      final db = await _dbHelper.database;
      return await db.insert(
        DatabaseHelper.tableTransactions,
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Erro ao inserir transação: $e');
      return -1;
    }
  }

  // Get all transactions, ordered by date descending
  Future<List<TransactionModel>> getTransactions({bool? isIncome}) async {
    try {
      return await _dbHelper.getTransactions(isIncome: isIncome);
    } catch (e) {
      print('Erro ao buscar transações: $e');
      return [];
    }
  }

  // Get total balance (Incomes - Expenses)
  Future<double> getTotalBalance() async {
    try {
      return await _dbHelper.getTotalBalance();
    } catch (e) {
      print('Erro ao calcular saldo total: $e');
      return 0.0;
    }
  }

  // Update a transaction
  Future<int> updateTransaction(TransactionModel transaction) async {
    try {
      return await _dbHelper.updateTransaction(transaction);
    } catch (e) {
      print('Erro ao atualizar transação: $e');
      return -1;
    }
  }

  // Delete a transaction
  Future<int> deleteTransaction(int id) async {
    try {
      return await _dbHelper.deleteTransaction(id);
    } catch (e) {
      print('Erro ao deletar transação: $e');
      return -1;
    }
  }

  // Get weekly stats
  Future<Map<String, Map<String, double>>> getWeeklyStats() async {
    try {
      return await _dbHelper.getWeeklyStats();
    } catch (e) {
      print('Erro ao buscar estatísticas semanais: $e');
      return {};
    }
  }

  // Get monthly stats
  Future<Map<String, Map<String, double>>> getMonthlyStats() async {
    try {
      return await _dbHelper.getMonthlyStats();
    } catch (e) {
      print('Erro ao buscar estatísticas mensais: $e');
      return {};
    }
  }
}
