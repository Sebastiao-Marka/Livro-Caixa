import 'package:flutter_test/flutter_test.dart';
import 'package:livro_caixa/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LivroCaixaApp());
    expect(find.text('Livro Caixa'), findsNothing);
  });
}
