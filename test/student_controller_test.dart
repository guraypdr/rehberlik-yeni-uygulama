import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/features/students/domain/student.dart';
import 'package:rehberlik_app/features/students/domain/student_interview.dart';

void main() {
  group('Student domain modeli', () {
    test('fullName ad ve soyadı birleştirir', () {
      const student = Student(
        id: 1,
        classId: 2,
        number: '101',
        name: 'Ahmet',
        surname: 'Yılmaz',
        createdAt: '2026-11-03',
      );
      expect(student.fullName, 'Ahmet Yılmaz');
    });

    test('copyWith doğru çalışır', () {
      const student = Student(
        id: 1,
        classId: 2,
        number: '101',
        name: 'Ahmet',
        surname: 'Yılmaz',
        createdAt: '2026-11-03',
      );
      final updated = student.copyWith(name: 'Mehmet', number: '102');
      expect(updated.name, 'Mehmet');
      expect(updated.surname, 'Yılmaz');
      expect(updated.number, '102');
      expect(updated.id, 1);
    });

    test('fromMap / toMap dönüşümü tutarlıdır', () {
      const student = Student(
        id: 1,
        classId: 2,
        number: '101',
        name: 'Zeynep',
        surname: 'Kaya',
        gender: 'Kız',
        status: 'Aktif',
        hasChronicIllness: true,
        chronicIllnessDetails: 'Astım',
        createdAt: '2026-11-03',
      );
      final map = student.toMap();
      final fromMap = Student.fromMap(map);

      expect(fromMap.id, student.id);
      expect(fromMap.classId, student.classId);
      expect(fromMap.number, student.number);
      expect(fromMap.fullName, 'Zeynep Kaya');
      expect(fromMap.gender, 'Kız');
      expect(fromMap.hasChronicIllness, isTrue);
      expect(fromMap.chronicIllnessDetails, 'Astım');
    });
  });

  group('StudentInterview domain modeli', () {
    test('typeLabel doğru etiketleri üretir', () {
      const i1 = StudentInterview(
        id: 1,
        studentId: 1,
        type: 'student',
        date: '2026-11-03',
        subject: 'Uyum',
        notes: 'Notlar',
        createdAt: '2026-11-03',
      );
      const i2 = StudentInterview(
        id: 2,
        studentId: 1,
        type: 'parent',
        date: '2026-11-03',
        subject: 'Veli',
        notes: 'Notlar',
        createdAt: '2026-11-03',
      );
      const i3 = StudentInterview(
        id: 3,
        studentId: 1,
        type: 'teacher',
        date: '2026-11-03',
        subject: 'Öğretmen',
        notes: 'Notlar',
        createdAt: '2026-11-03',
      );

      expect(i1.typeLabel, 'Bireysel Görüşme');
      expect(i2.typeLabel, 'Veli Görüşmesi');
      expect(i3.typeLabel, 'Öğretmen Görüşmesi');
    });

    test('fromMap / toMap dönüşümü tutarlıdır', () {
      const interview = StudentInterview(
        id: 1,
        studentId: 2,
        type: 'parent',
        date: '2026-11-03',
        subject: 'Devamsızlık',
        notes: 'Veli ile görüşüldü',
        actionPlan: 'Haftalık takip',
        createdAt: '2026-11-03',
      );
      final map = interview.toMap();
      final fromMap = StudentInterview.fromMap(map);

      expect(fromMap.id, interview.id);
      expect(fromMap.studentId, interview.studentId);
      expect(fromMap.type, 'parent');
      expect(fromMap.subject, 'Devamsızlık');
      expect(fromMap.actionPlan, 'Haftalık takip');
    });
  });
}

