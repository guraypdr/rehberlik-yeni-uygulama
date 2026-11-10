import '../../students/domain/student.dart';

class StudentRiskQuestion {
  const StudentRiskQuestion({
    required this.key,
    required this.label,
    this.fromStudentForm = false,
  });

  final String key;
  final String label;
  final bool fromStudentForm;

  bool? answerFromStudent(Student student) {
    if (!fromStudentForm) return null;

    return switch (key) {
      'mother_low_education' => _hasAtMostPrimaryEducation(
        student.motherEducation,
      ),
      'father_low_education' => _hasAtMostPrimaryEducation(
        student.fatherEducation,
      ),
      'only_child' => student.siblingCount == 0,
      'five_or_more_siblings' =>
        student.siblingCount != null && student.siblingCount! >= 5,
      'mother_deceased' => student.motherIsAlive == false,
      'father_deceased' => student.fatherIsAlive == false,
      'both_parents_deceased' =>
        student.motherIsAlive == false && student.fatherIsAlive == false,
      'family_chronic_illness' => student.familyHasChronicIllness == true,
      'student_chronic_illness' => student.hasChronicIllness == true,
      _ => throw StateError(
        'Öğrenci formundan cevap eşlemesi tanımlanmamış: $key',
      ),
    };
  }

  static bool _hasAtMostPrimaryEducation(String? education) {
    final normalized = education?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return false;
    return const {
      'ilkokul',
      'ilköğretim',
      'okur yazar',
      'okuryazar',
      'okuma yazma biliyor',
      'eğitimsiz',
      'eğitimi yok',
    }.contains(normalized);
  }
}

const studentRiskQuestions = <StudentRiskQuestion>[
  StudentRiskQuestion(
    key: 'mother_low_education',
    label: 'Anne en fazla ilkokul mezunu',
    fromStudentForm: true,
  ),
  StudentRiskQuestion(
    key: 'father_low_education',
    label: 'Baba en fazla ilkokul mezunu',
    fromStudentForm: true,
  ),
  StudentRiskQuestion(
    key: 'only_child',
    label: 'Tek çocuk olan',
    fromStudentForm: true,
  ),
  StudentRiskQuestion(
    key: 'five_or_more_siblings',
    label: '5 ve üstü kardeşi olan',
    fromStudentForm: true,
  ),
  StudentRiskQuestion(
    key: 'parents_separated',
    label: 'Anne ve babası ayrı yaşayan',
  ),
  StudentRiskQuestion(
    key: 'parents_divorced',
    label: 'Anne ve babası boşanmış olan',
  ),
  StudentRiskQuestion(
    key: 'lives_only_with_mother',
    label: 'Yalnızca annesi ile yaşayan',
  ),
  StudentRiskQuestion(
    key: 'lives_only_with_father',
    label: 'Yalnızca babası ile yaşayan',
  ),
  StudentRiskQuestion(
    key: 'mother_deceased',
    label: 'Annesi hayatta olmayan',
    fromStudentForm: true,
  ),
  StudentRiskQuestion(
    key: 'father_deceased',
    label: 'Babası hayatta olmayan',
    fromStudentForm: true,
  ),
  StudentRiskQuestion(
    key: 'both_parents_deceased',
    label: 'Anne ve babası hayatta olmayan',
    fromStudentForm: true,
  ),
  StudentRiskQuestion(key: 'martyr_child', label: 'Şehit çocuğu'),
  StudentRiskQuestion(
    key: 'lives_with_grandparents_only',
    label: 'Yalnızca büyükanne / büyükbabasıyla yaşayan',
  ),
  StudentRiskQuestion(
    key: 'lives_with_relatives_only',
    label: 'Yalnızca diğer akrabalarıyla yaşayan',
  ),
  StudentRiskQuestion(
    key: 'foster_care',
    label: 'Koruyucu aile gözetiminde olan',
  ),
  StudentRiskQuestion(key: 'children_home', label: 'Sevgi Evlerinde kalan'),
  StudentRiskQuestion(
    key: 'child_protection_institution',
    label: 'Sosyal Hizmetler Çocuk Esirgeme Kurumunda kalan',
  ),
  StudentRiskQuestion(
    key: 'family_chronic_illness',
    label: 'Ailesinde süreğen hastalığı olan',
    fromStudentForm: true,
  ),
  StudentRiskQuestion(
    key: 'family_mental_illness',
    label: 'Ailesinde ruhsal hastalığı olan',
  ),
  StudentRiskQuestion(
    key: 'family_substance_addiction',
    label: 'Ailesinde bağımlı bireyler bulunan (alkol / madde)',
  ),
  StudentRiskQuestion(
    key: 'family_criminal_conviction',
    label: 'Ailesinde cezai hükmü bulunan',
  ),
  StudentRiskQuestion(
    key: 'seasonal_worker_family',
    label: 'Ailesi mevsimlik işçi olan',
  ),
  StudentRiskQuestion(
    key: 'domestic_violence',
    label: 'Aile içi şiddete maruz kalan',
  ),
  StudentRiskQuestion(key: 'gifted', label: 'Özel yetenekli tanısı olan'),
  StudentRiskQuestion(
    key: 'special_education_report',
    label: 'Yetersizlik alanında özel eğitim raporu olan',
  ),
  StudentRiskQuestion(
    key: 'student_chronic_illness',
    label: 'Süreğen hastalığı olan',
    fromStudentForm: true,
  ),
  StudentRiskQuestion(key: 'mental_illness', label: 'Ruhsal hastalığı olan'),
  StudentRiskQuestion(
    key: 'counseling_measure',
    label: 'Danışmanlık tedbir kararı olan',
  ),
  StudentRiskQuestion(
    key: 'education_measure',
    label: 'Eğitim tedbir kararı olan',
  ),
  StudentRiskQuestion(
    key: 'financial_hardship',
    label: 'Maddi sıkıntı yaşayan',
  ),
  StudentRiskQuestion(
    key: 'chronic_absenteeism',
    label: 'Sürekli devamsız olan',
  ),
  StudentRiskQuestion(key: 'working_student', label: 'Bir işte çalışan'),
  StudentRiskQuestion(
    key: 'low_academic_achievement',
    label: 'Akademik başarısı düşük',
  ),
  StudentRiskQuestion(
    key: 'at_risk_peer_group',
    label: 'Riskli akran grubuna dahil olan',
  ),
  StudentRiskQuestion(
    key: 'foreign_national',
    label: 'Yabancı uyruklu öğrenci',
  ),
  StudentRiskQuestion(key: 'other', label: 'Diğer'),
];

final studentRiskManualQuestions = studentRiskQuestions
    .where((question) => !question.fromStudentForm)
    .toList(growable: false);
