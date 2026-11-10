import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/core/providers/session_provider.dart';
import 'package:rehberlik_app/features/classes/domain/school_class.dart';
import 'package:rehberlik_app/features/classes/presentation/class_dashboard_page.dart';
import 'package:rehberlik_app/features/classes/presentation/widgets/class_card.dart';
import 'package:rehberlik_app/features/students/domain/student.dart';
import 'package:rehberlik_app/features/students/presentation/students_provider.dart';
import 'package:rehberlik_app/features/teachers/domain/teacher.dart';
import 'package:rehberlik_app/features/teachers/presentation/teachers_provider.dart';

void main() {
  testWidgets('sınıf kartına tıklayınca sınıf profiline gider', (tester) async {
    const schoolClass = SchoolClass(
      id: 1,
      gradeLevelId: 1,
      gradeLevelLabel: '9. Sınıf',
      branch: 'A',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(null)],
        child: const MaterialApp(
          home: Scaffold(
            body: ClassCard(schoolClass: schoolClass, gradeLevels: []),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('class_open_1')));
    await tester.pumpAndSettle();

    expect(find.text('9/A'), findsOneWidget);
  });

  testWidgets(
    'sınıf profili öğrenci özetini gösterip öğrenci profiline gider',
    (tester) async {
      const schoolClass = SchoolClass(
        id: 1,
        gradeLevelId: 1,
        gradeLevelLabel: '9. Sınıf',
        branch: 'A',
        teacherId: 4,
      );
      const student = Student(
        id: 10,
        classId: 1,
        number: '101',
        name: 'Ayşe',
        surname: 'Kaya',
        gender: 'Kız',
        createdAt: '2026-11-10',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(null),
            studentsProvider.overrideWith(
              () => _FakeStudentsNotifier([student]),
            ),
            teachersProvider.overrideWith(
              () => _FakeTeachersNotifier([
                const Teacher(id: 4, name: 'Fatma', surname: 'Yılmaz'),
              ]),
            ),
          ],
          child: const MaterialApp(
            home: ClassDashboardPage(schoolClass: schoolClass),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Öğrenci Sayısı'), findsOneWidget);
      expect(find.text('1'), findsNWidgets(2));
      expect(find.text('Kız Öğrenci'), findsOneWidget);
      expect(find.text('Erkek Öğrenci'), findsOneWidget);
      expect(find.text('Fatma Yılmaz'), findsOneWidget);
      expect(find.text('101 · Ayşe Kaya'), findsOneWidget);

      await tester.tap(find.byKey(const Key('open_class_risk_map')));
      await tester.pumpAndSettle();
      expect(find.text('Sınıf Risk Haritası · 9/A'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('class_student_10')));
      await tester.pumpAndSettle();

      expect(find.text('Öğrenci Profili'), findsOneWidget);
    },
  );
}

class _FakeStudentsNotifier extends StudentsNotifier {
  _FakeStudentsNotifier(this.students);

  final List<Student> students;

  @override
  Future<List<Student>> build() async => students;
}

class _FakeTeachersNotifier extends TeachersNotifier {
  _FakeTeachersNotifier(this.teachers);

  final List<Teacher> teachers;

  @override
  Future<List<Teacher>> build() async => teachers;
}
