import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/core/providers/session_provider.dart';
import 'package:rehberlik_app/features/classes/domain/school_class.dart';
import 'package:rehberlik_app/features/classes/domain/student_risk_question.dart';
import 'package:rehberlik_app/features/classes/presentation/class_risk_map_overview_page.dart';
import 'package:rehberlik_app/features/classes/presentation/student_risk_provider.dart';
import 'package:rehberlik_app/features/students/domain/student.dart';
import 'package:rehberlik_app/features/students/presentation/students_provider.dart';

void main() {
  testWidgets('görünüm öğrenci kimlik bilgilerini ve işaretli evetleri gösterir', (
    tester,
  ) async {
    const schoolClass = SchoolClass(
      id: 5,
      gradeLevelId: 1,
      gradeLevelLabel: '9. Sınıf',
      branch: 'A',
    );
    const student = Student(
      id: 12,
      classId: 5,
      number: '104',
      name: 'Elif',
      surname: 'Yılmaz',
      createdAt: '2026-11-10',
      siblingCount: 0,
    );
    final answers = {
      student.id: {
        for (final question in studentRiskManualQuestions) question.key: false,
        'parents_separated': true,
      },
    };

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(null),
          studentsProvider.overrideWith(() => _OverviewStudents([student])),
          studentRiskProvider.overrideWith(
            () => _OverviewAnswers(answers),
          ),
        ],
        child: const MaterialApp(
          home: ClassRiskMapOverviewPage(schoolClass: schoolClass),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sıra'), findsOneWidget);
    expect(find.text('Okul No'), findsOneWidget);
    expect(find.text('Ad Soyad'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('104'), findsOneWidget);
    expect(find.text('Elif Yılmaz'), findsOneWidget);
    expect(
      find.byKey(const Key('class_risk_view_12_parents_separated')),
      findsOneWidget,
    );
    expect(
      tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const Key('class_risk_view_12_parents_separated')),
          matching: find.byIcon(Icons.check_circle_rounded),
        ),
      ).color,
      isNotNull,
    );

    await tester.tap(find.byKey(const Key('edit_class_risk_map')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('risk_map_next')), findsOneWidget);
  });
}

class _OverviewStudents extends StudentsNotifier {
  _OverviewStudents(this.students);

  final List<Student> students;

  @override
  Future<List<Student>> build() async => students;
}

class _OverviewAnswers extends StudentRiskNotifier {
  _OverviewAnswers(this.answers);

  final StudentRiskAnswers answers;

  @override
  Future<StudentRiskAnswers> build(int classId) async => answers;
}
