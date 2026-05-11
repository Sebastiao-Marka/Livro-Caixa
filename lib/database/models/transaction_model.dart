class TransactionModel {
  final int? id;
  final String description;
  final double amount;
  final DateTime date;
  final bool isIncome; // true = entrada, false = saída
  final String category;
  final int? storeId;

  TransactionModel({
    this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.category,
    this.storeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'dateMillis': date.millisecondsSinceEpoch, // Adicionado para ordenação
      'isIncome': isIncome ? 1 : 0,
      'category': category,
      'store_id': storeId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      description: map['description'],
      amount: map['amount'].toDouble(),
      date: map['date'] != null
          ? DateTime.parse(map['date'])
          : DateTime.fromMillisecondsSinceEpoch(map['dateMillis']),
      isIncome: map['isIncome'] == 1,
      category: map['category'],
      storeId: map['store_id'],
    );
  }
}
