import 'package:flutter/material.dart';

import '../models/cart.dart';
import '../models/receipt.dart';
import '../models/transaction_store.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/payment_sheets.dart';
import '../widgets/receipt_sheet.dart';

const _sheetShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
);

Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  Color background = Colors.white,
  double radius = 24,
  bool locked = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: !locked,
    enableDrag: !locked,
    backgroundColor: background,
    barrierColor: const Color(0x99000000),
    constraints: const BoxConstraints(maxWidth: 448),
    shape: radius == 24
        ? _sheetShape
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(radius))),
    builder: builder,
  );
}

/// Pembayaran Kasir (pembayaran.html): nota, pilih metode, sheet tunai/QRIS, struk.
/// Berisi Total Transaksi, Jumlah Pembayaran, dan Kembali (pada sheet tunai).
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.cart, required this.kasir});

  final Cart cart;
  final String kasir;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final DateTime _time = DateTime.now();
  late final String _invoice = invoiceNumber(_time, widget.cart.hashCode);
  bool _finishing = false;

  Future<void> _payCash() async {
    final tendered = await showAppSheet<int>(
      context,
      builder: (_) => CashPaymentSheet(total: widget.cart.total),
    );
    if (tendered == null || !mounted) return;
    await _finish(method: 'Tunai', tendered: tendered);
  }

  Future<void> _payQris() async {
    final ok = await showAppSheet<bool>(
      context,
      builder: (_) => QrisPaymentSheet(total: widget.cart.total),
    );
    if (ok != true || !mounted) return;
    await _finish(method: 'QRIS', tendered: widget.cart.total);
  }

  Future<void> _finish({required String method, required int tendered}) async {
    if (_finishing) return;
    _finishing = true;
    final cart = widget.cart;

    final receipt = ReceiptData(
      invoice: _invoice,
      time: _time,
      kasir: widget.kasir,
      lines: [
        for (final l in cart.lines)
          ReceiptLine(name: l.product.name, qty: l.qty, price: l.product.price),
      ],
      subtotal: cart.subtotal,
      tax: cart.tax,
      total: cart.total,
      method: method,
      tendered: tendered,
      change: method == 'Tunai' ? tendered - cart.total : 0,
    );

    TransactionStore.instance.add(receipt);
    showPillToast(
      context,
      method == 'Tunai'
          ? 'Transaksi tunai berhasil: struk siap dicetak.'
          : 'QRIS terverifikasi! Pembayaran ${rupiah(cart.total)} berhasil lunas.',
    );

    await showAppSheet<void>(
      context,
      background: const Color(0xFFF5F5F5),
      locked: true,
      builder: (_) => ReceiptSheet(data: receipt),
    );

    cart.checkout(); // kurangi stok + kosongkan keranjang
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _cancel() {
    widget.cart.clear();
    Navigator.of(context).pop();
  }

  Widget _navBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xE6F2F2F7),
        border: Border(bottom: BorderSide(color: Color(0x99E5E5EA))),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.of(context).pop(),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.chevron_left,
                            size: 28, color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pembayaran Kasir',
                        style: TextStyle(
                          fontSize: 17,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'WarungKuh',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: AppColors.subtle),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.separator),
                      ),
                      child: const AvatarImage(size: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 640;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _navBar(),
          Expanded(
            child: ListenableBuilder(
              listenable: widget.cart,
              builder: (context, _) {
                final cart = widget.cart;
                if (cart.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shopping_bag_outlined,
                            size: 56, color: AppColors.subtle),
                        const SizedBox(height: 12),
                        const Text('Belum ada pesanan'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Kembali ke Katalog'),
                        ),
                      ],
                    ),
                  );
                }
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 448),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                      children: [
                        _OrderCard(
                          cart: cart,
                          invoice: _invoice,
                          onRemoveLine: (line) =>
                              widget.cart.decrement(line.product),
                        ),
                        const SizedBox(height: 16),
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'PILIH METODE PEMBAYARAN',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                              color: AppColors.subtle,
                            ),
                          ),
                        ),
                        _MethodTile(
                          icon: Icons.qr_code_2,
                          color: const Color(0xFFDC2626),
                          bg: const Color(0xFFFFFFFF),
                          border: const Color(0xFFE5E5EA),
                          title: 'Bayar via QRIS',
                          subtitle: 'Tap untuk buka kode QR pembayaran',
                          onTap: _payQris,
                        ),
                        const SizedBox(height: 10),
                        _MethodTile(
                          icon: Icons.payments,
                          color: const Color(0xFFB45309),
                          bg: const Color(0xFFFFFFFF),
                          border: const Color(0xFFE5E5EA),
                          title: 'Bayar via Tunai / Cash',
                          subtitle: 'Tap untuk kalkulator kembalian & laci',
                          onTap: _payCash,
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: TextButton.icon(
                            onPressed: _cancel,
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Batalkan Pesanan'),
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard(
      {required this.cart, required this.invoice, required this.onRemoveLine});

  final Cart cart;
  final String invoice;
  final void Function(CartLine line) onRemoveLine;

  Widget _kv(String l, String r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.subtle)),
            Text(r,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral800)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final lines = cart.lines;
    return Container(
      decoration: cardBox(radius: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'NOTA TRANSAKSI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: AppColors.subtle,
                  ),
                ),
                Flexible(
                  child: Text(
                    '#$invoice',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xB3E5E5EA)),
          Container(
            width: double.infinity,
            color: const Color(0xFFFAFAFC),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Column(
              children: [
                for (var i = 0; i < lines.length; i++)
                  _LineRow(
                      line: lines[i],
                      last: i == lines.length - 1,
                      onRemove: () => onRemoveLine(lines[i])),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xB3E5E5EA))),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _kv('Subtotal (${cart.itemCount} Item)', rupiah(cart.subtotal)),
                _kv('PB1 (10%)', rupiah(cart.tax)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0x80E5E5EA))),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL TRANSAKSI',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: AppColors.subtle,
                        ),
                      ),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            rupiah(cart.total),
                            style: const TextStyle(
                              fontSize: 26,
                              height: 1,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: AppColors.neutral900,
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _LineRow extends StatelessWidget {
  const _LineRow(
      {required this.line, required this.last, required this.onRemove});

  final CartLine line;
  final bool last;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final p = line.product;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      margin: EdgeInsets.only(bottom: last ? 0 : 8),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: Color(0x80E5E5EA))),
      ),
      child: Row(
        children: [
          // tombol hapus item dari nota (dahulu nomor urut)
          _RemoveLineButton(onTap: onRemove),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral900,
                  ),
                ),
                Text(
                  '${line.qty}x @ ${rupiah(p.price)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.subtle),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 70),
            child: Text(
              rupiah(line.total),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol bulat kecil berikon "−" untuk menghapus baris dari nota.
class _RemoveLineButton extends StatelessWidget {
  const _RemoveLineButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE5E5E5),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: Icon(
            Icons.remove,
            size: 15,
            color: Color(0xFF525252),
          ),
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.icon,
    required this.color,
    required this.bg,
    required this.border,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : action = null;

  final IconData icon;
  final Color color;
  final Color bg;
  final Color border;
  final String title;
  final String subtitle;
  final String? action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: cardBox(),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.subtle),
                    ),
                  ],
                ),
              ),
              if (action != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    action!,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: color),
                  ),
                ),
              const Icon(Icons.chevron_right,
                  size: 20, color: AppColors.subtle),
            ],
          ),
        ),
      ),
    );
  }
}
