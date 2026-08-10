import 'package:flutter_test/flutter_test.dart';
import 'package:playzone_mobile/main.dart';

void main() {
  testWidgets('Teste de fumaça da tela de login', (WidgetTester verificador) async {
    // Constrói nosso aplicativo e dispara um frame.
    await verificador.pumpWidget(const MeuAplicativo());

    // Verifica se o texto de boas-vindas do cabeçalho da tela de login está na tela.
    expect(find.text('Bem-vindo de volta!'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
