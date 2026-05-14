import 'package:flutter_test/flutter_test.dart';

import 'package:attendance_and_operations/main.dart';

void main() {
  testWidgets('actor selection smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AttendanceApp());
    await tester.pumpAndSettle();

    expect(find.text('SAMS 2026'), findsOneWidget);
    expect(find.text('Attendance & Operations'), findsOneWidget);
    expect(find.text('Lecturer'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
  });
}
