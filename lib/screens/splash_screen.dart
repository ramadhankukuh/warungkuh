import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

/// 1. Splash screen (logo, animasi gelombang kopi & teks selamat datang).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entry;
  late final AnimationController _wave;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _boot();
  }

  Future<void> _boot() async {
    await Future<void>.delayed(const Duration(milliseconds: 2400));
    final logged = await AuthService.isLoggedIn();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) =>
            logged ? const DashboardScreen() : const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _entry.dispose();
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const brown = Color(0xFF4A2405);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Latar gradasi krem -> putih.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF8EFE6), Color(0xFFFDFBF8)],
              ),
            ),
          ),
          // Pilar cahaya lembut di belakang logo.
          Positioned(
            top: -140,
            child: Transform.translate(
              offset: const Offset(-60, 0),
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x3DE8B15A), Color(0x00E8B15A)],
                  ),
                ),
              ),
            ),
          ),
          // Dua gelombang kopi yang naik perlahan dari bawah layar.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _wave,
              builder: (context, _) {
                return CustomPaint(
                  painter: _WavePainter(
                    t: _wave.value,
                    color: brown,
                    opacity: 0.12,
                    speed: 1.0,
                    lift: 0.16,
                  ),
                  child: const SizedBox.expand(),
                );
              },
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _wave,
              builder: (context, _) {
                return CustomPaint(
                  painter: _WavePainter(
                    t: _wave.value,
                    color: brown,
                    opacity: 0.08,
                    speed: 1.6,
                    lift: 0.07,
                  ),
                  child: const SizedBox.expand(),
                );
              },
            ),
          ),
          // Konten utama: logo + teks + indikator.
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _entry,
                      curve: Curves.easeOut,
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.08),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(parent: _entry, curve: Curves.easeOut),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo miring ala stiker dengan bayangan organik.
                          Transform.rotate(
                            angle: -0.06,
                            child: Container(
                              width: 128,
                              height: 128,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(36),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x2E4A2405),
                                    blurRadius: 28,
                                    offset: Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(36),
                                child: Image.asset(
                                  'assets/logo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'selamat datang di',
                            style: TextStyle(
                              color: brown.withValues(alpha: 0.55),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'WarungKuh',
                            style: TextStyle(
                              color: brown,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.2,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 44),
                          // Titik-titik "menyeduh" sebagai indikator loading.
                          AnimatedBuilder(
                            animation: _wave,
                            builder: (context, _) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(3, (i) {
                                  final phase =
                                      (_wave.value * 3 - i * 0.35) % 1.0;
                                  final bounce =
                                      math.sin(phase * math.pi).abs();
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: 7 + 3 * bounce,
                                    height: 7 + 3 * bounce,
                                    decoration: BoxDecoration(
                                      color: brown.withValues(
                                          alpha: 0.25 + 0.5 * bounce),
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Text(
                    'Menyiapkan kasir...',
                    style: TextStyle(
                      color: brown.withValues(alpha: 0.4),
                      fontSize: 12,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Gelombang sinus yang bergeser terus dan naik-turun mengikuti [t].
class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.t,
    required this.color,
    required this.opacity,
    required this.speed,
    required this.lift,
  });

  final double t;
  final Color color;
  final double opacity;
  final double speed;
  final double lift;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = t * speed * 2 * math.pi;
    final amplitude = size.height * 0.05;
    final base = size.height * (1 - lift) +
        math.sin(t * speed * math.pi) * size.height * 0.02;
    final paint = Paint()..color = color.withValues(alpha: opacity);
    final path = Path()..moveTo(0, size.height);
    path.lineTo(0, base);
    for (double x = 0; x <= size.width; x += 6) {
      final y = base +
          amplitude * math.sin(x / size.width * 2 * math.pi + phase) +
          amplitude *
              0.5 *
              math.sin(x / size.width * 5 * math.pi - phase * 0.7);
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => oldDelegate.t != t;
}
