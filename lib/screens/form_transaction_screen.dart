import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/segmented_control.dart';
import '../widgets/forms/custom_text_field.dart';
import '../widgets/forms/custom_dropdown.dart';
import '../database/models/category_model.dart';
import '../database/models/transaction_model.dart';
import '../database/crud/transaction_crud.dart';
import '../database/crud/category_crud.dart';

class FormTransactionScreen extends StatefulWidget {
  final bool isIncomeInitial;

  const FormTransactionScreen({super.key, this.isIncomeInitial = true});

  @override
  State<FormTransactionScreen> createState() => _FormTransactionScreenState();
}

class _FormTransactionScreenState extends State<FormTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  late int _selectedTypeIndex;
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  List<CategoryModel> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _selectedTypeIndex = widget.isIncomeInitial ? 0 : 1;
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await CategoryCrud().getCategories();
    setState(() {
      _categories = categories;
      _isLoadingCategories = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      });
    }
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final String title = _titleController.text;
      final double amount =
          double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;
      final bool isIncome = _selectedTypeIndex == 0;
      final String category = _selectedCategory!.name;
      final DateTime date = _selectedDate;

      final transaction = TransactionModel(
        description: title,
        amount: amount,
        isIncome: isIncome,
        category: category,
        date: date,
      );

      await TransactionCrud().insertTransaction(transaction);

      if (mounted) {
        Navigator.pop(context, true); // Retorna true para indicar sucesso
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isIncome = _selectedTypeIndex == 0;
    final availableCategories = _categories
        .where((c) => c.isIncome == isIncome)
        .toList();

    // Reset selected category if type changes
    if (_selectedCategory != null && _selectedCategory!.isIncome != isIncome) {
      _selectedCategory = null;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Novo Lançamento',
              subtitle: 'Registre uma nova movimentação',
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomSegmentedControl(
                        options: const ['Entrada', 'Saída'],
                        selectedIndex: _selectedTypeIndex,
                        onValueChanged: (index) {
                          setState(() {
                            _selectedTypeIndex = index;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        label: 'Título',
                        controller: _titleController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, insira o título.';
                          }
                          return null;
                        },
                      ),
                      CustomTextField(
                        label: 'Valor (R\$)',
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, insira o valor.';
                          }
                          return null;
                        },
                      ),
                      if (_isLoadingCategories)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: CircularProgressIndicator(),
                        )
                      else
                        CustomDropdown(
                          label: 'Categoria',
                          value: _selectedCategory,
                          items: availableCategories,
                          onChanged: (CategoryModel? newValue) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Por favor, selecione uma categoria.';
                            }
                            return null;
                          },
                        ),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: CustomTextField(
                            label: 'Data',
                            controller: _dateController,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  child: const Text('SALVAR LANÇAMENTO'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
