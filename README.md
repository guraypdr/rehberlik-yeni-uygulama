# Rehberlik

Rehberlik ve psikolojik danışmanlık iş takip uygulaması (Windows masaüstü).

## Aşama 1 kapsamı

- Sol menülü temel yerleşim (`Ana Sayfa`, `Yapılacaklar`)
- `Yapılacaklar` sayfası: görev ekleme, tamamlama, silme (bellek içinde)
- Merkezî tasarım sistemi (renk, tipografi, boşluk, köşe yarıçapı)
- Pencere boyutuna uyumlu arayüz
- Supabase bağlantısı için hazır yapılandırma (bağlantı kurulmaz)

## Çalıştırma

```bash
flutter pub get
flutter run -d windows
```

## Testler

```bash
flutter test
flutter analyze
```

## Supabase yapılandırması

Anahtarlar kaynak koda gömülmez, derleme anında verilir:

```bash
flutter run -d windows ^
  --dart-define=SUPABASE_URL=https://<proje>.supabase.co ^
  --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

Değerler `lib/core/config/app_config.dart` içinde okunur. Aşama 1'de bu değerler
kullanılmaz; yalnızca ileride bağlantı kurulduğunda tek yerden yönetilir.

## Klasör yapısı

```
lib/
  main.dart                       Uygulama girişi
  app/                            Kök widget ve tema bağlantısı
  core/
    config/                       Ortam ayarları (Supabase anahtarları)
    theme/                        Renk, tipografi, boşluk, yarıçap
  shared/
    di/                           Uygulama geneli bağımlılıklar (AppScope)
    layout/                       Shell ve sol menü
    navigation/                   Modül listesi (yeni modül ekleme noktası)
    widgets/                      Paylaşılan arayüz parçaları
  features/
    home/                         Ana Sayfa
    todos/                        Yapılacaklar (domain / data / presentation)
```

## Yeni modül nasıl eklenir?

`lib/shared/navigation/app_navigation.dart` içindeki `appDestinations` listesine
yeni bir `AppDestination` eklemek yeterlidir. Menü, seçim durumu ve sayfa
gösterimi merkezî olarak yönetilir; `AppShell` değişikliği gerekmez.
