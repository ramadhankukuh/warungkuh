import 'package:flutter/material.dart';

import '../theme.dart';
import '../utils/format.dart';
import 'common.dart';

/// Kerangka bottom sheet iOS: grabber + header + isi (pembayaran.html).
class SheetFrame extends StatelessWidget {
  const SheetFrame({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D1D6),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xB3E5E5EA))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: AppColors.neutral900,
                        ),
                      ),
                      if (subtitle != null)
                        Text(subtitle!,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.subtle)),
                    ],
                  ),
                ),
                CloseCircleButton(onTap: () => Navigator.of(context).pop()),
              ],
            ),
          ),
          Flexible(child: child),
        ],
      ),
    );
  }
}

/// Tombol gelap besar (bg-neutral-900) / tombol sekunder kecil.
class DarkButton extends StatelessWidget {
  const DarkButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.small = false,
    this.light = false,
    this.iconColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool small;
  final bool light;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final fg = light ? const Color(0xFF404040) : Colors.white;
    return Material(
      color: light ? AppColors.neutral100 : AppColors.neutral900,
      borderRadius: BorderRadius.circular(12),
      elevation: light ? 0 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          height: small ? 36 : 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: small ? 16 : 20, color: iconColor ?? fg),
              SizedBox(width: small ? 6 : 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: small ? 12 : 15,
                    fontWeight: small ? FontWeight.w500 : FontWeight.w600,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TUNAI
// ============================================================================

/// Menutup sheet dengan `int` = jumlah pembayaran bila cukup.
class CashPaymentSheet extends StatefulWidget {
  const CashPaymentSheet({super.key, required this.total});

  final int total;

  @override
  State<CashPaymentSheet> createState() => _CashPaymentSheetState();
}

class _CashPaymentSheetState extends State<CashPaymentSheet> {
  static const _keys = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'C',
    '0',
    '000',
  ];

  String _raw = '0';

  int get _tendered => int.tryParse(_raw) ?? 0;

  void _press(String k) {
    setState(() {
      if (_raw == '0') {
        _raw = k == '000' ? '0' : k;
      } else if (_raw.length < 8) {
        _raw += k;
      }
    });
  }

  void _confirm() {
    if (_tendered < widget.total) {
      showPillToast(
          context, 'Nominal kurang: uang diterima masih kurang dari tagihan.');
      return;
    }
    Navigator.of(context).pop(_tendered);
  }

  Widget _preset(String label, int amount) {
    final selected = _tendered == amount;
    return GestureDetector(
      onTap: () => setState(() => _raw = amount.toString()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.amberSoft : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary.withAlpha(102)
                : AppColors.separator,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? AppColors.primary : AppColors.neutral800,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final change = _tendered - widget.total;
    final ok = change >= 0;
    final fg = ok ? AppColors.greenDark : AppColors.red;

    return SheetFrame(
      title: 'Pembayaran Tunai',
      subtitle: 'Kalkulator Kasir & Kembalian',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.separator),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Transaksi:',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.subtle)),
                  Text(rupiah(widget.total),
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral900)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 6),
              child: Text(
                'PILIHAN UANG PAS & PECAHAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: AppColors.subtle,
                ),
              ),
            ),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                mainAxisExtent: 36,
              ),
              children: [
                _preset('Uang Pas', widget.total),
                _preset('Rp 20.000', 20000),
                _preset('Rp 50.000', 50000),
                _preset('Rp 100.000', 100000),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: cardBox(radius: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Jumlah Pembayaran:',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.subtle)),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            rupiah(_tendered),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: AppColors.neutral900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ok ? AppColors.greenLight : AppColors.redLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (ok ? AppColors.green : AppColors.red)
                            .withAlpha(51),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: (ok ? AppColors.green : AppColors.red)
                                .withAlpha(51),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(ok ? Icons.check_circle : Icons.error,
                              size: 16, color: fg),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ok ? 'Kembali' : 'Uang Kurang',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: fg)),
                            ],
                          ),
                        ),
                        Text(
                          ok ? rupiah(change) : 'Kurang ${rupiah(-change)}',
                          style: TextStyle(
                            fontSize: ok ? 19 : 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: fg,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xB3E5E5EA)),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _keys.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      mainAxisExtent: 48,
                    ),
                    itemBuilder: (context, i) {
                      final k = _keys[i];
                      return Center(
                        child: _KeyButton(
                          label: k,
                          clear: k == 'C',
                          onTap: () =>
                              k == 'C' ? setState(() => _raw = '0') : _press(k),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DarkButton(
              label: 'Konfirmasi Bayar Tunai & Cetak Struk',
              icon: Icons.print,
              onTap: _confirm,
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton(
      {required this.label, required this.onTap, this.clear = false});

  final String label;
  final VoidCallback onTap;
  final bool clear;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 48,
      child: Material(
        color: clear ? const Color(0xFFFEF2F2) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: clear ? const Color(0xFFFECACA) : const Color(0xFFE5E5E5),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: clear ? 15 : (label == '000' ? 14 : 18),
                fontWeight:
                    clear || label == '000' ? FontWeight.w700 : FontWeight.w600,
                color: clear ? const Color(0xFFDC2626) : AppColors.neutral900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// QRIS
// ============================================================================

/// Menutup sheet dengan `true` jika kasir menekan "Konfirmasi Lunas".
class QrisPaymentSheet extends StatelessWidget {
  const QrisPaymentSheet({super.key, required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return SheetFrame(
      title: 'Pembayaran QRIS',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neutral800, width: 2),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomPaint(size: Size(192, 192), painter: QrisPainter()),
                    SizedBox(height: 4),
                    Text(
                      'NMID: ID1020083948211 • WarungKuh',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.5,
                        color: Color(0xFF737373),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.separator),
              ),
              child: Column(
                children: [
                  const Text(
                    'TOTAL TAGIHAN QRIS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.subtle,
                    ),
                  ),
                  Text(
                    rupiah(total),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: AppColors.neutral900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            DarkButton(
              label: 'Konfirmasi Lunas & Cetak Struk',
              icon: Icons.check_circle,
              onTap: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
  }
}

/// QR yang sama dengan SVG pada pembayaran.html (viewBox 200x200).
class QrisPainter extends CustomPainter {
  const QrisPainter();

  static const _dots = <List<double>>[
    [70, 12],
    [90, 12],
    [115, 12],
    [70, 30],
    [100, 30],
    [120, 30],
    [80, 48],
    [110, 48],
    [12, 70],
    [30, 70],
    [48, 70],
    [70, 70],
    [95, 70],
    [115, 70],
    [140, 70],
    [160, 70],
    [180, 70],
    [12, 90],
    [40, 90],
    [70, 90],
    [120, 90],
    [150, 90],
    [175, 90],
    [25, 110],
    [50, 110],
    [75, 110],
    [100, 110],
    [135, 110],
    [165, 110],
    [70, 130],
    [95, 130],
    [120, 130],
    [145, 130],
    [175, 130],
    [70, 150],
    [105, 150],
    [135, 150],
    [160, 150],
    [180, 150],
    [70, 175],
    [95, 175],
    [125, 175],
    [150, 175],
    [175, 175],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 200;
    final black = Paint()..color = Colors.black;
    final white = Paint()..color = Colors.white;

    RRect rr(double x, double y, double s, double r) => RRect.fromRectAndRadius(
        Rect.fromLTWH(x * k, y * k, s * k, s * k), Radius.circular(r * k));

    void finder(double x, double y) {
      canvas.drawRRect(rr(x, y, 50, 6), black);
      canvas.drawRRect(rr(x + 8, y + 8, 34, 2), white);
      canvas.drawRRect(rr(x + 14, y + 14, 22, 3), black);
    }

    finder(10, 10);
    finder(140, 10);
    finder(10, 140);

    for (final d in _dots) {
      canvas.drawRRect(rr(d[0], d[1], 10, 1.5), black);
    }

    // badge "Q" di tengah
    canvas.drawRRect(rr(84, 84, 32, 6), white);
    canvas.drawRRect(
      rr(84, 84, 32, 6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * k
        ..color = const Color(0xFF1C1917),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: 'Q',
        style: TextStyle(
          color: const Color(0xFFDC2626),
          fontSize: 16 * k,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(100 * k - tp.width / 2, 100 * k - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Barcode yang sama dengan SVG pada struk (viewBox 160x40).
class BarcodePainter extends CustomPainter {
  const BarcodePainter(this.color);

  final Color color;

  static const _bars = <List<double>>[
    [0, 3],
    [5, 1],
    [8, 4],
    [15, 2],
    [19, 3],
    [25, 1],
    [28, 5],
    [36, 2],
    [41, 3],
    [47, 1],
    [51, 4],
    [58, 2],
    [63, 3],
    [68, 1],
    [72, 4],
    [79, 2],
    [84, 3],
    [90, 2],
    [94, 5],
    [102, 1],
    [106, 3],
    [112, 2],
    [117, 4],
    [124, 1],
    [128, 3],
    [134, 2],
    [138, 4],
    [145, 2],
    [150, 3],
    [156, 2],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 160;
    final sy = size.height / 40;
    final p = Paint()..color = color;
    for (final b in _bars) {
      canvas.drawRect(Rect.fromLTWH(b[0] * sx, 0, b[1] * sx, 35 * sy), p);
    }
  }

  @override
  bool shouldRepaint(covariant BarcodePainter oldDelegate) =>
      oldDelegate.color != color;
}
