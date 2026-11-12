import 'student_subject_need.dart';

/// Öğrencinin bir dersine ait karar tablosu satırı.
class BepSubjectDecisionRow {
  const BepSubjectDecisionRow({
    required this.subjectName,
    required this.teacherName,
    required this.weeklyHours,
  });

  final String subjectName;

  /// Dersi verecek öğretmen; atanmamışsa "—" gösterilir.
  final String teacherName;
  final int weeklyHours;
}

/// Ders durumuna göre üretilen tek bir karar ve altındaki ders tablosu.
class BepSubjectDecision {
  const BepSubjectDecision({
    required this.text,
    required this.emptyText,
    required this.rows,
  });

  /// Karar cümlesi.
  final String text;

  /// Ders bulunmadığında kararın altında gösterilen açıklama.
  final String emptyText;

  final List<BepSubjectDecisionRow> rows;

  bool get hasRows => rows.isNotEmpty;
}

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
  }) => BepSubjectDecision(
    text: text,
    emptyText: emptyText,
    rows: [
      for (final need in needs)
        if (matches(need))
          BepSubjectDecisionRow(
            subjectName: need.subjectName,
            teacherName: (need.teacherName?.trim().isNotEmpty ?? false)
                ? need.teacherName!.trim()
                : '—',
            weeklyHours: need.weeklyHours,
          ),
    ],
  );

  return [
    build(
      matches: (need) => need.requiresSupportEducation,
      text:
          'Öğrencinin aşağıda belirtilen derslerde destek eğitim odasında '
          'eğitim alması uygun görülmüştür.',
      emptyText:
          'Öğrencinin destek eğitim odasında eğitim alması uygun görülen '
          'dersi bulunmamaktadır.',
    ),
    build(
      matches: (need) => need.requiresBep,
      text:
          'Öğrencinin BEP planı hazırlanarak sınıfta akranlarıyla birlikte '
          'eğitim alması uygun görülen dersler aşağıdaki gibidir.',
      emptyText:
          'Öğrencinin BEP planı hazırlanarak sınıfta akranlarıyla birlikte '
          'eğitim alması uygun görülen dersi bulunmamaktadır.',
    ),
    build(
      matches: (need) => need.isExempt,
      text:
          'Öğrencinin veli ve öğrenci talebi doğrultusunda ilgili yönetmelik '
          'hükümleri uyarınca muaf olması kararlaştırılan dersler aşağıdaki '
          'gibidir.',
      emptyText: 'Öğrencinin muaf olması kararlaştırılan ders bulunmamaktadır.',
    ),
    build(
      matches: (need) => need.isNormalProgram,
      text:
          'Öğrencinin normal öğretim programına uygun olarak (BEP '
          'hazırlanmasına gerek duyulmayan) dersler aşağıdaki gibidir.',
      emptyText:
          'Öğrencinin normal öğretim programına uygun olarak devam ettiği '
          'ders bulunmamaktadır.',
    ),
  ];
}
