import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/features/special_education/data/bep_meeting_pdf.dart';
import 'package:rehberlik_app/features/special_education/domain/bep_meeting.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('BEP toplantı tutanağı PDF olarak oluşturulur', () async {
    final meeting = BepMeeting(
      id: 1,
      studentId: 1,
      studentName: 'Ayşe Kaya',
      studentNumber: '101',
      className: '9. Sınıf / A',
      studentBirthDate: '2010-01-02',
      studentGender: 'Kız',
      meetingDate: '2026-11-11',
      agendaItems: [bepMeetingAgendaItems.first],
      decisions: [bepMeetingDecisionItems.first],
      teacherIds: [1, 2],
      teacherNames: ['Zeynep Arı', 'Mehmet Yılmaz'],
      createdAt: '2026-11-11',
    );

    final bytes = await (await BepMeetingPdf.build(
      meeting: meeting,
      meetingNumber: 2,
    )).save();

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(8)), startsWith('%PDF-'));
  });
}
