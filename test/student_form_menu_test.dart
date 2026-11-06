import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/features/students/presentation/widgets/student_form_menu.dart';

void main() {
  testWidgets('form menüsü öğrenci bilgi formu seçeneğini gösterir', (
    tester,
  ) async {
    StudentFormAction? selectedAction;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StudentFormMenu(
            onSelected: (action) => selectedAction = action,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Öğrenci formu aç'));
    await tester.pumpAndSettle();

    expect(find.text('Öğrenci Bilgi Formu'), findsOneWidget);

    await tester.tap(find.text('Öğrenci Bilgi Formu'));
    await tester.pumpAndSettle();

    expect(selectedAction, StudentFormAction.studentInfo);
  });
}
