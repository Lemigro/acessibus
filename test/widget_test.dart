// This is a basic Flutter widget test.
//
// To perform an interaction with a widget, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:acessibus/main.dart';

void main() {
  testWidgets('App starts with welcome page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AcessibusApp());

    // Verify that the welcome page is displayed
    expect(find.text('Bem-vindo!'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Cadastrar-se'), findsOneWidget);
  });
}
