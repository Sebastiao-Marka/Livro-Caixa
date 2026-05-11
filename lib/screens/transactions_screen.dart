import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../database/crud/transaction_crud.dart';
import '../database/models/transaction_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/transaction_tile.dart';
import '../core/routes/app_routes.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _selectedFilter = 0; // 0: Todos, 1: Entradas, 2: Saídas
  final List<String> _filters = ['Todos', 'Entradas', 'Saídas'];

  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  final TransactionCrud _transactionCrud = TransactionCrud();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<TransactionModel> transactions;

      // Filtrar por tipo se necessário
      if (_selectedFilter == 1) {
        transactions = await _transactionCrud.getTransactions(isIncome: true);
      } else if (_selectedFilter == 2) {
        transactions = await _transactionCrud.getTransactions(isIncome: false);
      } else {
        transactions = await _transactionCrud.getTransactions();
      }

      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar transações: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar transações')),
        );
      }
    }
  }

  Future<void> _deleteTransaction(int id) async {
    try {
      await _transactionCrud.deleteTransaction(id);
      await _loadTransactions(); // Recarregar a lista

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transação removida com sucesso')),
        );
      }
    } catch (e) {
      print('Erro ao deletar transação: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao remover transação')),
        );
      }
    }
  }

  Future<void> _editTransaction(TransactionModel transaction) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.formTransaction,
      arguments: transaction, // Passa a transação para edição
    );

    if (result == true) {
      await _loadTransactions(); // Recarregar se editou
    }
  }

  // Agrupar transações por data
  Map<String, List<TransactionModel>> _groupTransactionsByDate() {
    final Map<String, List<TransactionModel>> grouped = {};

    for (var transaction in _transactions) {
      final dateKey = _formatDateKey(transaction.date);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    // Ordenar as datas decrescentemente
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final sortedGrouped = <String, List<TransactionModel>>{};
    for (var key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }

  String _formatDateKey(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Hoje, ${_formatDateKey(date)}';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Ontem, ${_formatDateKey(date)}';
    } else {
      return _formatDateKey(date);
    }
  }

  double _getTotalForDay(List<TransactionModel> transactions) {
    double total = 0;
    for (var transaction in transactions) {
      if (transaction.isIncome) {
        total += transaction.amount;
      } else {
        total -= transaction.amount;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Lançamentos',
              subtitle: 'Histórico do seu caixa',
              trailing: FloatingActionButton(
                mini: true,
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    AppRoutes.formTransaction,
                    arguments: _selectedFilter == 0 || _selectedFilter == 1,
                  );
                  if (result == true) {
                    await _loadTransactions();
                  }
                },
                elevation: 0,
                child: const Icon(Icons.add),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedFilter == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = index;
                        });
                        _loadTransactions(); // Recarregar com novo filtro
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryGreen
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          _filters[index],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    )
                  : _transactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma transação encontrada',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Toque no botão + para adicionar',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadTransactions,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        children: _buildTransactionsList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTransactionsList() {
    final groupedTransactions = _groupTransactionsByDate();
    final List<Widget> widgets = [];

    groupedTransactions.forEach((dateKey, transactions) {
      // Adicionar cabeçalho da data
      final date = transactions.first.date;
      final total = _getTotalForDay(transactions);
      final isPositive = total >= 0;

      widgets.add(
        _buildDateHeader(_formatDateHeader(date), total.abs(), isPositive),
      );

      // Adicionar transações do dia
      for (var transaction in transactions) {
        widgets.add(
          TransactionTile(
            title: transaction.description,
            value: transaction.amount,
            isIncome: transaction.isIncome,
            category: transaction.category,
            date: transaction.date,
            onTap: () => _editTransaction(transaction),
            onDelete: () => _showDeleteDialog(transaction.id!),
          ),
        );
      }

      widgets.add(const SizedBox(height: 16));
    });

    return widgets;
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: const Text('Tem certeza que deseja excluir esta transação?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteTransaction(id);
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(String date, double total, bool isPositive) {
    final formattedTotal =
        '${isPositive ? '+' : '-'}R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
    final textColor = isPositive
        ? AppColors.primaryGreen
        : AppColors.primaryRed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            formattedTotal,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
