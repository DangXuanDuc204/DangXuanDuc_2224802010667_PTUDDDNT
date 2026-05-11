import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Hiển thị màn hình đăng nhập khi chưa có token', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const TodoJwtApp());
    await tester.pumpAndSettle();

    expect(find.text('Đăng nhập'), findsWidgets);
  });
}
