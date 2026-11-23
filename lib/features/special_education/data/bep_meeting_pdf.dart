import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../settings/domain/school_staff.dart';
import '../domain/bep_meeting.dart';
import '../domain/bep_subject_decision.dart';
import '../domain/student_subject_need.dart';

/// Türkçe karakterlere uygun Title Case (Baş Harfler Büyük) dönüştürücü.
String toTurkishTitleCase(String? text) {
  if (text == null) return '';
  final trimmed = text.trim();
  if (trimmed.isEmpty) return '';
  return trimmed.split(RegExp(r'\s+')).map((word) {
    if (word.isEmpty) return word;
    final lower = word
        .replaceAll('İ', 'i')
        .replaceAll('I', 'ı')
        .toLowerCase()
        .replaceAll('i\u0307', 'i');
    final characters = lower.runes.toList();
    final first = String.fromCharCode(characters.first);
    final capitalizedFirst = switch (first) {
      'i' => 'İ',
      'ı' => 'I',
      _ => first.toUpperCase(),
    };
    return '$capitalizedFirst${String.fromCharCodes(characters.skip(1))}';
  }).join(' ');
}

/// Katılımcı adı ve unvanını tutan yapı.
class BepAttendeeSignature {
  const BepAttendeeSignature({
    required this.name,
    required this.title,
  });

  final String name;
  final String title;
}

class BepMeetingPdf {
  const BepMeetingPdf._();

