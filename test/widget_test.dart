import 'package:flutter_test/flutter_test.dart';

import 'package:pccc_app/app.dart';

void main() {
  testWidgets('Mở app: màn chờ chuyển sang màn đăng nhập', (tester) async {
    await tester.pumpWidget(const PcccApp());
    expect(find.text('PCCC & CNCH'), findsOneWidget);

    // Chờ màn chờ (1,2 giây) chạy xong rồi chuyển trang.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Đăng nhập'), findsWidgets);
  });
}
