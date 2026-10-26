import 'package:flutter/material.dart';

import '../config.dart';
import '../models/receipt.dart';
import '../theme.dart';
import '../utils/format.dart';
import 'common.dart';
import 'payment_sheets.dart';

TextStyle _mono({
  double size = 12,
  FontWeight weight = FontWeight.w400,
  Color color = const Color(0xFF262626),
}) =>
    TextStyle(fontSize: size, fontWeight: weight, color: color, height: 1.5);

/// Struk transaksi (mengikuti #modal-receipt pada pembayaran.html).
class ReceiptSheet extends StatelessWidget {
  const ReceiptSheet({super.key, required this.data});

  final ReceiptData data;

  Widget _line(String l, String r,
      {FontWeight weight = FontWeight.w400,
      double size = 12,
      Color color = const Color(0xFF525252)}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Text(l,
                  style: _mono(size: size, weight: weight, color: color))),
          const SizedBox(width: 8),
          Text(r, style: _mono(size: size, weight: weight, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCash = data.method == 'Tunai';
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
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
                    border:
                        Border(bottom: BorderSide(color: Color(0xB3E5E5EA))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD1FAE5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.receipt_long,
                            size: 18, color: Color(0xFF047857)),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Struk Transaksi Selesai',
                              style: TextStyle(
                                fontSize: 17,
                                height: 1.25,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                color: AppColors.neutral900,
                              ),
                            ),
                            Text('Printer Kasir Terhubung',
                                style: TextStyle(
                                    fontSize: 11, color: AppColors.subtle)),
                          ],
                        ),
                      ),
                      CloseCircleButton(
                          onTap: () => Navigator.of(context).pop()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Container(
              color: AppColors.bg,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // status printer
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.separator),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.emerald,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Printer POS 58mm - Siap',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF404040),
                                ),
                              ),
                            ],
                          ),
                          Text('BT: POS-5802',
                              style: _mono(
                                  size: 11,
                                  weight: FontWeight.w600,
                                  color: const Color(0xFF737373))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // kertas struk
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E5EA)),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 8,
                              offset: Offset(0, 2)),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            kStoreName.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                              color: AppColors.neutral900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            kStoreAddress,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF525252)),
                          ),
                          const Text(
                            'Telp / WA: $kStorePhoneDisplay',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10, color: Color(0xFF737373)),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text('Kasir: ${data.kasir}',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF525252))),
                              ),
                              const Text('Dine In',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.neutral900,
                                  )),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text('#${data.invoice}',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF737373))),
                              ),
                              Text(formatDateTime(data.time),
                                  style: const TextStyle(
                                      fontSize: 10, color: Color(0xFF737373))),
                            ],
                          ),
                          const DashedLine(),
                          for (final l in data.lines) ...[
                            _line(l.name, rupiah(l.total),
                                weight: FontWeight.w600,
                                color: AppColors.neutral900),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text('${l.qty}x @ ${rupiah(l.price)}',
                                  style: _mono(
                                      size: 11,
                                      color: const Color(0xFF737373))),
                            ),
                          ],
                          const DashedLine(),
                          _line(
                              'Subtotal (${data.lines.fold<int>(0, (s, l) => s + l.qty)} item)',
                              rupiah(data.subtotal),
                              color: const Color(0xFF525252)),
                          _line('PB1 Restoran (10%)', rupiah(data.tax),
                              color: const Color(0xFF525252)),
                          const SizedBox(height: 4),
                          _line('TOTAL TAGIHAN', rupiah(data.total),
                              weight: FontWeight.w700,
                              size: 14,
                              color: AppColors.neutral900),
                          const DashedLine(vertical: 6),
                          _line(
                            isCash ? 'Bayar (Tunai)' : 'Bayar (QRIS Dinamis)',
                            isCash
                                ? rupiah(data.tendered)
                                : '${rupiah(data.total)} (LUNAS)',
                            weight: FontWeight.w700,
                            color: const Color(0xFF404040),
                          ),
                          if (isCash)
                            _line('Kembalian', rupiah(data.change),
                                weight: FontWeight.w700,
                                color: const Color(0xFF047857)),
                          const SizedBox(height: 14),
                          const Center(
                            child: SizedBox(
                              width: 176,
                              height: 40,
                              child: CustomPaint(
                                painter: BarcodePainter(AppColors.neutral800),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data.invoice,
                            textAlign: TextAlign.center,
                            style:
                                _mono(size: 9, color: const Color(0xFF737373))
                                    .copyWith(letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '"Thank you for your order!"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF262626),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Simpan struk ini sebagai bukti pembayaran yang sah.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10, color: Color(0xFFA3A3A3)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    DarkButton(
                      label: 'Cetak Struk Thermal',
                      icon: Icons.print,
                      onTap: () {
                        showPillToast(context,
                            'Mencetak struk: mengirim data ke printer thermal 58mm via Bluetooth... (simulasi)');
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  const _OutlineAction({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.border,
    required this.iconColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final Color border;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: iconColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: foreground,
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
