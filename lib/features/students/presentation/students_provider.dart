import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/session_provider.dart';
import '../data/interview_dao.dart';
import '../data/student_dao.dart';
import '../domain/student.dart';
import '../domain/student_interview.dart';

/// Tüm öğrenciler listesi notifier.
class StudentsNotifier extends AsyncNotifier<List<Student>> {
  StudentDao? _dao;

  @override
  Future<List<Student>> build() async {
    final db = ref.watch(databaseProvider);
    if (db == null) return [];
    _dao = StudentDao(db);
    return _dao!.fetchAll();
  }

  /// Temel bilgilerle yeni öğrenci ekler.
  Future<Student?> addBasicStudent({
    required int classId,
    required String number,
    required String name,
    required String surname,
    required String gender,
    String boardingStatus = 'Gündüzlü',
  }) async {
    if (_dao == null) return null;
    final created = await _dao!.insertBasic(
      classId: classId,
      number: number,
      name: name,
      surname: surname,
      gender: gender,
      boardingStatus: boardingStatus,
    );
    final all = await _dao!.fetchAll();
    state = AsyncValue.data(all);
    return created;
  }

  /// Toplu öğrenci ekler (Excel/CSV içe aktarımı için).
  Future<int> addBatch(List<Student> list) async {
    if (_dao == null || list.isEmpty) return 0;
    final count = await _dao!.insertBatch(list);
    final all = await _dao!.fetchAll();
    state = AsyncValue.data(all);
    return count;
  }

  /// Öğrenci detaylarını günceller.
  Future<void> updateStudent(Student student) async {
    if (_dao == null) return;
    await _dao!.update(student);
    final all = await _dao!.fetchAll();
    state = AsyncValue.data(all);
  }

  /// Öğrenci siler.
  Future<void> deleteStudent(int id) async {
    if (_dao == null) return;
    await _dao!.delete(id);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(current.where((s) => s.id != id).toList());
  }

  /// Tek bir öğrenciyi güncel veriyle getirir.
  Future<Student?> getStudent(int id) async {
    if (_dao == null) return null;
    return _dao!.getById(id);
  }
}

final studentsProvider = AsyncNotifierProvider<StudentsNotifier, List<Student>>(
  StudentsNotifier.new,
);

/// Belirli bir öğrencinin görüşme kayıtları notifier'ı.
class StudentInterviewsNotifier
    extends FamilyAsyncNotifier<List<StudentInterview>, int> {
  InterviewDao? _dao;

  @override
  Future<List<StudentInterview>> build(int arg) async {
    final db = ref.watch(databaseProvider);
    if (db == null) return [];
    _dao = InterviewDao(db);
    return _dao!.fetchByStudentId(arg);
  }

  Future<void> addInterview({
    required String type,
    required String date,
    required String subject,
    required String notes,
    String? actionPlan,
  }) async {
    if (_dao == null) return;
    final created = await _dao!.insert(
      studentId: arg,
      type: type,
      date: date,
      subject: subject,
      notes: notes,
      actionPlan: actionPlan,
    );
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data([created, ...current]);
  }

  Future<void> deleteInterview(int id) async {
    if (_dao == null) return;
    await _dao!.delete(id);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(current.where((i) => i.id != id).toList());
  }
}

final studentInterviewsProvider =
    AsyncNotifierProviderFamily<
      StudentInterviewsNotifier,
      List<StudentInterview>,
      int
    >(StudentInterviewsNotifier.new);
