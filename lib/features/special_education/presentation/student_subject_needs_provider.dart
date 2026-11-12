import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/session_provider.dart';
import '../data/student_subject_need_dao.dart';
import '../domain/student_subject_need.dart';

class StudentSubjectNeedsNotifier
    extends FamilyAsyncNotifier<List<StudentSubjectNeed>, int> {
  StudentSubjectNeedDao? _dao;

  @override
  Future<List<StudentSubjectNeed>> build(int studentId) async {
    final database = ref.watch(databaseProvider);
    if (database == null) return [];
    _dao = StudentSubjectNeedDao(database);
    return _dao!.fetchForStudent(studentId);
  }

  Future<void> setNeeds({
    required StudentSubjectNeed need,
    bool? requiresSupportEducation,
    bool? requiresBep,
    bool? isExempt,
  }) async {
    final dao = _dao;
    if (dao == null) {
      throw StateError('Açık bir veritabanı bulunamadı.');
    }
    await dao.setNeeds(
      studentId: need.studentId,
      classSubjectId: need.classSubjectId,
      requiresSupportEducation: requiresSupportEducation,
      requiresBep: requiresBep,
      isExempt: isExempt,
    );
    state = AsyncValue.data(await dao.fetchForStudent(need.studentId));
  }
}

final studentSubjectNeedsProvider =
    AsyncNotifierProviderFamily<
      StudentSubjectNeedsNotifier,
      List<StudentSubjectNeed>,
      int
    >(StudentSubjectNeedsNotifier.new);
