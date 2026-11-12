import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/session_provider.dart';
import '../data/class_subject_dao.dart';
import '../domain/class_subject.dart';

class ClassSubjectsNotifier
    extends FamilyAsyncNotifier<List<ClassSubject>, int> {
  ClassSubjectDao? _dao;

  @override
  Future<List<ClassSubject>> build(int classId) async {
    final database = ref.watch(databaseProvider);
    if (database == null) return [];
    _dao = ClassSubjectDao(database);
    return _dao!.fetchForClass(classId);
  }

  Future<void> add({
    required int classId,
    required String subjectName,
    required int weeklyHours,
    int? teacherId,
  }) async {
    final current = state.valueOrNull ?? <ClassSubject>[];
    final created = await _requireDao().insert(
      classId: classId,
      subjectName: subjectName,
      weeklyHours: weeklyHours,
      teacherId: teacherId,
    );
    state = AsyncValue.data(_sort([...current, created]));
  }

  Future<void> saveSubject({
    required ClassSubject subject,
    required String subjectName,
    required int weeklyHours,
    int? teacherId,
  }) async {
    final updated = await _requireDao().update(
      id: subject.id,
      classId: subject.classId,
      subjectName: subjectName,
      weeklyHours: weeklyHours,
      teacherId: teacherId,
    );
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      _sort([
        for (final item in current)
          if (item.id == updated.id) updated else item,
      ]),
    );
  }

  Future<void> addBatch({
    required int classId,
    required List<ClassSubject> subjects,
  }) async {
    if (subjects.isEmpty) return;
    final inserted = await _requireDao().insertBatch(
      classId: classId,
      subjects: subjects,
    );
    final current = state.valueOrNull ?? <ClassSubject>[];
    state = AsyncValue.data(_sort([...current, ...inserted]));
  }

  Future<void> delete(int id) async {
    await _requireDao().delete(id);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(current.where((item) => item.id != id).toList());
  }

  ClassSubjectDao _requireDao() {
    final dao = _dao;
    if (dao == null) {
      throw StateError('Açık bir veritabanı bulunamadı.');
    }
    return dao;
  }

  List<ClassSubject> _sort(List<ClassSubject> subjects) => subjects
    ..sort(
      (a, b) =>
          a.subjectName.toLowerCase().compareTo(b.subjectName.toLowerCase()),
    );
}

final classSubjectsProvider =
    AsyncNotifierProviderFamily<ClassSubjectsNotifier, List<ClassSubject>, int>(
      ClassSubjectsNotifier.new,
    );
