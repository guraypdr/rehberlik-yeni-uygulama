import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/core/providers/session_provider.dart';
import 'package:rehberlik_app/features/students/domain/student.dart';
import 'package:rehberlik_app/features/students/presentation/students_provider.dart';
import 'package:rehberlik_app/features/students/presentation/widgets/student_profile_page.dart';
import 'package:rehberlik_app/features/students/presentation/widgets/student_interviews_dialog.dart';

void main() {
  testWidgets('öğrenci profili kayıtlı bilgileri bölümler halinde gösterir', (
    tester,
  ) async {
    const student = Student(
      id: 1,
      classId: 2,
      number: '101',
      name: 'Ayşe',
      surname: 'Kaya',
      gender: 'Kız',
      boardingStatus: 'Yatılı',
      createdAt: '2026-11-06',
      birthPlace: 'Ankara',
      birthDate: '2010-03-04',
      address: 'Çankaya',
      preschoolEducation: true,
      usesRegularMedication: false,
      hasChronicIllness: false,
      likesActivities: 'Kitap okumak',
      hasRecentMoveOrSchoolChange: false,
      extracurricularActivities: 'Yüzme',
      hasTechnologyDevice: true,
      technologyUsageMinutes: 90,
      hasInfluentialEvent: false,
      motherName: 'Fatma',
      motherIsAlive: true,
      motherIsBiological: true,
      motherHasDisability: false,
      motherEducation: 'Lisans',
      motherJob: 'Öğretmen',
      fatherName: 'Mehmet',
      fatherIsAlive: true,
      fatherIsBiological: true,
      fatherHasDisability: false,
      fatherEducation: 'Lise',
      fatherJob: 'Esnaf',
      siblingCount: 1,
      childOrder: 2,
      familyHasChronicIllness: false,
      householdMembers: 'Anne, baba ve çocuk',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(null)],
        child: const MaterialApp(home: _ProfileHost(student: student)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Öğrenci Profili'), findsOneWidget);
    expect(find.text('Ayşe Kaya'), findsNWidgets(2));
    expect(find.text('101'), findsWidgets);
    expect(find.text('Yatılı'), findsOneWidget);
    expect(find.text('Kişisel Bilgiler'), findsOneWidget);
    final profileScrollable = find.descendant(
      of: find.byKey(const Key('student_profile_tab_content_0')),
      matching: find.byType(Scrollable),
    );

    await tester.scrollUntilVisible(
      find.text('Doğum Yeri'),
      300,
      scrollable: profileScrollable,
    );
    expect(find.text('Doğum Yeri'), findsOneWidget);
    expect(find.text('Ankara'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('student_profile_tab_Aile Bilgileri')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Anne Bilgileri'), findsOneWidget);
    expect(find.text('Fatma'), findsOneWidget);
    final familyScrollable = find.descendant(
      of: find.byKey(const Key('student_profile_tab_content_1')),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('Hane Bilgileri'),
      300,
      scrollable: familyScrollable,
    );
    expect(find.text('Hane Bilgileri'), findsOneWidget);
    expect(find.text('Kardeş Sayısı'), findsOneWidget);

    await tester.drag(
      find.byKey(const Key('student_profile_tab_bar')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('student_profile_tab_Sosyal Bilgiler')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Yapmaktan Hoşlandığı Şeyler'), findsOneWidget);

    await tester.drag(
      find.byKey(const Key('student_profile_tab_bar')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('student_profile_tab_Görüşme Geçmişi')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Görüşme Kayıtları'), findsOneWidget);
  });

  testWidgets('profil araması numaraya göre öğrenci değiştirebilir', (
    tester,
  ) async {
    const currentStudent = Student(
      id: 1,
      classId: 2,
      number: '101',
      name: 'Ayşe',
      surname: 'Kaya',
      createdAt: '2026-11-06',
    );
    const matchingStudent = Student(
      id: 2,
      classId: 2,
      number: '202',
      name: 'Mehmet',
      surname: 'Demir',
      createdAt: '2026-11-06',
      className: '9/A',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(null),
          studentsProvider.overrideWith(
            () => _ProfileStudentsNotifier([currentStudent, matchingStudent]),
          ),
        ],
        child: const MaterialApp(home: _ProfileHost(student: currentStudent)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('student_profile_search')),
      '202',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Öğrenci Ara'));
    await tester.pumpAndSettle();

    expect(find.text('Mehmet Demir'), findsNWidgets(2));
    expect(find.text('202'), findsWidgets);
  });

  testWidgets('profil bölümleri yerinde düzenlenir ve kaydedilir', (
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
      createdAt: '2026-11-06',
    );
    final studentsNotifier = _ProfileStudentsNotifier([student]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(null),
          studentsProvider.overrideWith(() => studentsNotifier),
        ],
        child: const MaterialApp(home: _ProfileHost(student: student)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('open_student_info_form')), findsNothing);
    expect(find.byKey(const Key('open_student_interviews')), findsOneWidget);

    await tester.drag(
      find.byKey(const Key('student_profile_tab_bar')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('student_profile_tab_Eğitim Bilgileri')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('edit_student_section_education')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('hasSpecialEducation_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Evet').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('student_info_save_button')));
    await tester.pumpAndSettle();

    expect(studentsNotifier.updatedStudent?.hasSpecialEducation, isTrue);
    expect(
      find.byKey(const Key('edit_student_section_education')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('open_student_interviews')));
    await tester.pumpAndSettle();
    expect(find.byType(StudentInterviewsDialog), findsOneWidget);
    expect(find.text('Görüşmeler · Ayşe Kaya'), findsOneWidget);
    expect(find.byKey(const Key('student_add_interview')), findsOneWidget);
  });
}

class _ProfileStudentsNotifier extends StudentsNotifier {
  _ProfileStudentsNotifier(this.students);

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

class _ProfileHost extends StatelessWidget {
  const _ProfileHost({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) => StudentProfilePage(student: student);
}
