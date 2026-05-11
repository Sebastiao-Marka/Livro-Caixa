class CategoryModel {
  final int? id;
  final String name;
  final String icon;
  final String color;
  final bool isIncome;

  CategoryModel({
    this.id,
    required this.name,
    this.icon = '💰', // Valor padrão
    this.color = '#4CAF50', // Valor padrão
    required this.isIncome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'isIncome': isIncome ? 1 : 0,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      icon: map['icon'] ?? '💰',
      color: map['color'] ?? '#4CAF50',
      isIncome: map['isIncome'] == 1,
    );
  }
}
