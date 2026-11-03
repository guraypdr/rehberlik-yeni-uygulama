import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/session_provider.dart';
import '../data/teacher_dao.dart';
import '../domain/teacher.dart';

class TeachersNotifier extends AsyncNotifier<List<Teacher>> {
  TeacherDao? _dao;

  @override
  Future<List<Teacher>> build() async {
    final db = ref.watch(databaseProvider);
    if (db == null) return [];
    _dao = TeacherDao(db);
    return _dao!.fetchAll();
  }

  Future<void> addTeacher({
    required String name,
    required String surname,
    String? branch,
  }) async {
    if (_dao == null) return;
    final created = await _dao!.insert(name: name, surname: surname, branch: branch);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      [...current, created]..sort((a, b) => a.surname.compareTo(b.surname)),
    );
  }

  Future<void> deleteTeacher(int id) async {
    if (_dao == null) return;
    await _dao!.delete(id);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(current.where((t) => t.id != id).toList());
  }
}

final teachersProvider =
    AsyncNotifierProvider<TeachersNotifier, List<Teacher>>(TeachersNotifier.new);
