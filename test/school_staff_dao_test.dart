import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rehberlik_app/core/database/app_database.dart';
import 'package:rehberlik_app/features/settings/data/school_staff_dao.dart';
import 'package:rehberlik_app/features/settings/domain/school_staff.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('müdür tek, müdür yardımcısı ve danışman çoklu kaydedilir', () async {
    final directory = await Directory.systemTemp.createTemp();
    final database = await AppDatabase.open(
      p.join(directory.path, 'school_staff.db'),
    );

    try {
      final dao = SchoolStaffDao(database);
      await dao.savePrincipal(name: 'Ahmet', surname: 'Yılmaz');
      await dao.savePrincipal(name: 'Mehmet', surname: 'Demir');
      await dao.addMember(
        role: SchoolStaffRole.vicePrincipal,
        name: 'Ayşe',
        surname: 'Kaya',
      );
      await dao.addMember(
        role: SchoolStaffRole.vicePrincipal,
        name: 'Ali',
        surname: 'Vural',
      );
      await dao.addMember(
        role: SchoolStaffRole.counselor,
        name: 'Elif',
        surname: 'Şahin',
      );

      final staff = await dao.fetchAll();
      final principals = staff
          .where((member) => member.role == SchoolStaffRole.principal)
          .toList();
      expect(principals, hasLength(1));
      expect(principals.single.fullName, 'Mehmet Demir');
      expect(staff.first.role, SchoolStaffRole.principal);
      expect(
        staff.where((member) => member.role == SchoolStaffRole.vicePrincipal),
        hasLength(2),
      );
      expect(
        staff
            .where((member) => member.role == SchoolStaffRole.counselor)
            .single
            .fullName,
        'Elif Şahin',
      );

      await dao.update(
        id: principals.single.id,
        name: 'Mehmet',
        surname: 'Kaya',
      );
      expect((await dao.fetchAll()).first.fullName, 'Mehmet Kaya');

      await dao.delete(principals.single.id);
      expect(await dao.fetchAll(), hasLength(3));
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });
}
