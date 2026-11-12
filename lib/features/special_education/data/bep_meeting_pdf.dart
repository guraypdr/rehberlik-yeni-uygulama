import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/bep_meeting.dart';
import '../domain/bep_subject_decision.dart';
import '../domain/student_subject_need.dart';

class BepMeetingPdf {
  const BepMeetingPdf._();

  static Future<pw.Document> build({
    required BepMeeting meeting,
    required int meetingNumber,
    List<StudentSubjectNeed> subjectNeeds = const [],
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
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'BEP TOPLANTI TUTANAĞI',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.6),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
            },
            children: [
              _infoRow(['Öğrenci Adı Soyadı', 'Sınıf / Şube', 'Öğrenci No']),
              _valueRow([
                meeting.studentName,
                meeting.className,
                meeting.studentNumber,
              ]),
              _infoRow(['Doğum Tarihi', 'Cinsiyeti', 'Toplantı Tarihi']),
              _valueRow([
                _formatDate(meeting.studentBirthDate),
                meeting.studentGender,
                _formatDate(meeting.meetingDate),
              ]),
              _infoRow(['Toplantı No', '', '']),
              _valueRow(['$meetingNumber', '', '']),
            ],
          ),
          pw.SizedBox(height: 18),
          _sectionTitle('GÖRÜŞÜLEN GÜNDEM MADDELERİ'),
          if (meeting.agendaItems.isEmpty)
            _emptyLine()
          else
            for (var index = 0; index < meeting.agendaItems.length; index++)
              _numberedItem(index, meeting.agendaItems[index]),
          pw.SizedBox(height: 14),
          _sectionTitle('ALINAN KARARLAR'),
          if (meeting.decisions.isEmpty && subjectNeeds.isEmpty)
            _emptyLine()
          else ...[
            for (var index = 0; index < meeting.decisions.length; index++)
              _numberedItem(index, meeting.decisions[index]),
            for (var index = 0; index < subjectDecisions.length; index++) ...[
              _numberedItem(
                meeting.decisions.length + index,
                subjectDecisions[index].text,
              ),
              if (subjectDecisions[index].hasRows)
                _subjectDecisionTable(subjectDecisions[index].rows)
              else
                _subjectDecisionNote(subjectDecisions[index].emptyText),
            ],
          ],
          pw.SizedBox(height: 20),
          _sectionTitle('KATILIMCILAR VE İMZALAR'),
          pw.SizedBox(height: 8),
          _signatureTable([
            ...meeting.staffAttendees,
            ...meeting.parentAttendees,
            ...meeting.teacherNames,
          ]),
          pw.SizedBox(height: 24),
          pw.Text(
            'Bu tutanak toplantıda görüşülen gündem maddeleri ve alınan '
            'kararları kayıt altına almak amacıyla düzenlenmiştir.',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Sayfa ${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ),
      ),
    );
    return document;
  }

  static pw.TableRow _infoRow(List<String> labels) => pw.TableRow(
    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
    children: [
      for (final label in labels)
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
        ),
    ],
  );

  static pw.TableRow _valueRow(List<String> values) => pw.TableRow(
    children: [
      for (final value in values)
        pw.Padding(
          padding: const pw.EdgeInsets.all(7),
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
        ),
    ],
  );

  static pw.Widget _sectionTitle(String title) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 7),
    child: pw.Text(
      title,
      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
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

  /// Karar altındaki ders tablosu (ders adı, öğretmen, ders saati).
  static pw.Widget _subjectDecisionTable(List<BepSubjectDecisionRow> rows) =>
      pw.Padding(
        padding: const pw.EdgeInsets.only(left: 26, bottom: 8),
        child: pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
          columnWidths: const {
            0: pw.FlexColumnWidth(3),
            1: pw.FlexColumnWidth(3),
            2: pw.FlexColumnWidth(1.4),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _cell('Ders Adı', bold: true),
                _cell('Dersi Verecek Öğretmen', bold: true),
                _cell('Ders Saati', bold: true),
              ],
            ),
            for (final row in rows)
              pw.TableRow(
                children: [
                  _cell(row.subjectName),
                  _cell(row.teacherName),
                  _cell('${row.weeklyHours}'),
                ],
              ),
          ],
        ),
      );

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

  static pw.Widget _signatureTable(List<String> names) {
    final participants = names.isEmpty ? [''] : names;
    final rows = <pw.TableRow>[];
    for (var index = 0; index < participants.length; index += 2) {
      rows.add(
        pw.TableRow(
          children: [
            for (var offset = 0; offset < 2; offset++)
              _signatureCell(
                index + offset < participants.length
                    ? participants[index + offset]
                    : '',
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

  static pw.Widget _signatureCell(String name) => pw.Container(
    height: 66,
    padding: const pw.EdgeInsets.all(8),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          name.isEmpty ? 'Katılımcı Adı Soyadı:' : name,
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.Spacer(),
        pw.Text(
          'İmza: ____________________',
          style: const pw.TextStyle(fontSize: 8),
        ),
      ],
    ),
  );

  static String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '-';
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
