import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../session/last_file_store.dart';
import '../session/session_state.dart';
import '../../features/setup/data/school_profile_dao.dart';
import 'theme_provider.dart';

export '../session/session_state.dart';
export '../session/last_file_store.dart';

/// LastFileStore provider.
final lastFileStoreProvider = Provider<LastFileStore>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LastFileStore(prefs);
});

/// Oturum notifier — aktif dosya ve okul bilgisini yönetir.
class SessionNotifier extends AsyncNotifier<SessionState> {
  @override
  Future<SessionState> build() async {
    final store = ref.read(lastFileStoreProvider);
    final lastPath = store.lastFile;

    if (lastPath == null) {
      return const SessionState();
    }

    // Son dosya var — mevcut mu kontrol et.
    if (!File(lastPath).existsSync()) {
      // Dosya bulunamadı, listeden çıkar ama hata fırlatma.
      await store.removeFile(lastPath);
      return const SessionState();
    }

    return _openFile(lastPath);
  }

  /// Verilen yolda yeni bir veritabanı dosyası oluşturur ve profili kaydeder.
  Future<void> createNewFile({
    required String filePath,
    required SchoolProfileDaoInput input,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = await AppDatabase.open(filePath);
      final dao = SchoolProfileDao(db);
      await dao.insertProfileAndGradeLevels(input.toProfile());

      final store = ref.read(lastFileStoreProvider);
      await store.pushFile(filePath);

      return SessionState(
        filePath: filePath,
        database: db,
        schoolProfile: input.toProfile(),
      );
    });
  }

  /// Var olan bir dosyayı açar.
  Future<void> openFile(String filePath) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _openFile(filePath);
      final store = ref.read(lastFileStoreProvider);
      await store.pushFile(filePath);
      return result;
    });
  }

  Future<SessionState> _openFile(String filePath) async {
    final db = await AppDatabase.open(filePath);
    final dao = SchoolProfileDao(db);
    final profile = await dao.fetchProfile();
    return SessionState(
      filePath: filePath,
      database: db,
      schoolProfile: profile,
    );
  }

  /// Aktif dosyayı kapatır (oturum temizlenir, dosya silinmez).
  Future<void> closeFile() async {
    final current = state.valueOrNull;
    if (current?.database != null) {
      await current!.database!.close();
    }
    state = const AsyncValue.data(SessionState());
  }
}

final sessionProvider = AsyncNotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);

/// Aktif veritabanına kısayol — null ise dosya açık değil.
final databaseProvider = Provider<AppDatabase?>((ref) {
  return ref.watch(sessionProvider).valueOrNull?.database;
});
