import 'package:ascend/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('la app arranca sin errores', (tester) async {
    await tester.pumpWidget(const MainApp());
    expect(find.byType(MainApp), findsOneWidget);
  });
}
