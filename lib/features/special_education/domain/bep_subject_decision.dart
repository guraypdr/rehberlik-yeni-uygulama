import '../data/bep_meeting_pdf.dart';
import 'student_subject_need.dart';

/// Ders durumuna göre üretilen tek bir karar ve altındaki ders tablosu.
class BepSubjectDecision {
  const BepSubjectDecision({
    required this.text,
    required this.emptyText,
    required this.columns,
    required this.rows,
  });

  /// Karar cümlesi.
  final String text;

  /// Ders bulunmadığında kararın altında gösterilen açıklama.
  final String emptyText;

  /// Tablo başlıkları.
  final List<String> columns;

  /// Tablo satırları — her satır sütun sırasına göre değer taşır.
  final List<List<String>> rows;

  bool get hasRows => rows.isNotEmpty;
}

const List<String> _subjectColumns = [
  'Ders Adı',
  'Ders Öğretmeni',
  'Ders Saati',
];

const List<String> _supportColumns = [
  'Ders Adı',
  'Ders Öğretmeni',
  'Destek Eğitim Öğretmeni',
  'Haftalık Ders Saati',
  'Destek Eğitimi Ders Saati',
];

/// Öğrencinin ders ihtiyaçlarından BEP toplantısı kararlarını üretir.
///
/// Kararlar her görüntülemede güncel ders ihtiyaçlarından hesaplandığı için
/// uygulama içinde ders bilgileri değiştiğinde kararlar da değişir.
List<BepSubjectDecision> buildBepSubjectDecisions(
  List<StudentSubjectNeed> needs,
) {
  BepSubjectDecision build({
    required bool Function(StudentSubjectNeed need) matches,
    required String text,
    required String emptyText,
    required List<String> Function(StudentSubjectNeed need) row,
    List<String> columns = _subjectColumns,
  }) => BepSubjectDecision(
    text: text,
    emptyText: emptyText,
    columns: columns,
    rows: [
      for (final need in needs)
        if (matches(need)) row(need),
    ],
  );

  return [
    build(
      matches: (need) => need.requiresSupportEducation,
      columns: _supportColumns,
      row: (need) => [
        need.subjectName,
        _teacher(need.teacherName),
        _teacher(need.supportTeacherName),
        '${need.weeklyHours}',
        '${need.effectiveSupportHours ?? need.suggestedSupportHours}',
      ],
      text:
          'Öğrencinin aşağıda belirtilen derslerde destek eğitim odasında '
          'eğitim alması uygun görülmüştür.',
      emptyText:
          'Öğrencinin destek eğitim odasında eğitim alması uygun görülen '
          'dersi bulunmamaktadır.',
    ),
    build(
      matches: (need) => need.requiresBep,
      row: (need) => [
        need.subjectName,
        _teacher(need.teacherName),
        '${need.weeklyHours}',
      ],
      text:
          'Öğrencinin BEP planı hazırlanarak sınıfta akranlarıyla birlikte '
          'eğitim alması uygun görülen dersler aşağıdaki gibidir.',
      emptyText:
          'Öğrencinin BEP planı hazırlanarak sınıfta akranlarıyla birlikte '
          'eğitim alması uygun görülen dersi bulunmamaktadır.',
    ),
    build(
      matches: (need) => need.isExempt,
      row: (need) => [
        need.subjectName,
        _teacher(need.teacherName),
        '${need.weeklyHours}',
      ],
      text:
          'Öğrencinin veli ve öğrenci talebi doğrultusunda ilgili yönetmelik '
          'hükümleri uyarınca muaf olması kararlaştırılan dersler aşağıdaki '
          'gibidir.',
      emptyText: 'Öğrencinin muaf olması kararlaştırılan ders bulunmamaktadır.',
    ),
    build(
      matches: (need) => need.isNormalProgram,
      row: (need) => [
        need.subjectName,
        _teacher(need.teacherName),
        '${need.weeklyHours}',
      ],
      text:
          'Öğrencinin normal öğretim programına uygun olarak (BEP '
          'hazırlanmasına gerek duyulmayan) dersler aşağıdaki gibidir.',
      emptyText:
          'Öğrencinin normal öğretim programına uygun olarak devam ettiği '
          'ders bulunmamaktadır.',
    ),
  ];
}

String _teacher(String? name) {
  final trimmed = name?.trim() ?? '';
  return trimmed.isEmpty ? '—' : toTurkishTitleCase(trimmed);
}
