import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/features/settings/domain/school_staff.dart';
import 'package:rehberlik_app/features/special_education/data/bep_meeting_pdf.dart';
import 'package:rehberlik_app/features/special_education/domain/bep_meeting.dart';
import 'package:rehberlik_app/features/special_education/domain/bep_subject_decision.dart';
import 'package:rehberlik_app/features/special_education/domain/student_subject_need.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('toTurkishTitleCase isimleri Türkçe kurallarına göre düzenler', () {
    expect(toTurkishTitleCase('ahmet yılmaz'), 'Ahmet Yılmaz');
    expect(toTurkishTitleCase('AYŞE KAYA'), 'Ayşe Kaya');
    expect(toTurkishTitleCase('İSMAİL IŞIK'), 'İsmail Işık');
    expect(toTurkishTitleCase('ömer çetin'), 'Ömer Çetin');
    expect(toTurkishTitleCase('şaziye ünal'), 'Şaziye Ünal');
    expect(toTurkishTitleCase('   mehmet   ali   demir   '), 'Mehmet Ali Demir');
    expect(toTurkishTitleCase(''), '');
    expect(toTurkishTitleCase(null), '');
  });

  test('buildBepSubjectDecisions tablolarında Ders Öğretmeni başlığı kullanılır', () {
    const need = StudentSubjectNeed(
      studentId: 1,
      classSubjectId: 1,
      subjectName: 'Matematik',
      weeklyHours: 4,
      requiresSupportEducation: true,
      requiresBep: false,
      isExempt: false,
      teacherName: 'ahmet yılmaz',
      supportTeacherName: 'mehmet demir',
    );

    final decisions = buildBepSubjectDecisions([need]);
    expect(decisions.first.columns, contains('Ders Öğretmeni'));
    expect(decisions.first.columns, isNot(contains('Dersi Verecek Öğretmen')));
    expect(decisions[1].columns, contains('Ders Öğretmeni'));
    expect(decisions[1].columns, isNot(contains('Dersi Verecek Öğretmen')));

    // Öğretmen adları büyük harf küçük harf tutarlılığı (Title Case) ile yazılır
    expect(decisions.first.rows.first[1], 'Ahmet Yılmaz');
    expect(decisions.first.rows.first[2], 'Mehmet Demir');
  });

  test('BEP toplantı tutanağı PDF olarak oluşturulur ve tedbirleri içerir', () async {
    const meeting = BepMeeting(
      id: 1,
      studentId: 1,
      studentName: 'ayşe kaya',
      studentNumber: '101',
      className: '9. Sınıf / A',
      studentBirthDate: '2010-01-02',
      studentGender: 'Kız',
      meetingDate: '2026-11-11',
      agendaItems: [bepMeetingAgendaItems.first],
      decisions: [bepMeetingDecisionItems.first],
      teacherIds: [1, 2],
      teacherNames: ['zeynep arı', 'MEHMET YILMAZ'],
      parentAttendees: ['fatma kaya'],
      staffAttendees: ['hasan çelik'],
      createdAt: '2026-11-11',
    );

    const staff = [
      SchoolStaff(
        id: 1,
        role: SchoolStaffRole.principal,
        name: 'Hasan',
        surname: 'Çelik',
      ),
    ];

    final docWithMeasures = await BepMeetingPdf.build(
      meeting: meeting,
      meetingNumber: 2,
      schoolName: 'Ankara Lisesi',
      schoolAndClassroomMeasures: 'Ön sırada oturtulması\nSınavlarda ek süre verilmesi',
      staff: staff,
      classTeacherName: 'Zeynep Arı',
      subjectNeeds: const [
        StudentSubjectNeed(
          studentId: 1,
          classSubjectId: 1,
          subjectName: 'Matematik',
          weeklyHours: 5,
          requiresSupportEducation: true,
          requiresBep: false,
          isExempt: false,
          teacherName: 'zeynep arı',
        ),
      ],
    );

    final bytesWithMeasures = await docWithMeasures.save();
    expect(bytesWithMeasures, isNotEmpty);
    expect(String.fromCharCodes(bytesWithMeasures.take(8)), startsWith('%PDF-'));

    // Tedbirsiz oluşturma testi
    final docWithoutMeasures = await BepMeetingPdf.build(
      meeting: meeting,
      meetingNumber: 1,
      schoolName: 'Ankara Lisesi',
      staff: staff,
      classTeacherName: 'Zeynep Arı',
    );
    final bytesWithoutMeasures = await docWithoutMeasures.save();
    expect(bytesWithoutMeasures, isNotEmpty);
    expect(String.fromCharCodes(bytesWithoutMeasures.take(8)), startsWith('%PDF-'));
  });
}
