import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/features/classes/data/school_risk_pdf.dart';
import 'package:rehberlik_app/features/classes/domain/school_class.dart';
import 'package:rehberlik_app/features/classes/domain/student_risk_question.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('A4 yatay okul risk haritası PDF çıktısı oluşturur', () async {
    final classes = [
      for (var index = 0; index < 24; index++)
        SchoolClass(
          id: index + 1,
          gradeLevelId: 1,
          gradeLevelLabel: '9. Sınıf',
          branch: String.fromCharCode(65 + index % 26),
        ),
    ];
    final counts = {
      for (final schoolClass in classes)
        schoolClass.id: {
          for (final question in studentRiskQuestions) question.key: 2,
        },
    };

    final document = await SchoolRiskPdf.build(
      classes: classes,
      counts: counts,
    );
    final bytes = await document.save();

    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
