import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/session_provider.dart';
import '../data/student_risk_dao.dart';
import '../domain/student_risk_question.dart';

typedef StudentRiskAnswers = Map<int, Map<String, bool>>;

class StudentRiskNotifier extends FamilyAsyncNotifier<StudentRiskAnswers, int> {
  StudentRiskDao? _dao;

  @override
  Future<StudentRiskAnswers> build(int classId) async {
    final database = ref.watch(databaseProvider);
    if (database == null) return const {};
    _dao = StudentRiskDao(database);
    return _dao!.initializeAndFetch(
      classId: classId,
      questionKeys: [
        for (final question in studentRiskManualQuestions) question.key,
      ],
    );
  }

  Future<void> setAnswer({
    required int studentId,
    required String questionKey,
    required bool answer,
  }) async {
    final dao = _dao;
    if (dao == null) {
      throw StateError('Açık bir veritabanı bulunamadı.');
    }

    await dao.setAnswer(
      studentId: studentId,
      questionKey: questionKey,
      answer: answer,
    );
    final current = state.valueOrNull ?? const <int, Map<String, bool>>{};
    state = AsyncValue.data({
      ...current,
      studentId: {
        ...current[studentId] ?? const <String, bool>{},
        questionKey: answer,
      },
    });
  }
}

final studentRiskProvider =
    AsyncNotifierProviderFamily<StudentRiskNotifier, StudentRiskAnswers, int>(
      StudentRiskNotifier.new,
    );

final classRiskMapCompletedProvider = FutureProvider.family<bool, int>((
  ref,
  classId,
) async {
  final database = ref.watch(databaseProvider);
  if (database == null) return false;
  return StudentRiskDao(database).isClassRiskMapCompleted(classId);
});
