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

    test('öğrenci bilgi formu doluluk oranını hesaplar', () {
      const student = Student(
        id: 1,
        classId: 2,
        number: '101',
        name: 'Ahmet',
        surname: 'Yılmaz',
        createdAt: '2026-11-03',
      );
      final partial = Student(
        id: 1,
        classId: 2,
        number: '101',
        name: 'Ahmet',
        surname: 'Yılmaz',
        createdAt: '2026-11-03',
        birthDate: '2010-01-01',
        preschoolEducation: true,
        usesRegularMedication: false,
        hasChronicIllness: false,
        likesActivities: 'Kitap okumak',
      );
      expect(student.studentInfoFormCompletion, 0);
      expect(partial.studentInfoFormCompletion, greaterThan(0));
      expect(partial.studentInfoFormCompletion, lessThan(100));

      final complete = Student(
        id: 1,
        classId: 2,
        number: '101',
        name: 'Ahmet',
        surname: 'Yılmaz',
        createdAt: '2026-11-03',
        birthPlace: 'Ankara',
        birthDate: '2010-01-01',
        address: 'Çankaya',
        preschoolEducation: true,
        hasSpecialEducation: true,
        usesRegularMedication: false,
        hasChronicIllness: false,
        likesActivities: 'Kitap okumak',
        hasRecentMoveOrSchoolChange: false,
        extracurricularActivities: 'Spor',
        hasTechnologyDevice: true,
        technologyUsageMinutes: 120,
        hasInfluentialEvent: false,
        motherName: 'Ayşe',
        motherSurname: 'Yılmaz',
        motherBirthPlace: 'Ankara',
        motherBirthDate: '1980-01-01',
        motherIsAlive: true,
        motherIsBiological: true,
        motherHasDisability: false,
        motherEducation: 'Lisans',
        motherJob: 'Öğretmen',
        fatherName: 'Mehmet',
        fatherSurname: 'Yılmaz',
        fatherBirthPlace: 'İzmir',
        fatherBirthDate: '1978-01-01',
        fatherIsAlive: true,
        fatherIsBiological: true,
        fatherHasDisability: false,
        fatherEducation: 'Lisans',
        fatherJob: 'Memur',
        siblingCount: 1,
        childOrder: 1,
        familyHasChronicIllness: false,
        householdMembers: 'Anne, baba ve öğrenci',
      );
      expect(complete.studentInfoFormCompletion, 100);
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
        boardingStatus: 'Yatılı',
        birthPlace: 'Ankara',
        address: 'Çankaya',
        birthDate: '2010-01-01',
        preschoolEducation: true,
        hasSpecialEducation: true,
        likesActivities: 'Kitap okumak',
        hasRecentMoveOrSchoolChange: false,
        motherBirthPlace: 'Ankara',
        motherBirthDate: '1980-01-01',
        motherEducation: 'Lisans',
        fatherBirthPlace: 'İzmir',
        fatherBirthDate: '1978-01-01',
        fatherEducation: 'Lisans',
        siblingCount: 2,
        childOrder: 1,
        familyHasChronicIllness: false,
        chronicIllnessDetails: 'Astım',
        createdAt: '2026-11-03',
      );
      final map = student.toMap();
      final formMap = student.toInfoFormMap();
      final fromMap = Student.fromMap({
        ...map,
        ...formMap,
        'preschool_education': 1,
        'has_recent_move_or_school_change': 0,
        'family_has_chronic_illness': 0,
      });

      expect(map.keys, {
        'id',
        'class_id',
        'number',
        'name',
        'surname',
        'gender',
        'boarding_status',
        'created_at',
      });
      expect(fromMap.id, student.id);
      expect(fromMap.classId, student.classId);
      expect(fromMap.number, student.number);
      expect(fromMap.fullName, 'Zeynep Kaya');
      expect(fromMap.gender, 'Kız');
      expect(fromMap.boardingStatus, 'Yatılı');
      expect(fromMap.birthPlace, 'Ankara');
      expect(fromMap.address, 'Çankaya');
      expect(fromMap.preschoolEducation, isTrue);
      expect(fromMap.hasSpecialEducation, isTrue);
      expect(fromMap.likesActivities, 'Kitap okumak');
      expect(fromMap.motherBirthPlace, 'Ankara');
      expect(fromMap.motherBirthDate, '1980-01-01');
      expect(fromMap.motherEducation, 'Lisans');
      expect(fromMap.fatherBirthPlace, 'İzmir');
      expect(fromMap.fatherBirthDate, '1978-01-01');
      expect(fromMap.fatherEducation, 'Lisans');
      expect(fromMap.siblingCount, 2);
      expect(fromMap.childOrder, 1);
      expect(fromMap.familyHasChronicIllness, isFalse);
      expect(fromMap.hasChronicIllness, isNull);
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
