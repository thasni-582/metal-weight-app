import 'package:flutter_test/flutter_test.dart';
import 'package:metal_weight/main.dart';

void main() {
  testWidgets('App launches to the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Milen Trading'), findsOneWidget);
  });
}
