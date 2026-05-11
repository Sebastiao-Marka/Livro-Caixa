import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CategoryTile extends StatelessWidget {
  final String title;
  final bool isIncome;
  final VoidCallback onDelete;

  const CategoryTile({
    super.key,
    required this.title,
    required this.isIncome,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final Color dotColor = isIncome
        ? AppColors.iconGreen
        : AppColors.primaryRed;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(
                Icons.delete_outline,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
