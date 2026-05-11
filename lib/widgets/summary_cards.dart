import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CurrentBalanceCard extends StatelessWidget {
  final double balance;
  final double incomes;
  final double expenses;

  const CurrentBalanceCard({
    super.key,
    required this.balance,
    required this.incomes,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SALDO ATUAL',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'R\$ ${balance.toStringAsFixed(2).replaceAll('.', ',')}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _MiniSummaryCard(
                    title: 'Entradas',
                    value: incomes,
                    isIncome: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniSummaryCard(
                    title: 'Saídas',
                    value: expenses,
                    isIncome: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniSummaryCard extends StatelessWidget {
  final String title;
  final double value;
  final bool isIncome;

  const _MiniSummaryCard({
    required this.title,
    required this.value,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = isIncome ? AppColors.iconGreen : AppColors.primaryRed;
    final valueColor = isIncome ? AppColors.primaryGreen : AppColors.primaryRed;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class MonthlySummaryCard extends StatelessWidget {
  final double incomes;
  final double expenses;
  final double balance;

  const MonthlySummaryCard({
    super.key,
    required this.incomes,
    required this.expenses,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Este mês',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SummaryColumn(
                  title: 'Entradas',
                  value: incomes,
                  valueColor: AppColors.primaryGreen,
                ),
                Container(width: 1, height: 30, color: AppColors.border),
                _SummaryColumn(
                  title: 'Saídas',
                  value: expenses,
                  valueColor: AppColors.primaryRed,
                ),
                Container(width: 1, height: 30, color: AppColors.border),
                _SummaryColumn(
                  title: 'Saldo',
                  value: balance,
                  valueColor: AppColors.textPrimary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final String title;
  final double value;
  final Color valueColor;

  const _SummaryColumn({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
