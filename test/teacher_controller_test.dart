import 'package:flutter_test/flutter_test.dart';
import 'package:rehberlik_app/features/teachers/domain/teacher.dart';

void main() {
  group('Teacher domain modeli', () {
    const teacher = Teacher(id: 1, name: 'Ahmet', surname: 'Yılmaz');

    test('fullName ad ve soyadı birleştirir', () {
      expect(teacher.fullName, 'Ahmet Yılmaz');
    });

    test('copyWith doğru çalışır', () {
      final updated = teacher.copyWith(name: 'Mehmet');
      expect(updated.name, 'Mehmet');
      expect(updated.surname, 'Yılmaz');
      expect(updated.id, 1);
    });

    test('fromMap / toMap dönüşümü tutarlı', () {
      final map = teacher.toMap();
      final restored = Teacher.fromMap(map);
      expect(restored, teacher);
    });
  });
}
