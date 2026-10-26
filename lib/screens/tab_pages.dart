import 'package:flutter/material.dart';

import '../config.dart';
import '../models/receipt.dart';
import '../models/transaction_store.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../utils/launcher.dart';
import '../widgets/common.dart';
import '../widgets/shell_widgets.dart';
import 'payment_screen.dart' show showAppSheet;
import '../widgets/receipt_sheet.dart';

/// Kerangka halaman tab (header yang sama dengan katalog + judul besar).
class _TabScaffold extends StatelessWidget {
  const _TabScaffold({
    required this.title,
    required this.subtitle,
    required this.onMenu,
    required this.child,
  });

  final String title;
  final String subtitle;
  final VoidCallback onMenu;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(subtitle: subtitle, onMenu: onMenu),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  child,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          Icon(icon, size: 52, color: const Color.fromARGB(255, 14, 14, 243)),
          const SizedBox(height: 10),
          Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.subtle, fontSize: 14)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- Transaksi

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key, required this.subtitle, required this.onMenu});

  final String subtitle;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return _TabScaffold(
      title: 'Transaksi',
      subtitle: subtitle,
      onMenu: onMenu,
      child: ListenableBuilder(
        listenable: TransactionStore.instance,
        builder: (context, _) {
          final items = TransactionStore.instance.items;
          if (items.isEmpty) {
            return const _Empty(Icons.receipt_long,
                'Belum ada transaksi.\nPenjualan yang selesai akan muncul di sini.');
          }
          return Column(
            children: [for (final r in items) _HistoryTile(receipt: r)],
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.receipt});

  final ReceiptData receipt;

  @override
  Widget build(BuildContext context) {
    final qty = receipt.lines.fold<int>(0, (s, l) => s + l.qty);
    final cash = receipt.method == 'Tunai';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => showAppSheet<void>(
            context,
            background: const Color(0xFFF5F5F5),
            builder: (_) => ReceiptSheet(data: receipt),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: cardBox(),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cash
                        ? const Color(0xFFFFFBEB)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    cash ? Icons.payments : Icons.qr_code_2,
                    color: cash
                        ? const Color(0xFFB45309)
                        : const Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('#${receipt.invoice}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      Text(
                          '${formatDateTime(receipt.time)} • $qty item • ${receipt.method}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.subtle)),
                    ],
                  ),
                ),
                Text(rupiah(receipt.total),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ Laporan

class ReportPage extends StatelessWidget {
  const ReportPage({super.key, required this.subtitle, required this.onMenu});

  final String subtitle;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return _TabScaffold(
      title: 'Laporan',
      subtitle: subtitle,
      onMenu: onMenu,
      child: ListenableBuilder(
        listenable: TransactionStore.instance,
        builder: (context, _) {
          final items = TransactionStore.instance.items;
          if (items.isEmpty) {
            return const _Empty(Icons.bar_chart, 'Belum ada data penjualan.');
          }
          final omzet = items.fold<int>(0, (s, r) => s + r.total);
          final pajak = items.fold<int>(0, (s, r) => s + r.tax);
          final qty = items.fold<int>(
              0, (s, r) => s + r.lines.fold<int>(0, (a, l) => a + l.qty));
          final cash = items
              .where((r) => r.method == 'Tunai')
              .fold<int>(0, (s, r) => s + r.total);
          final qris = omzet - cash;

          final perProduct = <String, int>{};
          for (final r in items) {
            for (final l in r.lines) {
              perProduct[l.name] = (perProduct[l.name] ?? 0) + l.qty;
            }
          }
          final top = perProduct.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          Widget stat(String label, String value, {Color? color}) => Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: cardBox(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: AppColors.subtle)),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(value,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                color: color ?? Colors.black)),
                      ),
                    ],
                  ),
                ),
              );

          return Column(
            children: [
              Row(children: [
                stat('TOTAL PENJUALAN', rupiah(omzet),
                    color: AppColors.primary),
                const SizedBox(width: 10),
                stat('TRANSAKSI', '${items.length}'),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                stat('ITEM TERJUAL', '$qty'),
                const SizedBox(width: 10),
                stat('PB1 TERKUMPUL', rupiah(pajak)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                stat('TUNAI', rupiah(cash)),
                const SizedBox(width: 10),
                stat('QRIS', rupiah(qris)),
              ]),
              const SizedBox(height: 18),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text('MENU TERLARIS',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: AppColors.subtle)),
                ),
              ),
              Container(
                decoration: cardBox(),
                child: Column(
                  children: [
                    for (var i = 0; i < top.length; i++) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Text('${i + 1}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.subtle)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(top[i].key,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ),
                            Text('${top[i].value} terjual',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      if (i != top.length - 1)
                        const Divider(height: 1, color: Color(0xB3E5E5EA)),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------------ Bantuan

class HelpPage extends StatelessWidget {
  const HelpPage({super.key, required this.subtitle, required this.onMenu});

  final String subtitle;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return _TabScaffold(
      title: 'Bantuan',
      subtitle: subtitle,
      onMenu: onMenu,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: cardBox(),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.storefront, color: Colors.white),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(kStoreName,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      SizedBox(height: 2),
                      Text(kStoreAddress,
                          style:
                              TextStyle(fontSize: 12, color: AppColors.subtle)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: cardBox(),
            child: Column(
              children: [
                ActionRow(
                  icon: Icons.call,
                  iconColor: const Color(0xFF059669),
                  iconBg: const Color(0xFFECFDF5),
                  title: 'Call Center',
                  subtitle: kStorePhoneDisplay,
                  onTap: () => openExternal(
                      context, Uri(scheme: 'tel', path: kStorePhone)),
                ),
                ActionRow(
                  icon: Icons.sms,
                  iconColor: const Color(0xFF2563EB),
                  iconBg: const Color(0xFFEFF6FF),
                  title: 'SMS Center',
                  subtitle: 'Kirim pesan order',
                  onTap: () =>
                      openExternal(context, Uri.parse('sms:$kStorePhone')),
                ),
                ActionRow(
                  icon: Icons.chat,
                  iconColor: const Color(0xFF16A34A),
                  iconBg: const Color(0xFFF0FDF4),
                  title: 'WhatsApp',
                  subtitle: 'Chat dengan warung',
                  onTap: () => openExternal(context,
                      Uri.parse('https://wa.me/62${kStorePhone.substring(1)}')),
                ),
                ActionRow(
                  icon: Icons.near_me,
                  iconColor: const Color(0xFFEA580C),
                  iconBg: const Color(0xFFFFF7ED),
                  title: 'Lokasi / Maps Agen',
                  subtitle: 'Kalibanteng, Semarang',
                  onTap: () => openExternal(
                    context,
                    Uri.https('www.google.com', '/maps/search/', {
                      'api': '1',
                      'query': kStoreMapQuery,
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tips: ketuk foto produk untuk menambah ke Total Jual, tahan foto untuk mengurangi, '
            'ketuk nama produk untuk melihat deskripsi, lalu ketuk Total Pembelian untuk membayar.',
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 12, height: 1.5, color: AppColors.subtle),
          ),
        ],
      ),
    );
  }
}
