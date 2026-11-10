import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/school_class.dart';
import '../domain/student_risk_question.dart';
import 'school_risk_dao.dart';

class SchoolRiskPdf {
  const SchoolRiskPdf._();

  static Future<pw.Document> build({
    required List<SchoolClass> classes,
    required SchoolRiskCounts counts,
  }) async {
    final pageFormat = PdfPageFormat.a4.landscape;
    const margin = 18.0;
    const classWidth = 58.0;
    const headerHeight = 126.0;
    const rowHeight = 22.0;
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Lato-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Lato-Bold.ttf'),
    );
    final riskWidth =
        (pageFormat.width - margin * 2 - classWidth) /
        studentRiskQuestions.length;
    final rowsPerPage =
        ((pageFormat.height - margin * 2 - headerHeight - 38) / rowHeight)
            .floor();
    final document = pw.Document(
      theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
    );

    for (var start = 0; start < classes.length; start += rowsPerPage) {
      final pageClasses = classes.skip(start).take(rowsPerPage).toList();
      document.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(margin),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(
                'Okul Risk Haritası',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey500,
                  width: 0.35,
                ),
                columnWidths: {
                  0: const pw.FixedColumnWidth(classWidth),
                  for (
                    var column = 1;
                    column <= studentRiskQuestions.length;
                    column++
                  )
                    column: pw.FixedColumnWidth(riskWidth),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      pw.Container(
                        height: headerHeight,
                        alignment: pw.Alignment.bottomLeft,
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Sınıf',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      for (final question in studentRiskQuestions)
                        pw.Container(
                          height: headerHeight,
                          alignment: pw.Alignment.center,
                          child: pw.Transform.rotate(
                            angle: -math.pi / 2,
                            child: pw.SizedBox(
                              width: headerHeight - 8,
                              child: pw.Text(
                                question.label,
                                textAlign: pw.TextAlign.center,
                                maxLines: 2,
                                style: const pw.TextStyle(fontSize: 6.5),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  for (final schoolClass in pageClasses)
                    pw.TableRow(
                      children: [
                        pw.Container(
                          height: rowHeight,
                          alignment: pw.Alignment.centerLeft,
                          padding: const pw.EdgeInsets.symmetric(horizontal: 4),
                          child: pw.Text(
                            schoolClass.displayName,
                            style: pw.TextStyle(
                              fontSize: 7,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        for (final question in studentRiskQuestions)
                          pw.Container(
                            height: rowHeight,
                            alignment: pw.Alignment.center,
                            child: pw.Text(
                              '${counts[schoolClass.id]?[question.key] ?? 0}',
                              style: const pw.TextStyle(fontSize: 7),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              pw.Spacer(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Sayfa ${context.pageNumber}',
                  style: const pw.TextStyle(
                    fontSize: 7,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return document;
  }
}
