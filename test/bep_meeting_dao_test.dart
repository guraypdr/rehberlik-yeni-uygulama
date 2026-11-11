import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rehberlik_app/core/database/app_database.dart';
import 'package:rehberlik_app/features/special_education/data/bep_meeting_dao.dart';
import 'package:rehberlik_app/features/special_education/domain/bep_meeting.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test(
    'BEP toplantısını katılımcı, gündem ve kararlarıyla saklar ve siler',
    () async {
      final directory = await Directory.systemTemp.createTemp();
      final database = await AppDatabase.open(
        p.join(directory.path, 'bep_meetings.db'),
      );

      try {
        final gradeLevelId = await database.db.insert('grade_levels', {
          'label': '9. Sınıf',
          'sort_order': 1,
        });
        final classId = await database.db.insert('classes', {
          'grade_level_id': gradeLevelId,
          'branch': 'A',
        });
        final studentId = await database.db.insert('students', {
          'class_id': classId,
          'number': '101',
          'name': 'Ayşe',
          'surname': 'Kaya',
          'created_at': '2026-11-11',
        });
        await database.db.insert('student_info_forms', {
          'student_id': studentId,
          'birth_date': '2010-01-02',
        });
        final teacherId = await database.db.insert('teachers', {
          'name': 'Mehmet',
          'surname': 'Demir',
        });
        final secondTeacherId = await database.db.insert('teachers', {
          'name': 'Zeynep',
          'surname': 'Arı',
        });
        final agenda = [bepMeetingAgendaItems[0], bepMeetingAgendaItems[4]];
        final decisions = [bepMeetingDecisionItems[0], 'Ek karar'];
        final dao = BepMeetingDao(database);

        await dao.insert(
          studentId: studentId,
          teacherIds: [teacherId],
          meetingDate: '2026-11-11',
          agendaItems: agenda,
          decisions: decisions,
        );

        final meetings = await dao.fetchAll();
        expect(meetings, hasLength(1));
        expect(meetings.single.studentName, 'Ayşe Kaya');
        expect(meetings.single.studentNumber, '101');
        expect(meetings.single.className, '9. Sınıf / A');
        expect(meetings.single.studentBirthDate, '2010-01-02');
        expect(meetings.single.studentGender, 'Erkek');
        expect(meetings.single.teacherNames, ['Mehmet Demir']);
        expect(meetings.single.teacherIds, [teacherId]);
        expect(meetings.single.agendaItems, agenda);
        expect(meetings.single.decisions, decisions);
        final updatedAgenda = [bepMeetingAgendaItems[1]];
        final updatedDecisions = ['Güncellenen karar'];
        await dao.update(
          meetingId: meetings.single.id,
          studentId: studentId,
          teacherIds: [secondTeacherId],
          meetingDate: '2026-11-12',
          agendaItems: updatedAgenda,
          decisions: updatedDecisions,
        );
        final updatedMeeting = (await dao.fetchAll()).single;
        expect(updatedMeeting.meetingDate, '2026-11-12');
        expect(updatedMeeting.teacherIds, [secondTeacherId]);
        expect(updatedMeeting.teacherNames, ['Zeynep Arı']);
        expect(updatedMeeting.agendaItems, updatedAgenda);
        expect(updatedMeeting.decisions, updatedDecisions);
        await dao.delete(meetings.single.id);
        expect(await dao.fetchAll(), isEmpty);
        expect(await database.db.query('bep_meeting_teachers'), isEmpty);
      } finally {
        await database.close();
        await directory.delete(recursive: true);
      }
    },
  );

  test('v12 BEP kayıtlarına boş karar listesi ekler', () async {
    final directory = await Directory.systemTemp.createTemp();
    final path = p.join(directory.path, 'bep_meetings_v12.db');
    final legacyDatabase = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 12,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE bep_meetings (
              id INTEGER PRIMARY KEY,
              student_id INTEGER NOT NULL,
              meeting_date TEXT NOT NULL,
              agenda_items TEXT NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');
          await db.insert('bep_meetings', {
            'id': 1,
            'student_id': 2,
            'meeting_date': '2026-11-11',
            'agenda_items': '[]',
            'created_at': '2026-11-11',
          });
        },
      ),
    );
    await legacyDatabase.close();

    final database = await AppDatabase.open(path);
    try {
      final rows = await database.db.query('bep_meetings');
      expect(rows, hasLength(1));
      expect(rows.single['decisions'], '[]');
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });
}
