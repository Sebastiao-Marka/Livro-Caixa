import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../database/models/category_model.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final CategoryModel? value;
  final List<CategoryModel> items;
  final ValueChanged<CategoryModel?> onChanged;
  final String? Function(CategoryModel?)? validator;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<CategoryModel>(
            value: value, // ignore: deprecated_member_use
            items: items.map((CategoryModel category) {
              return DropdownMenuItem<CategoryModel>(
                value: category,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: onChanged,
            validator: validator,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryGreen,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryRed),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
