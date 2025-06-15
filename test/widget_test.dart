// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_2/main.dart';

void main() {
  testWidgets('Pantalla de bienvenida aparece', (WidgetTester tester) async {
    // Construye la app principal.
    await tester.pumpWidget(const PanaderiaDeliciaApp());

    // Verifica que la pantalla de bienvenida contiene cierto texto.
    expect(find.text('¡Bienvenido de nuevo!'), findsWidgets); // Cambia el texto según tu WelcomeScreen
  });
}