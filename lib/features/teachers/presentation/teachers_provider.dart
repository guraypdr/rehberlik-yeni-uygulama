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
    required String branch,
    String? email,
    String? phone,
  }) async {
    final dao = _dao;
    if (dao == null) {
      throw StateError('Açık bir veritabanı bulunamadı.');
    }
    final normalizedEmail = email?.trim();
    final normalizedPhone = phone?.trim();
    final created = await dao.insert(
      name: name.trim(),
      surname: surname.trim(),
      branch: branch.trim(),
      email: normalizedEmail == null || normalizedEmail.isEmpty
          ? null
          : normalizedEmail,
      phone: normalizedPhone == null || normalizedPhone.isEmpty
          ? null
          : normalizedPhone,
    );
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      [...current, created]..sort((a, b) => a.surname.compareTo(b.surname)),
    );
  }

  Future<int> addBatch(List<Teacher> teachers) async {
    final dao = _dao;
    if (dao == null) {
      throw StateError('Açık bir veritabanı bulunamadı.');
    }
    if (teachers.isEmpty) return 0;
    final count = await dao.insertBatch(
      teachers
          .map(
            (teacher) => teacher.copyWith(
              name: teacher.name.trim(),
              surname: teacher.surname.trim(),
              branch: teacher.branch?.trim(),
              email: teacher.email?.trim().isEmpty ?? true
                  ? null
                  : teacher.email!.trim(),
              phone: teacher.phone?.trim().isEmpty ?? true
                  ? null
                  : teacher.phone!.trim(),
            ),
          )
          .toList(),
    );
    final all = await dao.fetchAll();
    state = AsyncValue.data(all);
    return count;
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
