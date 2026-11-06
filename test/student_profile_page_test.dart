import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/core/providers/session_provider.dart';
import 'package:rehberlik_app/features/students/domain/student.dart';
import 'package:rehberlik_app/features/students/presentation/widgets/student_profile_page.dart';

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
    expect(find.text('Ayşe Kaya'), findsOneWidget);
    expect(find.text('No 101'), findsOneWidget);
    expect(find.text('Yatılı'), findsNWidgets(2));
    expect(find.text('Temel Öğrenci Bilgileri'), findsOneWidget);
    expect(find.text('Öğrenci Bilgileri'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Öğrenci Bilgileri'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Öğrenci Bilgileri'));
    await tester.pumpAndSettle();
    expect(find.text('Doğum Yeri'), findsOneWidget);
    expect(find.text('Ankara'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Anne Bilgileri'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Anne Bilgileri'));
    await tester.pumpAndSettle();
    expect(find.text('Anne Bilgileri'), findsOneWidget);
    expect(find.text('Fatma'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Kardeş ve Hane Bilgileri'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Kardeş ve Hane Bilgileri'));
    await tester.pumpAndSettle();
    expect(find.text('Kardeş Sayısı'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Görüşme Kayıtları'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Görüşme Kayıtları'), findsOneWidget);
    expect(find.text('Görüşme Kayıtları'), findsOneWidget);
  });
}

class _ProfileHost extends StatelessWidget {
  const _ProfileHost({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) => StudentProfilePage(student: student);
}
