import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/session_provider.dart';
import '../data/bep_meeting_dao.dart';
import '../domain/bep_meeting.dart';

class BepMeetingsNotifier extends AsyncNotifier<List<BepMeeting>> {
  BepMeetingDao? _dao;

  @override
  Future<List<BepMeeting>> build() async {
    final database = ref.watch(databaseProvider);
    if (database == null) return [];
    _dao = BepMeetingDao(database);
    return _dao!.fetchAll();
  }

  Future<void> addMeeting({
    required int studentId,
    required List<int> teacherIds,
    required String meetingDate,
    required List<String> agendaItems,
    required List<String> decisions,
    List<String> parentAttendees = const [],
    List<String> staffAttendees = const [],
  }) async {
    final dao = _dao;
    if (dao == null) {
      throw StateError('Açık bir veritabanı bulunamadı.');
    }
    await dao.insert(
      studentId: studentId,
      teacherIds: teacherIds,
      meetingDate: meetingDate,
      agendaItems: agendaItems,
      decisions: decisions,
      parentAttendees: parentAttendees,
      staffAttendees: staffAttendees,
    );
    state = AsyncValue.data(await dao.fetchAll());
  }

  Future<void> deleteMeeting(int meetingId) async {
    final dao = _dao;
    if (dao == null) {
      throw StateError('Açık bir veritabanı bulunamadı.');
    }
    await dao.delete(meetingId);
    state = AsyncValue.data(await dao.fetchAll());
  }

  Future<void> updateMeeting({
    required int meetingId,
    required int studentId,
    required List<int> teacherIds,
    required String meetingDate,
    required List<String> agendaItems,
    required List<String> decisions,
    List<String> parentAttendees = const [],
    List<String> staffAttendees = const [],
  }) async {
    final dao = _dao;
    if (dao == null) {
      throw StateError('Açık bir veritabanı bulunamadı.');
    }
    await dao.update(
      meetingId: meetingId,
      studentId: studentId,
      teacherIds: teacherIds,
      meetingDate: meetingDate,
      agendaItems: agendaItems,
      decisions: decisions,
      parentAttendees: parentAttendees,
      staffAttendees: staffAttendees,
    );
    state = AsyncValue.data(await dao.fetchAll());
  }
}

final bepMeetingsProvider =
    AsyncNotifierProvider<BepMeetingsNotifier, List<BepMeeting>>(
      BepMeetingsNotifier.new,
    );
