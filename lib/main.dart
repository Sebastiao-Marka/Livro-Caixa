import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';

void main() {
  runApp(const LivroCaixaApp());
}

class LivroCaixaApp extends StatelessWidget {
  const LivroCaixaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Livro Caixa',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.main,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
    );
  }
}
