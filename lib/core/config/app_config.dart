/// Uygulama yapılandırması.
///
/// Supabase bağlantı bilgileri kaynak koda gömülmez; derleme anında
/// `--dart-define` ile verilir:
///
/// ```
/// flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
/// ```
///
/// Aşama 1'de bu değerler yalnızca okunur ve hiçbir yerde bağlantı kurulmaz.
/// Böylece anahtarlar widget veya sayfa dosyalarına dağılmaz; Supabase
/// eklendiğinde tek yerden yönetilir.
class AppConfig {
  const AppConfig({required this.supabaseUrl, required this.supabaseAnonKey});

  static const AppConfig current = AppConfig(
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabaseAnonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  final String supabaseUrl;
  final String supabaseAnonKey;

  /// Supabase bağlantı bilgileri tanımlı mı?
  bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
