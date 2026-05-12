import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('App boots', (WidgetTester tester) async {
    await tester.pumpWidget(const Lab6App());
    await tester.pump();
    expect(find.byType(Lab6App), findsOneWidget);
  });
}
