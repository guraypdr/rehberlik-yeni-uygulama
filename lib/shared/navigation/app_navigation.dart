import 'package:flutter/material.dart';

import '../../features/home/presentation/home_page.dart';
import '../../features/todos/presentation/todos_page.dart';

/// Sol menüdeki bir modülü tanımlar.
class AppDestination {
  const AppDestination({
    required this.id,
    required this.label,
    required this.icon,
    required this.builder,
  });

  /// Benzersiz kimlik; seçili sayfayı tutan durum bu değerle eşleşir.
  final String id;

  /// Menüde ve sayfa başlığında görünen Türkçe metin.
  final String label;
  final IconData icon;
  final WidgetBuilder builder;
}

/// Uygulama açılışında seçili olan modül.
const String initialDestinationId = 'home';

/// Modül listesi ve sırası burada belirlenir.
///
/// Yeni bir modül eklemek için yalnızca bu listeye yeni bir [AppDestination]
/// eklemek yeterlidir: menü, seçim durumu ve sayfa geçişi merkezî olarak
/// yönetilir. Sonraki aşamalarda Öğrenciler, Görüşmeler, Öğrenci Takibi,
/// Notlar, Raporlar, Takvim ve Ayarlar modülleri de bu listeye eklenecek.
/// Ayarlar gibi sürekli kullanılacak modüller listenin sonuna konulacaktır.
const List<AppDestination> appDestinations = <AppDestination>[
  AppDestination(
    id: 'home',
    label: 'Ana Sayfa',
    icon: Icons.dashboard_outlined,
    builder: _buildHomePage,
  ),
  AppDestination(
    id: 'todos',
    label: 'Yapılacaklar',
    icon: Icons.checklist_rtl_outlined,
    builder: _buildTodosPage,
  ),
];

/// Kimliğe göre modül arar. Bulunamazsa `null` döner.
AppDestination? appDestinationById(String id) {
  for (final destination in appDestinations) {
    if (destination.id == id) {
      return destination;
    }
  }
  return null;
}

Widget _buildHomePage(BuildContext context) => const HomePage();

Widget _buildTodosPage(BuildContext context) => const TodosPage();
