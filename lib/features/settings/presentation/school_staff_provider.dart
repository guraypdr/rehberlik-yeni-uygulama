import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/session_provider.dart';
import '../data/school_staff_dao.dart';
import '../domain/school_staff.dart';

/// Aktif okulun idari kadrosunu (müdür, müdür yardımcısı, danışman) yönetir.
///
/// Diğer sayfalar (örn. BEP toplantısı) katılımcı seçimi için bu provider'ı
/// dinleyebilir.
class SchoolStaffNotifier extends AsyncNotifier<List<SchoolStaff>> {
  SchoolStaffDao? _dao;

  @override
  Future<List<SchoolStaff>> build() async {
    final database = ref.watch(databaseProvider);
    if (database == null) return [];
    _dao = SchoolStaffDao(database);
    return _dao!.fetchAll();
  }

  SchoolStaffDao get _requireDao {
    final dao = _dao;
    if (dao == null) {
      throw StateError('Açık bir veritabanı bulunamadı.');
    }
    return dao;
  }

  Future<void> savePrincipal({
    required String name,
    required String surname,
  }) async {
    final dao = _requireDao;
    await dao.savePrincipal(name: name, surname: surname);
    state = AsyncValue.data(await dao.fetchAll());
  }

  Future<void> addMember({
    required SchoolStaffRole role,
    required String name,
    required String surname,
  }) async {
    final dao = _requireDao;
    await dao.addMember(role: role, name: name, surname: surname);
    state = AsyncValue.data(await dao.fetchAll());
  }

  Future<void> updateMember({
    required int id,
    required String name,
    required String surname,
  }) async {
    final dao = _requireDao;
    await dao.update(id: id, name: name, surname: surname);
    state = AsyncValue.data(await dao.fetchAll());
  }

  Future<void> removeMember(int id) async {
    final dao = _requireDao;
    await dao.delete(id);
    state = AsyncValue.data(await dao.fetchAll());
  }
}

final schoolStaffProvider =
    AsyncNotifierProvider<SchoolStaffNotifier, List<SchoolStaff>>(
      SchoolStaffNotifier.new,
    );
