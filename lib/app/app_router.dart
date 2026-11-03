import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/session_provider.dart';
import '../features/setup/presentation/setup_page.dart';
import '../features/welcome/presentation/welcome_page.dart';
import '../shared/layout/app_shell.dart';

/// Rota isimleri.
abstract final class AppRoutes {
  static const welcome = '/';
  static const setup = '/setup';
  static const home = '/home';
}

final routerProvider = Provider<GoRouter>((ref) {
  // sessionProvider değiştiğinde router yeniden değerlendirilir.
  final sessionAsync = ref.watch(sessionProvider);

  return GoRouter(
    initialLocation: AppRoutes.welcome,
    refreshListenable: _ProviderListenable(ref, sessionProvider),
    redirect: (context, state) {
      final session = sessionAsync.valueOrNull;

      // Yükleniyor → bekle (redirect yapma).
      if (sessionAsync.isLoading) return null;

      final loc = state.matchedLocation;

      // Dosya açık ve kurulum tamamsa → shell'e git.
      if (session != null && session.hasOpenFile && session.isSetupComplete) {
        if (loc == AppRoutes.welcome || loc == AppRoutes.setup) {
          return AppRoutes.home;
        }
        return null;
      }

      // Dosya açık ama kurulum yok → setup (bu normalde olmamalı).
      if (session != null && session.hasOpenFile && !session.isSetupComplete) {
        if (loc != AppRoutes.setup) return AppRoutes.setup;
        return null;
      }

      // Dosya yok → welcome.
      if (loc != AppRoutes.welcome && loc != AppRoutes.setup) {
        return AppRoutes.welcome;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: AppRoutes.setup,
        builder: (context, state) => const SetupPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const AppShell(),
      ),
    ],
  );
});

/// GoRouter'ın [refreshListenable]'ı için Riverpod köprüsü.
class _ProviderListenable extends ChangeNotifier {
  _ProviderListenable(Ref ref, ProviderListenable provider) {
    ref.listen(provider, (prev, next) => notifyListeners());
  }
}
