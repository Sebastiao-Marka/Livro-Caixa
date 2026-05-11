import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/segmented_control.dart';
import '../widgets/summary_cards.dart';
import '../core/routes/app_routes.dart';
import '../database/database_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  int _selectedPeriodIndex = 0; // 0 para Semanal, 1 para Mensal
  bool _isLoading = true;

  List<Map<String, dynamic>> _weeklyData = [];
  List<Map<String, dynamic>> _monthlyData = [];

  // Dados do CurrentBalanceCard (últimos 30 dias)
  double _currentBalance = 0;
  double _recentIncomes = 0;
  double _recentExpenses = 0;

  // Dados do MonthlySummaryCard (mês atual)
  double _currentMonthIncomes = 0;
  double _currentMonthExpenses = 0;
  double _currentMonthBalance = 0;

  // Dados totais (opcional)
  double _totalIncomes = 0;
  double _totalExpenses = 0;
  double _totalBalance = 0;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Recarregar quando o app voltar para primeiro plano
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recarregar se o widget for atualizado
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        _loadWeeklyData(),
        _loadMonthlyData(),
        _loadCurrentBalanceStats(),
        _loadCurrentMonthStats(),
        _loadTotalStats(),
      ]);
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCurrentBalanceStats() async {
    final currentBalance = await _dbHelper.getCurrentBalance();
    final recentIncomes = await _dbHelper.getRecentIncomes();
    final recentExpenses = await _dbHelper.getRecentExpenses();

    if (mounted) {
      setState(() {
        _currentBalance = currentBalance;
        _recentIncomes = recentIncomes;
        _recentExpenses = recentExpenses;
      });
    }
  }

  Future<void> _loadCurrentMonthStats() async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final transactions = await _dbHelper.getTransactionsByPeriod(
      firstDayOfMonth,
      lastDayOfMonth,
    );

    double incomes = 0;
    double expenses = 0;

    for (var transaction in transactions) {
      if (transaction.isIncome) {
        incomes += transaction.amount;
      } else {
        expenses += transaction.amount;
      }
    }

    if (mounted) {
      setState(() {
        _currentMonthIncomes = incomes;
        _currentMonthExpenses = expenses;
        _currentMonthBalance = incomes - expenses;
      });
    }
  }

  Future<void> _loadTotalStats() async {
    final totalStats = await _dbHelper.getTotalStats();

    if (mounted) {
      setState(() {
        _totalIncomes = totalStats['incomes'] ?? 0;
        _totalExpenses = totalStats['expenses'] ?? 0;
        _totalBalance = totalStats['balance'] ?? 0;
      });
    }
  }

  Future<void> _loadWeeklyData() async {
    final weeklyStats = await _dbHelper.getWeeklyStats();

    final List<Map<String, dynamic>> weeklyList = [];
    weeklyStats.forEach((week, values) {
      weeklyList.add({
        'week': week,
        'incomes': values['incomes'] ?? 0,
        'expenses': values['expenses'] ?? 0,
      });
    });

    if (mounted) {
      setState(() {
        _weeklyData = weeklyList;
      });
    }
  }

  Future<void> _loadMonthlyData() async {
    final monthlyStats = await _dbHelper.getMonthlyStats();

    final List<Map<String, dynamic>> monthlyList = [];
    monthlyStats.forEach((month, values) {
      monthlyList.add({
        'month': month,
        'incomes': values['incomes'] ?? 0,
        'expenses': values['expenses'] ?? 0,
      });
    });

    if (mounted) {
      setState(() {
        _monthlyData = monthlyList;
      });
    }
  }

  BarChartGroupData _buildBarGroup(int x, double incomes, double expenses) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: incomes,
          colors: [AppColors.primaryGreen],
          width: 12,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          y: expenses,
          colors: [AppColors.primaryRed],
          width: 12,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
      barsSpace: 8,
    );
  }

  List<BarChartGroupData> _buildChartData() {
    final data = _selectedPeriodIndex == 0 ? _weeklyData : _monthlyData;
    if (data.isEmpty) return [];

    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return _buildBarGroup(index, item['incomes'], item['expenses']);
    }).toList();
  }

  double _getMaxYValue() {
    final data = _selectedPeriodIndex == 0 ? _weeklyData : _monthlyData;
    if (data.isEmpty) return 1000;

    double maxValue = 0;
    for (var item in data) {
      if (item['incomes'] > maxValue) maxValue = item['incomes'];
      if (item['expenses'] > maxValue) maxValue = item['expenses'];
    }

    return maxValue * 1.1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              )
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomAppBar(
                        title: 'Olá, Lojista',
                        subtitle: 'Resumo do seu caixa',
                        trailing: GestureDetector(
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              AppRoutes.formTransaction,
                              arguments: true,
                            );
                            // Recarregar quando voltar da transação
                            if (result == true) {
                              await _loadData();
                            }
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: AppColors.lightGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: AppColors.primaryGreen,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: CustomSegmentedControl(
                          options: const ['Semanal', 'Mensal'],
                          selectedIndex: _selectedPeriodIndex,
                          onValueChanged: (index) {
                            setState(() {
                              _selectedPeriodIndex = index;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Card com saldo atual (últimos 30 dias)
                      CurrentBalanceCard(
                        balance: _currentBalance,
                        incomes: _recentIncomes,
                        expenses: _recentExpenses,
                      ),

                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.pushNamed(
                                    context,
                                    AppRoutes.formTransaction,
                                    arguments: true,
                                  );
                                  if (result == true) {
                                    await _loadData();
                                  }
                                },
                                icon: const Icon(Icons.arrow_downward),
                                label: const Text('Entrada'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.pushNamed(
                                    context,
                                    AppRoutes.formTransaction,
                                    arguments: false,
                                  );
                                  if (result == true) {
                                    await _loadData();
                                  }
                                },
                                icon: const Icon(Icons.arrow_upward),
                                label: const Text('Saída'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryRed,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Card com resumo do mês atual
                      MonthlySummaryCard(
                        incomes: _currentMonthIncomes,
                        expenses: _currentMonthExpenses,
                        balance: _currentMonthBalance,
                      ),

                      const SizedBox(height: 24),

                      // GRÁFICO DE BARRAS
                      if ((_selectedPeriodIndex == 0 &&
                              _weeklyData.isNotEmpty) ||
                          (_selectedPeriodIndex == 1 &&
                              _monthlyData.isNotEmpty))
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedPeriodIndex == 0
                                          ? '📊 Evolução Semanal'
                                          : '📈 Evolução Mensal',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryGreen,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'Entradas',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryRed,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'Saídas',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 300,
                                  child: BarChart(
                                    BarChartData(
                                      barGroups: _buildChartData(),
                                      maxY: _getMaxYValue(),
                                      minY: 0,
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: _getMaxYValue() / 5,
                                        getDrawingHorizontalLine: (value) {
                                          return FlLine(
                                            color: Colors.grey.withOpacity(0.2),
                                            strokeWidth: 1,
                                          );
                                        },
                                      ),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        bottomTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 32,
                                          getTitles: (double value) {
                                            final data =
                                                _selectedPeriodIndex == 0
                                                ? _weeklyData
                                                : _monthlyData;
                                            final index = value.toInt();
                                            if (index >= 0 &&
                                                index < data.length) {
                                              return _selectedPeriodIndex == 0
                                                  ? data[index]['week']
                                                        .toString()
                                                        .substring(0, 3)
                                                  : data[index]['month']
                                                        .toString();
                                            }
                                            return '';
                                          },
                                          getTextStyles: (context, value) =>
                                              TextStyle(
                                                color: AppColors.textLight,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                          margin: 8,
                                        ),
                                        leftTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 48,
                                          getTitles: (double value) {
                                            if (value == 0) return '';
                                            if (value >= 1000) {
                                              return '${(value / 1000).toStringAsFixed(0)}k';
                                            }
                                            return value.toInt().toString();
                                          },
                                          getTextStyles: (context, value) =>
                                              TextStyle(
                                                color: AppColors.textLight,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                          margin: 8,
                                          interval: _getMaxYValue() / 5,
                                        ),
                                        topTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                        rightTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      barTouchData: BarTouchData(
                                        touchTooltipData: BarTouchTooltipData(
                                          tooltipBgColor: Colors.grey[800],
                                          tooltipMargin: 8,
                                          getTooltipItem:
                                              (
                                                BarChartGroupData group,
                                                int groupIndex,
                                                BarChartRodData rod,
                                                int rodIndex,
                                              ) {
                                                return BarTooltipItem(
                                                  '${rodIndex == 0 ? "Entrada" : "Saída"}: R\$ ${rod.y.toStringAsFixed(2)}',
                                                  TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildPeriodSummary(
                                        'Total Entradas',
                                        _selectedPeriodIndex == 0
                                            ? _weeklyData.fold(
                                                0.0,
                                                (sum, item) =>
                                                    sum + item['incomes'],
                                              )
                                            : _monthlyData.fold(
                                                0.0,
                                                (sum, item) =>
                                                    sum + item['incomes'],
                                              ),
                                        AppColors.primaryGreen,
                                      ),
                                      Container(
                                        width: 1,
                                        height: 30,
                                        color: Colors.grey.withOpacity(0.3),
                                      ),
                                      _buildPeriodSummary(
                                        'Total Saídas',
                                        _selectedPeriodIndex == 0
                                            ? _weeklyData.fold(
                                                0.0,
                                                (sum, item) =>
                                                    sum + item['expenses'],
                                              )
                                            : _monthlyData.fold(
                                                0.0,
                                                (sum, item) =>
                                                    sum + item['expenses'],
                                              ),
                                        AppColors.primaryRed,
                                      ),
                                      Container(
                                        width: 1,
                                        height: 30,
                                        color: Colors.grey.withOpacity(0.3),
                                      ),
                                      _buildPeriodSummary(
                                        'Saldo',
                                        _selectedPeriodIndex == 0
                                            ? (_weeklyData.fold(
                                                    0.0,
                                                    (sum, item) =>
                                                        sum + item['incomes'],
                                                  ) -
                                                  _weeklyData.fold(
                                                    0.0,
                                                    (sum, item) =>
                                                        sum + item['expenses'],
                                                  ))
                                            : (_monthlyData.fold(
                                                    0.0,
                                                    (sum, item) =>
                                                        sum + item['incomes'],
                                                  ) -
                                                  _monthlyData.fold(
                                                    0.0,
                                                    (sum, item) =>
                                                        sum + item['expenses'],
                                                  )),
                                        AppColors.primaryBlue,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.bar_chart,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhum dado disponível\nAdicione suas primeiras transações',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildPeriodSummary(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textLight)),
        const SizedBox(height: 4),
        Text(
          'R\$ ${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
