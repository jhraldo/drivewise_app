import 'package:flutter_test/flutter_test.dart';

import 'package:drivewise_app/main.dart';

void main() {
  testWidgets('DriveWise inicia correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('DriveWise'), findsOneWidget);
  });
}