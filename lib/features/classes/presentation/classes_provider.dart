import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/session_provider.dart';
import '../data/class_dao.dart';
import '../domain/grade_level.dart';
import '../domain/school_class.dart';

class ClassesState {
  const ClassesState({
    this.gradeLevels = const [],
    this.classes = const [],
  });

  final List<GradeLevel> gradeLevels;
  final List<SchoolClass> classes;
}

class ClassesNotifier extends AsyncNotifier<ClassesState> {
  ClassDao? _dao;

  @override
  Future<ClassesState> build() async {
    final db = ref.watch(databaseProvider);
    if (db == null) return const ClassesState();
    _dao = ClassDao(db);
    final levels = await _dao!.fetchGradeLevels();
    final classes = await _dao!.fetchAll();
    return ClassesState(gradeLevels: levels, classes: classes);
  }

  Future<void> addClass({
    required int gradeLevelId,
    required String gradeLevelLabel,
    required String branch,
    String? fieldName,
    int? teacherId,
  }) async {
    if (_dao == null) return;
    final created = await _dao!.insert(
      gradeLevelId: gradeLevelId,
      gradeLevelLabel: gradeLevelLabel,
      branch: branch,
      fieldName: fieldName,
      teacherId: teacherId,
    );
    final current = state.valueOrNull ?? const ClassesState();
    state = AsyncValue.data(ClassesState(
      gradeLevels: current.gradeLevels,
      classes: [...current.classes, created],
    ));
  }

  Future<void> deleteClass(int id) async {
    if (_dao == null) return;
    await _dao!.delete(id);
    final current = state.valueOrNull ?? const ClassesState();
    state = AsyncValue.data(ClassesState(
      gradeLevels: current.gradeLevels,
      classes: current.classes.where((c) => c.id != id).toList(),
    ));
  }
}

final classesProvider =
    AsyncNotifierProvider<ClassesNotifier, ClassesState>(ClassesNotifier.new);
