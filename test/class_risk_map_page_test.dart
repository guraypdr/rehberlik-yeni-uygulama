import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/core/providers/session_provider.dart';
import 'package:rehberlik_app/features/classes/domain/school_class.dart';
import 'package:rehberlik_app/features/classes/domain/student_risk_question.dart';
import 'package:rehberlik_app/features/classes/presentation/class_risk_map_page.dart';
import 'package:rehberlik_app/features/classes/presentation/student_risk_provider.dart';
import 'package:rehberlik_app/features/students/domain/student.dart';
import 'package:rehberlik_app/features/students/presentation/students_provider.dart';

void main() {
  testWidgets('sorular arasında ilerler ve işaretleri otomatik kaydeder', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
      motherEducation: 'İlkokul',
      fatherEducation: 'Lise',
      siblingCount: 0,
    );
    final initialAnswers = {
      student.id: {
        for (final question in studentRiskManualQuestions) question.key: false,
      },
    };

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(null),
          studentsProvider.overrideWith(() => _RiskMapStudents([student])),
          studentRiskProvider.overrideWith(
            () => _RiskMapAnswers(initialAnswers),
          ),
        ],
        child: const MaterialApp(
          home: ClassRiskMapPage(schoolClass: schoolClass),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final formRect = tester.getRect(
      find.byKey(const Key('risk_map_form_container')),
    );
    expect(formRect.width, lessThanOrEqualTo(1100));
    expect(formRect.center.dx, closeTo(800, 1));

    expect(find.text('Anne en fazla ilkokul mezunu'), findsWidgets);
    expect(
      tester
          .widget<Checkbox>(
            find.byKey(const Key('risk_answer_12_mother_low_education')),
          )
          .value,
      isTrue,
    );

    await tester.tap(find.byKey(const Key('risk_map_next')));
    await tester.pumpAndSettle();
    expect(find.text('Baba en fazla ilkokul mezunu'), findsWidgets);

    await tester.tap(find.byKey(const Key('risk_map_next')));
    await tester.pumpAndSettle();
    expect(find.text('Tek çocuk olan'), findsWidgets);

    await tester.tap(find.byKey(const Key('risk_map_next')));
    await tester.pumpAndSettle();
    expect(find.text('5 ve üstü kardeşi olan'), findsWidgets);

    await tester.tap(find.byKey(const Key('risk_map_next')));
    await tester.pumpAndSettle();
    expect(find.text('Anne ve babası ayrı yaşayan'), findsWidgets);

    final checkbox = find.byKey(const Key('risk_answer_12_parents_separated'));
    await tester.tap(checkbox);
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(checkbox).value, isTrue);

    await tester.tap(find.byKey(const Key('risk_map_previous')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('risk_map_next')));
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(checkbox).value, isTrue);
  });
}

class _RiskMapStudents extends StudentsNotifier {
  _RiskMapStudents(this.students);

  final List<Student> students;

  @override
  Future<List<Student>> build() async => students;
}

class _RiskMapAnswers extends StudentRiskNotifier {
  _RiskMapAnswers(this.answers);

  final StudentRiskAnswers answers;

  @override
  Future<StudentRiskAnswers> build(int classId) async => answers;

  @override
  Future<void> setAnswer({
    required int studentId,
    required String questionKey,
    required bool answer,
  }) async {
    final current = state.valueOrNull ?? answers;
    state = AsyncValue.data({
      ...current,
      studentId: {
        ...current[studentId] ?? const <String, bool>{},
        questionKey: answer,
      },
    });
  }
}
