import '../database/app_database.dart';
import '../../features/setup/domain/school_profile.dart';

/// Uygulamanın oturum durumu: hangi dosya açık, okul profili nedir.
class SessionState {
  const SessionState({
    this.filePath,
    this.database,
    this.schoolProfile,
  });

  /// Açık `.rdb` dosyasının tam yolu. null → henüz dosya açılmadı.
  final String? filePath;

  /// Aktif SQLite bağlantısı.
  final AppDatabase? database;

  /// Veritabanından okunan okul profili.
  final SchoolProfile? schoolProfile;

  bool get hasOpenFile => filePath != null && database != null;
  bool get isSetupComplete => schoolProfile != null;

  SessionState copyWith({
    String? filePath,
    AppDatabase? database,
    SchoolProfile? schoolProfile,
    bool clearFile = false,
  }) {
    return SessionState(
      filePath: clearFile ? null : (filePath ?? this.filePath),
      database: clearFile ? null : (database ?? this.database),
      schoolProfile: clearFile ? null : (schoolProfile ?? this.schoolProfile),
    );
  }
}
