import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rehberlik_app/core/database/app_database.dart';
import 'package:rehberlik_app/features/teachers/data/teacher_dao.dart';
import 'package:rehberlik_app/features/teachers/domain/teacher.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('öğretmen iletişim bilgilerini kaydeder ve geri okur', () async {
    final directory = await Directory.systemTemp.createTemp();
    final database = await AppDatabase.open(
      p.join(directory.path, 'teacher_contacts.db'),
    );

    try {
      final dao = TeacherDao(database);
      final teacher = await dao.insert(
        name: 'Ayşe',
        surname: 'Yılmaz',
        branch: 'Türkçe',
        email: 'ayse@example.com',
        phone: '05551234567',
      );

      expect(teacher.email, 'ayse@example.com');
      expect(teacher.phone, '05551234567');
      final rows = await database.db.query(
        'teachers',
        where: 'id = ?',
        whereArgs: [teacher.id],
      );
      expect(rows.single['branch'], 'Türkçe');
      expect(rows.single['email'], 'ayse@example.com');
      expect(rows.single['phone'], '05551234567');
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });

  test('öğretmenleri toplu olarak veritabanına kaydeder', () async {
    final directory = await Directory.systemTemp.createTemp();
    final database = await AppDatabase.open(
      p.join(directory.path, 'teacher_batch.db'),
    );

    try {
      final dao = TeacherDao(database);
      final count = await dao.insertBatch([
        const Teacher(
          id: 0,
          name: 'Ayşe',
          surname: 'Yılmaz',
          branch: 'Türkçe',
          email: 'ayse@example.com',
          phone: '05551234567',
        ),
        const Teacher(
          id: 0,
          name: 'Mehmet',
          surname: 'Kaya',
          branch: 'Matematik',
        ),
      ]);

      expect(count, 2);
      final teachers = await dao.fetchAll();
      expect(teachers, hasLength(2));
      expect(teachers.first.fullName, 'Mehmet Kaya');
      expect(teachers.last.email, 'ayse@example.com');
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });
}
