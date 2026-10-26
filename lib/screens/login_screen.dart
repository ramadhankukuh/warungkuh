import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'dashboard_screen.dart';

/// 2. Login & registrasi user (Shared Preferences).
///
/// Default adalah login; pindah mode lewat tautan
/// "Belum punya akun? Daftar" / "Sudah punya akun? Masuk".
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.startInRegister = false});

  final bool startInRegister;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _user = TextEditingController();
  final _pass = TextEditingController();

  late bool _isRegister = widget.startInRegister;
  bool _obscure = true;
  bool _busy = false;

  late final AnimationController _entry;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _nama.dispose();
    _user.dispose();
    _pass.dispose();
    _entry.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final user = _user.text.trim();
    final pass = _pass.text;

    var ok = true;
    if (_isRegister) {
      await AuthService.register(
        nama: _nama.text.trim(),
        username: user,
        password: pass,
      );
      if (!mounted) return;
      // Setelah daftar, kembali ke form login agar user masuk manual.
      setState(() {
        _busy = false;
        _isRegister = false;
        _nama.clear();
        _user.clear();
        _pass.clear();
      });
      _formKey.currentState?.reset();
      _toast(
        'Akun "$user" berhasil dibuat. Silakan login dengan akunmu.',
      );
      return;
    }
    ok = await AuthService.login(user, pass);
    if (!mounted) return;
    setState(() => _busy = false);

    if (!ok) {
      _toast('Username atau password salah');
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const DashboardScreen()),
    );
  }

  void _toggleMode() {
    setState(() {
      _isRegister = !_isRegister;
      _nama.clear();
      _user.clear();
      _pass.clear();
      _formKey.currentState?.reset();
    });
    _entry
      ..reset()
      ..forward();
  }

  InputDecoration _decoration(String label, IconData icon, {Widget? suffix}) {
    const brown = Color(0xFF4A2405);
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: brown.withValues(alpha: 0.55)),
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: brown.withValues(alpha: 0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: brown.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF8D4B00), width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brown = Color(0xFF4A2405);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Latar gradasi krem -> putih, senada dengan splash.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF8EFE6), Color(0xFFFDFBF8)],
              ),
            ),
          ),
          // Cahaya lembut di belakang logo.
          Positioned(
            top: -160,
            child: Transform.translate(
              offset: const Offset(-70, 0),
              child: Container(
                width: 320,
                height: 320,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x3DE8B15A), Color(0x00E8B15A)],
                  ),
                ),
              ),
            ),
          ),
          // Gelombang kopi statis di bawah.
          const Positioned.fill(
            child: CustomPaint(
              painter: _StaticWavePainter(),
              child: SizedBox.expand(),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _entry,
                      curve: Curves.easeOut,
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.06),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(parent: _entry, curve: Curves.easeOut),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo miring ala stiker, senada splash.
                          Transform.rotate(
                            angle: -0.06,
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x264A2405),
                                    blurRadius: 18,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Image.asset(
                                  'assets/logo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _isRegister
                                ? 'Buat akun kasirmu'
                                : 'Selamat datang\nkembali 👋',
                            style: const TextStyle(
                              color: brown,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isRegister
                                ? 'Isi data di bawah untuk mulai pakai WarungKuh POS.'
                                : 'Masuk dulu untuk membuka kasir WarungKuh POS.',
                            style: TextStyle(
                              color: brown.withValues(alpha: 0.55),
                              fontSize: 14.5,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 26),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                if (_isRegister) ...[
                                  TextFormField(
                                    controller: _nama,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: _decoration(
                                      'Nama Lengkap',
                                      Icons.badge_outlined,
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().length < 3)
                                            ? 'Nama lengkap minimal 3 karakter'
                                            : null,
                                  ),
                                  const SizedBox(height: 14),
                                ],
                                TextFormField(
                                  controller: _user,
                                  textInputAction: TextInputAction.next,
                                  autocorrect: false,
                                  decoration: _decoration(
                                    'Username',
                                    Icons.person_outline,
                                  ),
                                  validator: (v) {
                                    final t = v?.trim() ?? '';
                                    if (t.length < 3) {
                                      return 'Username minimal 3 karakter';
                                    }
                                    if (t.contains(' ')) {
                                      return 'Username tanpa spasi';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _pass,
                                  obscureText: _obscure,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _submit(),
                                  decoration: _decoration(
                                    'Password',
                                    Icons.lock_outline,
                                    suffix: IconButton(
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 20,
                                        color: brown.withValues(alpha: 0.5),
                                      ),
                                      onPressed: () => setState(
                                        () => _obscure = !_obscure,
                                      ),
                                    ),
                                  ),
                                  validator: (v) => (v == null || v.length < 4)
                                      ? 'Password minimal 4 karakter'
                                      : null,
                                ),
                                const SizedBox(height: 22),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: brown,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: _busy ? null : _submit,
                                    child: _busy
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            _isRegister
                                                ? 'Daftar Sekarang'
                                                : 'Masuk',
                                            style: const TextStyle(
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _isRegister
                                      ? 'Sudah punya akun? '
                                      : 'Belum punya akun? ',
                                  style: TextStyle(
                                    color: brown.withValues(alpha: 0.55),
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _busy ? null : _toggleMode,
                                  child: Text(
                                    _isRegister ? 'Masuk' : 'Daftar',
                                    style: const TextStyle(
                                      color: brown,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu gelombang kopi statis sebagai penyeimbang bawah layar.
class _StaticWavePainter extends CustomPainter {
  const _StaticWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final base = size.height * 0.86;
    final amplitude = size.height * 0.04;
    final paint = Paint()
      ..color = const Color(0xFF4A2405).withValues(alpha: 0.10);
    final path = Path()..moveTo(0, size.height);
    path.lineTo(0, base);
    for (double x = 0; x <= size.width; x += 6) {
      final y = base + amplitude * math.sin(x / size.width * 2 * math.pi);
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
