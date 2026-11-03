import 'package:flutter/material.dart';

import '../../features/classes/presentation/classes_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/teachers/presentation/teachers_page.dart';
import '../../features/todos/presentation/todos_page.dart';

/// Sol menüdeki bir modülü tanımlar.
class AppDestination {
  const AppDestination({
    required this.id,
    required this.label,
    required this.icon,
    required this.builder,
  });

  final String id;
  final String label;
  final IconData icon;
  final WidgetBuilder builder;
}

/// Uygulama açılışında seçili modül.
const String initialDestinationId = 'home';

/// Modül listesi ve sırası.
const List<AppDestination> appDestinations = <AppDestination>[
  AppDestination(
    id: 'home',
    label: 'Ana Sayfa',
    icon: Icons.dashboard_outlined,
    builder: _buildHomePage,
  ),
  AppDestination(
    id: 'classes',
    label: 'Sınıflar',
    icon: Icons.meeting_room_outlined,
    builder: _buildClassesPage,
  ),
  AppDestination(
    id: 'teachers',
    label: 'Öğretmenler',
    icon: Icons.person_outline,
    builder: _buildTeachersPage,
  ),
  AppDestination(
    id: 'todos',
    label: 'Yapılacaklar',
    icon: Icons.checklist_rtl_outlined,
    builder: _buildTodosPage,
  ),
  AppDestination(
    id: 'settings',
    label: 'Ayarlar',
    icon: Icons.settings_outlined,
    builder: _buildSettingsPage,
  ),
];

Widget _buildHomePage(BuildContext context) => const HomePage();
Widget _buildClassesPage(BuildContext context) => const ClassesPage();
Widget _buildTeachersPage(BuildContext context) => const TeachersPage();
Widget _buildTodosPage(BuildContext context) => const TodosPage();
Widget _buildSettingsPage(BuildContext context) => const SettingsPage();