  static Future<pw.Document> build({
    required BepMeeting meeting,
    required int meetingNumber,
    List<StudentSubjectNeed> subjectNeeds = const [],
    String? schoolName,
    String? schoolAndClassroomMeasures,
    List<SchoolStaff> staff = const [],
    String? classTeacherName,
  }) async {
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Lato-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Lato-Bold.ttf'),
    );
    final document = pw.Document(
      theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
    );
    final subjectDecisions = buildBepSubjectDecisions(subjectNeeds);
    final school = schoolName?.trim() ?? '';
    final measureItems = _parseMeasures(schoolAndClassroomMeasures);
    final hasMeasures = measureItems.isNotEmpty;
    final attendees = _buildAttendees(
      meeting: meeting,
      staff: staff,
      classTeacherName: classTeacherName,
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => [
          if (school.isNotEmpty)
            pw.Center(
              child: pw.Text(
                school.toUpperCase(),
                style: pw.TextStyle(fontSize: 10, letterSpacing: 0.8),
              ),
            ),
          pw.SizedBox(height: 8),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 9),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey300,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Center(
              child: pw.Text(
                'BEP TOPLANTI TUTANAĞI',
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.6),
            columnWidths: const {
              0: pw.FlexColumnWidth(1.2),
              1: pw.FlexColumnWidth(1),
              2: pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                children: [
                  _keyValueCell(
                    'Adı Soyadı',
                    toTurkishTitleCase(meeting.studentName),
                  ),
                  _keyValueCell('Sınıfı / Şubesi', meeting.className),
                  _keyValueCell('Öğrenci No', meeting.studentNumber),
                ],
              ),
              pw.TableRow(
                children: [
                  _keyValueCell(
                    'Doğum Tarihi',
                    _formatDate(meeting.studentBirthDate),
                  ),
                  _keyValueCell('Cinsiyeti', meeting.studentGender),
                  _keyValueCell(
                    'Toplantı Tarihi',
                    _formatDate(meeting.meetingDate),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  _keyValueCell('Toplantı No', '$meetingNumber'),
                  _keyValueCell('', ''),
                  _keyValueCell('', ''),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          _sectionTitle('GÖRÜŞÜLEN GÜNDEM MADDELERİ'),
          if (meeting.agendaItems.isEmpty)
            _emptyLine()
          else
            for (var index = 0; index < meeting.agendaItems.length; index++)
              _numberedItem(index, meeting.agendaItems[index]),
          pw.SizedBox(height: 14),
          _sectionTitle('ALINAN KARARLAR'),
          if (meeting.decisions.isEmpty && subjectNeeds.isEmpty && !hasMeasures)
            _emptyLine()
          else ...[
            if (hasMeasures) ...[
              _numberedItem(
                0,
                'Öğrenciye yönelik sınıf ve okul içinde aşağıdaki tedbirlerin '
                'alınması kararlaştırılmıştır.',
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 26, bottom: 6),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    for (final measure in measureItems)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 2),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('• ',
                                style: const pw.TextStyle(fontSize: 8.5)),
                            pw.Expanded(
                              child: pw.Text(
                                measure,
                                style: const pw.TextStyle(fontSize: 8.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
            for (var index = 0; index < meeting.decisions.length; index++)
              _numberedItem(
                hasMeasures ? index + 1 : index,
                meeting.decisions[index],
              ),
            for (var index = 0; index < subjectDecisions.length; index++) ...[
              _numberedItem(
                (hasMeasures ? 1 : 0) + meeting.decisions.length + index,
                subjectDecisions[index].text,
              ),
              if (subjectDecisions[index].hasRows)
                _subjectDecisionTable(subjectDecisions[index])
              else
                _subjectDecisionNote(subjectDecisions[index].emptyText),
            ],
          ],
          pw.SizedBox(height: 20),
          _sectionTitle('KATILIMCILAR VE İMZALAR'),
          pw.SizedBox(height: 8),
          _signatureTable(attendees),
          pw.SizedBox(height: 22),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(3),
            ),
            child: pw.Text(
              'Bu tutanak toplantıda görüşülen gündem maddeleri ve alınan '
              'kararları kayıt altına almak amacıyla düzenlenmiştir.',
              style: const pw.TextStyle(
                fontSize: 8.5,
                color: PdfColors.grey800,
              ),
            ),
          ),
        ],
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              school,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
            pw.Text(
              'Sayfa ${context.pageNumber} / ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          ],
        ),
      ),
    );
    return document;
  }

  static pw.Widget _keyValueCell(String label, String value) {
    if (label.isEmpty && value.isEmpty) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 6),
        child: pw.Text(''),
      );
    }
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label: ',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 8.5,
              ),
            ),
            pw.TextSpan(
              text: value,
              style: const pw.TextStyle(fontSize: 8.5),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _sectionTitle(String title) => pw.Container(
    width: double.infinity,
    margin: const pw.EdgeInsets.only(bottom: 8),
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey300,
      borderRadius: pw.BorderRadius.circular(3),
    ),
    child: pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 9.5,
        fontWeight: pw.FontWeight.bold,
        letterSpacing: 0.4,
      ),
    ),
  );

  static pw.Widget _numberedItem(int index, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(left: 8, bottom: 5),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 18,
          child: pw.Text(
            '${index + 1}.',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
        pw.Expanded(
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
        ),
      ],
    ),
  );

  static pw.Widget _emptyLine() => pw.Padding(
    padding: const pw.EdgeInsets.only(left: 8, bottom: 5),
    child: pw.Text('-', style: const pw.TextStyle(fontSize: 9)),
  );

  /// Ders bulunmadığında kararın altına yazılan açıklama.
  static pw.Widget _subjectDecisionNote(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(left: 26, bottom: 6),
    child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
  );

  /// Karar altındaki ders tablosu (ders adı, öğretmen(ler), ders saatleri).
  static pw.Widget _subjectDecisionTable(BepSubjectDecision decision) {
    final wide = decision.columns.length > 3;
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 26, bottom: 8),
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
        columnWidths: wide
            ? const {
                0: pw.FlexColumnWidth(2.6),
                1: pw.FlexColumnWidth(2.6),
                2: pw.FlexColumnWidth(2.6),
                3: pw.FlexColumnWidth(1.6),
                4: pw.FlexColumnWidth(2),
              }
            : const {
                0: pw.FlexColumnWidth(3),
                1: pw.FlexColumnWidth(3),
                2: pw.FlexColumnWidth(1.4),
              },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey300),
            children: [
              for (final column in decision.columns) _cell(column, bold: true),
            ],
          ),
          for (var index = 0; index < decision.rows.length; index++)
            pw.TableRow(
              decoration: index.isOdd
                  ? const pw.BoxDecoration(color: PdfColors.grey100)
                  : null,
              children: [
                for (final value in decision.rows[index]) _cell(value),
              ],
            ),
        ],
      ),
    );
  }

  static pw.Widget _cell(String value, {bool bold = false}) => pw.Padding(
    padding: const pw.EdgeInsets.all(5),
    child: pw.Text(
      value,
      style: pw.TextStyle(
        fontSize: 8.5,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );

  static (String, String) _extractNameAndTitle(String rawName) {
    final match = RegExp(r'^(.*?)\s*\((.*?)\)$').firstMatch(rawName.trim());
    if (match != null) {
      return (match.group(1)!.trim(), match.group(2)!.trim());
    }
    return (rawName.trim(), '');
  }

  static List<BepAttendeeSignature> _buildAttendees({
    required BepMeeting meeting,
    List<SchoolStaff> staff = const [],
    String? classTeacherName,
  }) {
    final attendees = <BepAttendeeSignature>[];

    // 1. İdari kadro ve psikolojik danışmanlar
    for (final raw in meeting.staffAttendees) {
      if (raw.trim().isEmpty) continue;
      final (rawName, existingTitle) = _extractNameAndTitle(raw);
      String role = existingTitle;
      if (role.isEmpty) {
        final matched = staff.where((s) {
          final sName = s.fullName.toLowerCase();
          final rName = rawName.toLowerCase();
          return sName == rName ||
              toTurkishTitleCase(s.fullName) == toTurkishTitleCase(rawName);
        }).firstOrNull;
        role = matched?.role.label ?? 'Psikolojik Danışman';
      }
      attendees.add(
        BepAttendeeSignature(
          name: toTurkishTitleCase(rawName),
          title: role,
        ),
      );
    }

    // 2. Veliler
    for (final raw in meeting.parentAttendees) {
      if (raw.trim().isEmpty) continue;
      final (rawName, existingTitle) = _extractNameAndTitle(raw);
      attendees.add(
        BepAttendeeSignature(
          name: toTurkishTitleCase(rawName),
          title: existingTitle.isNotEmpty ? existingTitle : 'Veli',
        ),
      );
    }

    // 3. Öğretmenler
    for (final raw in meeting.teacherNames) {
      if (raw.trim().isEmpty) continue;
      final (rawName, existingTitle) = _extractNameAndTitle(raw);
      String role = existingTitle;
      if (role.isEmpty) {
        final isClassTeacher = classTeacherName != null &&
            (rawName.toLowerCase() == classTeacherName.toLowerCase() ||
                toTurkishTitleCase(rawName) ==
                    toTurkishTitleCase(classTeacherName));
        role = isClassTeacher ? 'Sınıf Rehber Öğretmeni' : 'Ders Öğretmeni';
      }
      attendees.add(
        BepAttendeeSignature(
          name: toTurkishTitleCase(rawName),
          title: role,
        ),
      );
    }

    return attendees;
  }

  static pw.Widget _signatureTable(List<BepAttendeeSignature> attendees) {
    final participants = attendees.isEmpty
        ? const [BepAttendeeSignature(name: '', title: '')]
        : attendees;
    final rows = <pw.TableRow>[];
    for (var index = 0; index < participants.length; index += 2) {
      rows.add(
        pw.TableRow(
          children: [
            for (var offset = 0; offset < 2; offset++)
              _signatureCell(
                index + offset < participants.length
                    ? participants[index + offset]
                    : const BepAttendeeSignature(name: '', title: ''),
              ),
          ],
        ),
      );
    }
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.5),
      columnWidths: const {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(1)},
      children: rows,
    );
  }

  static pw.Widget _signatureCell(BepAttendeeSignature attendee) {
    final titleCasedName = toTurkishTitleCase(attendee.name);
    final text = attendee.title.isNotEmpty
        ? '$titleCasedName (${attendee.title})'
        : titleCasedName;
    return pw.Container(
      height: 68,
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            attendee.name.isEmpty ? 'Katılımcı Adı Soyadı:' : text,
            style: const pw.TextStyle(fontSize: 8.5),
          ),
          pw.Spacer(),
          pw.Text(
            'İmza: ____________________',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  static List<String> _parseMeasures(String? text) {
    if (text == null) return const [];
    final trimmed = text.trim();
    if (trimmed.isEmpty) return const [];
    if (trimmed.contains('\n')) {
      return trimmed
          .split('\n')
          .map((line) => line.trim().replaceFirst(RegExp(r'^[•\-\*]\s*'), ''))
          .where((line) => line.isNotEmpty)
          .toList();
    }
    if (trimmed.contains(',')) {
      return trimmed
          .split(',')
          .map((part) => part.trim().replaceFirst(RegExp(r'^[•\-\*]\s*'), ''))
          .where((part) => part.isNotEmpty)
          .toList();
    }
    return [trimmed.replaceFirst(RegExp(r'^[•\-\*]\s*'), '')];
  }

  static String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '-';
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
