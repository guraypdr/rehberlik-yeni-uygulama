import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rehberlik_app/core/database/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('v2 öğrenci kayıtlarına varsayılan pansiyon durumu ekler', () async {
    final directory = await Directory.systemTemp.createTemp();
    final path = p.join(directory.path, 'legacy_students.db');
    AppDatabase? database;

    try {
      final legacyDatabase = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE students (
                id INTEGER PRIMARY KEY,
                number TEXT NOT NULL
              )
            ''');
            await db.insert('students', {'id': 1, 'number': '101'});
          },
        ),
      );
      await legacyDatabase.close();

      database = await AppDatabase.open(path);
      final rows = await database.db.query('students');

      expect(rows, hasLength(1));
      expect(rows.single['boarding_status'], 'Gündüzlü');
      expect(rows.single['number'], '101');
    } finally {
      await database?.close();
      await directory.delete(recursive: true);
    }
  });
}
