import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/core/providers/session_provider.dart';
import 'package:rehberlik_app/features/classes/domain/grade_level.dart';
import 'package:rehberlik_app/features/classes/domain/school_class.dart';
import 'package:rehberlik_app/features/classes/presentation/classes_provider.dart';
import 'package:rehberlik_app/features/students/domain/student.dart';
import 'package:rehberlik_app/features/students/presentation/students_provider.dart';
import 'package:rehberlik_app/features/students/presentation/widgets/student_info_form_sheet.dart';

void main() {
  testWidgets('form stale öğrenci nesnesi yerine güncel kayıtla açılır', (
    tester,
  ) async {
    const staleStudent = Student(
      id: 1,
      classId: 2,
      number: '101',
      name: 'Ayşe',
      surname: 'Kaya',
      createdAt: '2026-11-10',
    );
    const savedStudent = Student(
      id: 1,
      classId: 2,
      number: '101',
      name: 'Ayşe',
      surname: 'Kaya',
      createdAt: '2026-11-10',
      birthPlace: 'Ankara',
      motherName: 'Fatma',
      motherIsAlive: true,
    );
    final studentsNotifier = _FormStudentsNotifier([savedStudent]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(null),
          studentsProvider.overrideWith(() => studentsNotifier),
          classesProvider.overrideWith(
            () => _FormClassesNotifier(
              const SchoolClass(
                id: 2,
                gradeLevelId: 1,
                gradeLevelLabel: '9. Sınıf',
                branch: 'A',
              ),
            ),
          ),
        ],
        child: MaterialApp(home: _FormHost(staleStudent: staleStudent)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open_student_form')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('student_info_save_button')));
    await tester.pumpAndSettle();

    expect(studentsNotifier.updatedStudent?.birthPlace, 'Ankara');
    expect(studentsNotifier.updatedStudent?.motherName, 'Fatma');
  });

  testWidgets('anne ve baba eğitim durumu verilen seçeneklerden seçilir', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const student = Student(
      id: 1,
      classId: 2,
      number: '101',
      name: 'Ayşe',
      surname: 'Kaya',
      createdAt: '2026-11-10',
    );
    final studentsNotifier = _FormStudentsNotifier([student]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(null),
          studentsProvider.overrideWith(() => studentsNotifier),
          classesProvider.overrideWith(
            () => _FormClassesNotifier(
              const SchoolClass(
                id: 2,
                gradeLevelId: 1,
                gradeLevelLabel: '9. Sınıf',
                branch: 'A',
              ),
            ),
          ),
        ],
        child: MaterialApp(home: _FormHost(staleStudent: student)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open_student_form')));
    await tester.pumpAndSettle();

    final motherEducation = find.byKey(const Key('motherEducation_dropdown'));
    await tester.tap(motherEducation);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Üniversite').last);
    await tester.pumpAndSettle();

    final fatherEducation = find.byKey(const Key('fatherEducation_dropdown'));
    await tester.tap(fatherEducation);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lise').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('student_info_save_button')));
    await tester.pumpAndSettle();

    expect(studentsNotifier.updatedStudent?.motherEducation, 'Üniversite');
    expect(studentsNotifier.updatedStudent?.fatherEducation, 'Lise');
  });
}

class _FormStudentsNotifier extends StudentsNotifier {
  _FormStudentsNotifier(this.students);

  final List<Student> students;
  Student? updatedStudent;

  @override
  Future<List<Student>> build() async => students;

  @override
  Future<void> updateStudent(Student student) async {
    updatedStudent = student;
    state = AsyncValue.data([student]);
  }
}

class _FormHost extends ConsumerWidget {
  const _FormHost({required this.staleStudent});

  final Student staleStudent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(studentsProvider);
    return Scaffold(
      body: TextButton(
        key: const Key('open_student_form'),
        onPressed: () => StudentInfoFormSheet.show(context, staleStudent),
        child: const Text('Formu Aç'),
      ),
    );
  }
}

class _FormClassesNotifier extends ClassesNotifier {
  _FormClassesNotifier(this.schoolClass);

  final SchoolClass schoolClass;

  @override
  Future<ClassesState> build() async => ClassesState(
    gradeLevels: [
      GradeLevel(
        id: schoolClass.gradeLevelId,
        label: schoolClass.gradeLevelLabel,
        sortOrder: 1,
      ),
    ],
    classes: [schoolClass],
  );
}
