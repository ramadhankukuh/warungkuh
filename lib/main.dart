import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WarungKuhApp());
}

/// Agar scroll bisa dengan drag mouse (web / desktop) selain touch.
class _AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

class WarungKuhApp extends StatelessWidget {
  const WarungKuhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WarungKuh POS',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      scrollBehavior: _AppScrollBehavior(),
      home: const SplashScreen(),
    );
  }
}
