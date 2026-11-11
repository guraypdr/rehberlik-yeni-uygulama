import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/core/providers/session_provider.dart';
import 'package:rehberlik_app/features/classes/domain/school_class.dart';
import 'package:rehberlik_app/features/classes/presentation/class_dashboard_page.dart';
import 'package:rehberlik_app/features/classes/presentation/classes_provider.dart';
import 'package:rehberlik_app/features/classes/presentation/student_risk_provider.dart';
import 'package:rehberlik_app/features/classes/presentation/widgets/class_card.dart';
import 'package:rehberlik_app/features/students/domain/student.dart';
import 'package:rehberlik_app/features/students/presentation/students_provider.dart';
import 'package:rehberlik_app/features/students/presentation/widgets/quick_student_dialog.dart';
import 'package:rehberlik_app/features/students/presentation/widgets/student_import_dialog.dart';
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
      expect(find.text('1'), findsNWidgets(3));
      expect(find.text('Kız Öğrenci'), findsOneWidget);
      expect(find.text('Erkek Öğrenci'), findsOneWidget);
      expect(find.text('Fatma Yılmaz'), findsOneWidget);
      expect(find.text('Sıra'), findsOneWidget);
      expect(find.text('Öğrenci No'), findsOneWidget);
      expect(find.text('Ad Soyad'), findsOneWidget);
      expect(find.text('101'), findsOneWidget);
      expect(find.text('Ayşe Kaya'), findsOneWidget);
      expect(find.byKey(const Key('class_students_table')), findsOneWidget);
      expect(find.byKey(const Key('add_student_to_class')), findsOneWidget);
      expect(
        find.byKey(const Key('bulk_add_students_to_class')),
        findsOneWidget,
      );

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

  testWidgets('sınıf rehber öğretmeni atanıp sınıfa kaydedilir', (
    tester,
  ) async {
    const schoolClass = SchoolClass(
      id: 2,
      gradeLevelId: 1,
      gradeLevelLabel: '10. Sınıf',
      branch: 'B',
    );
    const anotherClass = SchoolClass(
      id: 3,
      gradeLevelId: 1,
      gradeLevelLabel: '9. Sınıf',
      branch: 'A',
      teacherId: 8,
    );
    final classesNotifier = _FakeClassAssignmentsNotifier(
      schoolClass,
      otherClasses: [anotherClass],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(null),
          studentsProvider.overrideWith(() => _FakeStudentsNotifier([])),
          teachersProvider.overrideWith(
            () => _FakeTeachersNotifier([
              const Teacher(
                id: 7,
                name: 'Deniz',
                surname: 'Arı',
                branch: 'Türkçe',
              ),
              const Teacher(
                id: 8,
                name: 'Ece',
                surname: 'Yıldız',
                branch: 'Matematik',
              ),
            ]),
          ),
          classesProvider.overrideWith(() => classesNotifier),
        ],
        child: const MaterialApp(
          home: ClassDashboardPage(schoolClass: schoolClass),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('class_advisor_edit_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('class_advisor_dropdown')));
    await tester.pumpAndSettle();

    expect(find.text('Deniz Arı · Türkçe'), findsOneWidget);
    expect(find.text('Ece Yıldız · Matematik · 9/A sınıfında'), findsOneWidget);
    await tester.tap(find.text('Deniz Arı · Türkçe'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('class_advisor_save_button')));
    await tester.pumpAndSettle();

    expect(classesNotifier.updatedClass?.teacherId, 7);
    expect(find.text('Deniz Arı'), findsOneWidget);
    expect(find.text('Deniz Arı, 10/B sınıfına atandı.'), findsOneWidget);
    expect(find.byKey(const Key('class_advisor_dropdown')), findsNothing);
    expect(find.byKey(const Key('class_advisor_edit_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('class_advisor_edit_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('class_advisor_dropdown')), findsOneWidget);
  });

  testWidgets('sınıf profilinden toplu öğrenci ekleme açılabilir', (
    tester,
  ) async {
    const schoolClass = SchoolClass(
      id: 6,
      gradeLevelId: 1,
      gradeLevelLabel: '12. Sınıf',
      branch: 'D',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(null),
          studentsProvider.overrideWith(() => _FakeStudentsNotifier([])),
          teachersProvider.overrideWith(() => _FakeTeachersNotifier([])),
          classesProvider.overrideWith(
            () => _FakeClassAssignmentsNotifier(schoolClass),
          ),
        ],
        child: const MaterialApp(
          home: ClassDashboardPage(schoolClass: schoolClass),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bulk_add_students_to_class')));
    await tester.pumpAndSettle();

    expect(find.byType(StudentImportDialog), findsOneWidget);
    expect(find.text('12/D - Toplu Öğrenci Ekle'), findsOneWidget);
  });

  testWidgets('sınıf profilinden öğrenci ekleme formu açılabilir', (
    tester,
  ) async {
    const schoolClass = SchoolClass(
      id: 5,
      gradeLevelId: 1,
      gradeLevelLabel: '11. Sınıf',
      branch: 'C',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(null),
          studentsProvider.overrideWith(() => _FakeStudentsNotifier([])),
          teachersProvider.overrideWith(() => _FakeTeachersNotifier([])),
          classesProvider.overrideWith(
            () => _FakeClassAssignmentsNotifier(schoolClass),
          ),
        ],
        child: const MaterialApp(
          home: ClassDashboardPage(schoolClass: schoolClass),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add_student_to_class')));
    await tester.pumpAndSettle();

    expect(find.byType(QuickStudentDialog), findsOneWidget);
    expect(find.text('Yeni Öğrenci Ekle'), findsOneWidget);
  });

  test('aynı öğretmen ikinci sınıfa atanamaz', () async {
    const firstClass = SchoolClass(
      id: 1,
      gradeLevelId: 1,
      gradeLevelLabel: '9. Sınıf',
      branch: 'A',
      teacherId: 7,
    );
    const secondClass = SchoolClass(
      id: 2,
      gradeLevelId: 1,
      gradeLevelLabel: '9. Sınıf',
      branch: 'B',
    );
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(null),
        classesProvider.overrideWith(
          () => _FakeClassAssignmentsNotifier(
            secondClass,
            otherClasses: [firstClass],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(classesProvider.future);
    expect(
      container
          .read(classesProvider.notifier)
          .updateClass(secondClass.copyWith(teacherId: 7)),
      throwsA(isA<StateError>()),
    );
  });

  testWidgets('tamamlanan risk haritası doğrudan görünümde açılır', (
    tester,
  ) async {
    const schoolClass = SchoolClass(
      id: 1,
      gradeLevelId: 1,
      gradeLevelLabel: '9. Sınıf',
      branch: 'A',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(null),
          studentsProvider.overrideWith(() => _FakeStudentsNotifier([])),
          teachersProvider.overrideWith(() => _FakeTeachersNotifier([])),
          classRiskMapCompletedProvider.overrideWith(
            (ref, classId) async => true,
          ),
        ],
        child: const MaterialApp(
          home: ClassDashboardPage(schoolClass: schoolClass),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open_class_risk_map')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('edit_class_risk_map')), findsOneWidget);
  });
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

class _FakeClassAssignmentsNotifier extends ClassesNotifier {
  _FakeClassAssignmentsNotifier(
    this.schoolClass, {
    this.otherClasses = const [],
  });

  final SchoolClass schoolClass;
  final List<SchoolClass> otherClasses;
  SchoolClass? updatedClass;

  @override
  Future<ClassesState> build() async =>
      ClassesState(classes: [schoolClass, ...otherClasses]);

  @override
  Future<void> updateClass(SchoolClass updatedClass) async {
    final occupied = [schoolClass, ...otherClasses].any(
      (item) =>
          item.id != updatedClass.id &&
          item.teacherId == updatedClass.teacherId,
    );
    if (occupied) {
      throw StateError('Öğretmen başka bir sınıfa atanmış.');
    }
    this.updatedClass = updatedClass;
    state = AsyncValue.data(
      ClassesState(
        classes: [
          updatedClass,
          ...otherClasses.where((item) => item.id != updatedClass.id),
        ],
      ),
    );
  }
}
