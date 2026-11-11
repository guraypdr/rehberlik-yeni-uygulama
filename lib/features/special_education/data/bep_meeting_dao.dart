import 'dart:convert';

import '../../../core/database/app_database.dart';
import '../domain/bep_meeting.dart';

class BepMeetingDao {
  const BepMeetingDao(this._database);

  final AppDatabase _database;

  Future<List<BepMeeting>> fetchAll() async {
    final rows = await _database.db.rawQuery('''
      SELECT
        m.id,
        m.student_id,
        s.name || ' ' || s.surname AS student_name,
        s.number AS student_number,
        g.label || ' / ' || c.branch AS class_name,
        m.meeting_date,
        m.agenda_items,
        m.decisions,
        m.created_at,
        COALESCE(
          GROUP_CONCAT(t.name || ' ' || t.surname, '|||'),
          ''
        ) AS teacher_names
      FROM bep_meetings m
      JOIN students s ON s.id = m.student_id
      JOIN classes c ON c.id = s.class_id
      JOIN grade_levels g ON g.id = c.grade_level_id
      LEFT JOIN bep_meeting_teachers mt ON mt.meeting_id = m.id
      LEFT JOIN teachers t ON t.id = mt.teacher_id
      GROUP BY m.id
      ORDER BY m.meeting_date DESC, m.id DESC
    ''');
    return rows.map(_fromRow).toList();
  }

  Future<void> insert({
    required int studentId,
    required List<int> teacherIds,
    required String meetingDate,
    required List<String> agendaItems,
    required List<String> decisions,
  }) async {
    if (teacherIds.isEmpty) {
      throw ArgumentError('En az bir öğretmen toplantıya katılmalıdır.');
    }
    if (agendaItems.isEmpty) {
      throw ArgumentError('En az bir gündem maddesi seçilmelidir.');
    }

    await _database.db.transaction((txn) async {
      final meetingId = await txn.insert('bep_meetings', {
        'student_id': studentId,
        'meeting_date': meetingDate,
        'agenda_items': jsonEncode(agendaItems),
        'decisions': jsonEncode(decisions),
        'created_at': DateTime.now().toIso8601String(),
      });
      final batch = txn.batch();
      for (final teacherId in teacherIds.toSet()) {
        batch.insert('bep_meeting_teachers', {
          'meeting_id': meetingId,
          'teacher_id': teacherId,
        });
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> delete(int meetingId) async {
    await _database.db.delete(
      'bep_meetings',
      where: 'id = ?',
      whereArgs: [meetingId],
    );
  }

  BepMeeting _fromRow(Map<String, Object?> row) {
    final agendaItems = jsonDecode(row['agenda_items']! as String) as List;
    final decisions = jsonDecode(row['decisions']! as String) as List;
    final teacherNames = (row['teacher_names']! as String)
        .split('|||')
        .where((name) => name.isNotEmpty)
        .toList();
    return BepMeeting(
      id: row['id']! as int,
      studentId: row['student_id']! as int,
      studentName: row['student_name']! as String,
      studentNumber: row['student_number']! as String,
      className: row['class_name']! as String,
      meetingDate: row['meeting_date']! as String,
      agendaItems: agendaItems.cast<String>(),
      decisions: decisions.cast<String>(),
      teacherNames: teacherNames,
      createdAt: row['created_at']! as String,
    );
  }
}
