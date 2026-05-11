import 'package:flutter/material.dart';
import '../database/crud/category_crud.dart';
import '../database/models/category_model.dart';
import '../core/theme/app_colors.dart';

class FormCategoryScreen extends StatefulWidget {
  final CategoryModel? category;

  const FormCategoryScreen({super.key, this.category});

  @override
  State<FormCategoryScreen> createState() => _FormCategoryScreenState();
}

class _FormCategoryScreenState extends State<FormCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _selectedTypeIndex = 0; // 0 para Entrada, 1 para Saída
  String _selectedIcon = '💰'; // Ícone padrão
  String _selectedColor = '#4CAF50'; // Cor padrão

  // Lista de ícones disponíveis
  final List<String> _availableIcons = [
    '💰',
    '💵',
    '📦',
    '🛒',
    '🏠',
    '👥',
    '📢',
    '⚙️',
    '🔧',
    '📈',
    '📉',
    '💻',
    '📱',
    '🎯',
    '⭐',
    '❤️',
    '🎨',
    '🏪',
    '🚗',
    '✈️',
    '🎓',
    '💊',
    '🍔',
    '👕',
  ];

  // Cores disponíveis
  final List<Map<String, String>> _availableColors = [
    {'name': 'Verde', 'code': '#4CAF50'},
    {'name': 'Vermelho', 'code': '#F44336'},
    {'name': 'Azul', 'code': '#2196F3'},
    {'name': 'Laranja', 'code': '#FF9800'},
    {'name': 'Roxo', 'code': '#9C27B0'},
    {'name': 'Rosa', 'code': '#E91E63'},
    {'name': 'Ciano', 'code': '#00BCD4'},
    {'name': 'Amarelo', 'code': '#FFC107'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedTypeIndex = widget.category!.isIncome ? 0 : 1;
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final bool isIncome = _selectedTypeIndex == 0;

      final category = CategoryModel(
        name: name,
        icon: _selectedIcon,
        color: _selectedColor,
        isIncome: isIncome,
        id: widget.category?.id,
      );

      try {
        if (widget.category == null) {
          await CategoryCrud().insertCategory(category);
        } else {
          await CategoryCrud().updateCategory(category);
        }

        if (mounted) {
          Navigator.pop(context, true); // Retorna true para indicar sucesso
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar categoria: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category == null ? 'Nova Categoria' : 'Editar Categoria',
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tipo de categoria (Entrada/Saída)
              Text(
                'Tipo de Categoria',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('💰 Entrada')),
                  ButtonSegment(value: 1, label: Text('📉 Saída')),
                ],
                selected: {_selectedTypeIndex},
                onSelectionChanged: (Set<int> selection) {
                  setState(() {
                    _selectedTypeIndex = selection.first;
                    // Resetar ícone e cor padrão baseado no tipo
                    if (_selectedTypeIndex == 0) {
                      _selectedIcon = '💰';
                      _selectedColor = '#4CAF50';
                    } else {
                      _selectedIcon = '📉';
                      _selectedColor = '#F44336';
                    }
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primaryGreen;
                    }
                    return Colors.grey[200];
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return Colors.grey[700];
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // Nome da categoria
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Categoria',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite o nome da categoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Seleção de Ícone
              Text(
                'Escolha um Ícone',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 100,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: _availableIcons.length,
                  itemBuilder: (context, index) {
                    final icon = _availableIcons[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIcon = icon;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedIcon == icon
                              ? AppColors.primaryGreen.withOpacity(0.2)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedIcon == icon
                                ? AppColors.primaryGreen
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            icon,
                            style: TextStyle(
                              fontSize: 28,
                              color: _selectedIcon == icon
                                  ? AppColors.primaryGreen
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Seleção de Cor
              Text(
                'Escolha uma Cor',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableColors.map((color) {
                  final isSelected = _selectedColor == color['code'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color['code']!;
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(
                              int.parse(
                                    color['code']!.substring(1),
                                    radix: 16,
                                  ) +
                                  0xFF000000,
                            ),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 3)
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          color['name']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Preview da categoria
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(_selectedColor.substring(1), radix: 16) +
                              0xFF000000,
                        ).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _selectedIcon,
                          style: TextStyle(
                            fontSize: 32,
                            color: Color(
                              int.parse(
                                    _selectedColor.substring(1),
                                    radix: 16,
                                  ) +
                                  0xFF000000,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preview da Categoria',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _nameController.text.isEmpty
                                ? 'Nome da Categoria'
                                : _nameController.text,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _selectedTypeIndex == 0 ? 'Entrada' : 'Saída',
                            style: TextStyle(
                              fontSize: 14,
                              color: _selectedTypeIndex == 0
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primaryGreen),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveCategory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
