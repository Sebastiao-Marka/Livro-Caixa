import 'package:flutter/material.dart';
import '../../screens/main_screen.dart';
import '../../screens/form_transaction_screen.dart';
import '../../screens/form_category_screen.dart';

class AppRoutes {
  static const String main = '/';
  static const String formTransaction = '/form-transaction';
  static const String formCategory = '/form-category';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case formTransaction:
        final isIncomeInitial = settings.arguments as bool? ?? true;
        return MaterialPageRoute(
          builder: (_) =>
              FormTransactionScreen(isIncomeInitial: isIncomeInitial),
        );
      case formCategory:
        return MaterialPageRoute(builder: (_) => const FormCategoryScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Erro')),
            body: Center(
              child: Text('Nenhuma rota definida para ${settings.name}'),
            ),
          ),
        );
    }
  }
}
