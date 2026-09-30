import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/theme/app_theme.dart';
import '../shared/layout/app_shell.dart';

/// Uygulamanın kök widget'ı.
class RehberlikApp extends StatelessWidget {
  const RehberlikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rehberlik',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // İleride koyu tema eklendiğinde yalnızca bu satır güncellenecek;
      // renkler merkezî olarak tanımlandığı için widget'lar değişmez.
      themeMode: ThemeMode.light,
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AppShell(),
    );
  }
}
