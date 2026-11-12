import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/features/special_education/domain/bep_subject_decision.dart';
import 'package:rehberlik_app/features/special_education/domain/student_subject_need.dart';

void main() {
  test('ders ihtiyaçlarını karar gruplarına ve tablo satırlarına ayırır', () {
    const needs = [
      StudentSubjectNeed(
        studentId: 1,
        classSubjectId: 1,
        subjectName: 'Matematik',
        weeklyHours: 5,
        requiresSupportEducation: true,
        requiresBep: false,
        isExempt: false,
        teacherName: 'Ayşe Kaya',
      ),
      StudentSubjectNeed(
        studentId: 1,
        classSubjectId: 2,
        subjectName: 'Fizik',
        weeklyHours: 2,
        requiresSupportEducation: false,
        requiresBep: true,
        isExempt: false,
        teacherName: '  ',
      ),
      StudentSubjectNeed(
        studentId: 1,
        classSubjectId: 3,
        subjectName: 'Kimya',
        weeklyHours: 3,
        requiresSupportEducation: false,
        requiresBep: false,
        isExempt: true,
        teacherName: 'Mehmet Yılmaz',
      ),
      StudentSubjectNeed(
        studentId: 1,
        classSubjectId: 4,
        subjectName: 'Biyoloji',
        weeklyHours: 2,
        requiresSupportEducation: false,
        requiresBep: false,
        isExempt: false,
      ),
    ];

    final decisions = buildBepSubjectDecisions(needs);

    expect(decisions, hasLength(4));
    expect(decisions.map((decision) => decision.hasRows), everyElement(isTrue));
    expect(decisions[0].rows.single.subjectName, 'Matematik');
    expect(decisions[0].rows.single.teacherName, 'Ayşe Kaya');
    expect(decisions[0].rows.single.weeklyHours, 5);
    expect(decisions[1].rows.single.subjectName, 'Fizik');
    expect(decisions[1].rows.single.teacherName, '—');
    expect(decisions[2].rows.single.subjectName, 'Kimya');
    expect(decisions[3].rows.single.subjectName, 'Biyoloji');
  });

  test('ders bulunmayan kararlarda açıklama metni kullanılır', () {
    final decisions = buildBepSubjectDecisions(const []);

    expect(decisions, hasLength(4));
    for (final decision in decisions) {
      expect(decision.hasRows, isFalse);
      expect(decision.text, isNotEmpty);
    }
    expect(
      decisions[2].emptyText,
      'Öğrencinin muaf olması kararlaştırılan ders bulunmamaktadır.',
    );
  });
}
