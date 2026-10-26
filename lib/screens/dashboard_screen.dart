import 'package:flutter/material.dart';

import '../config.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../services/auth_service.dart';
import '../utils/format.dart';
import '../utils/launcher.dart';
import '../widgets/common.dart';
import '../widgets/product_detail_sheet.dart';
import '../widgets/shell_widgets.dart';
import 'catalog_page.dart';
import 'login_screen.dart';
import 'payment_screen.dart';
import 'tab_pages.dart';
import 'update_user_screen.dart';

/// Dashboard (katalog.html): 4 tab — Katalog, Transaksi, Laporan, Bantuan.
/// - Menu pojok kanan atas (⋯): Call Center, SMS Center, Lokasi/Maps, Update User & Password
/// - Ketuk nama produk  -> deskripsi produk
/// - Ketuk gambar       -> tambah ke Total Pembelian (dock bawah)
/// - Ketuk dock         -> form pembayaran
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Cart _cart = Cart();
  UserProfile? _profile;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _cart.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final p = await AuthService.profile();
    if (!mounted) return;
    setState(() => _profile = p);
  }

  String get _subtitle {
    final nama = _profile?.nama ?? '';
    return nama.isEmpty ? 'WarungKuh • Semarang' : 'Kasir: $nama';
  }

  // ---------------------------------------------------------------- actions

  void _add(Product p) {
    final ok = _cart.add(p);
    showPillToast(
      context,
      ok ? '+1 ${p.fullName} (${rupiah(p.price)})' : 'Stok ${p.fullName} habis',
    );
  }

  void _remove(Product p) {
    if (_cart.qtyOf(p) == 0) return;
    _cart.decrement(p);
    showPillToast(context, '-1 ${p.fullName}');
  }

  void _showDetail(Product p) {
    showAppSheet<void>(
      context,
      radius: 32,
      builder: (_) => ProductDetailSheet(
        product: p,
        remaining: p.stock - _cart.qtyOf(p),
        onAdd: () => _add(p),
      ),
    );
  }

  Future<void> _openPayment() async {
    if (_cart.isEmpty) {
      showPillToast(
          context, 'Belum ada penjualan. Ketuk foto produk untuk menambah.');
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            PaymentScreen(cart: _cart, kasir: _profile?.nama ?? 'Kasir'),
      ),
    );
    if (mounted) setState(() {});
  }

  void _openMenu() {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup menu',
      barrierColor: const Color(0x00000000),
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (ctx, _, __) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 64, right: 16),
              child: QuickMenu(
                onClose: () => Navigator.of(ctx).pop(),
                onSelect: (v) {
                  Navigator.of(ctx).pop();
                  _onMenu(v);
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: ScaleTransition(
          alignment: Alignment.topRight,
          scale: Tween<double>(begin: 0.92, end: 1).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOut),
          ),
          child: child,
        ),
      ),
    );
  }

  Future<void> _onMenu(String value) async {
    switch (value) {
      case 'call':
        await openExternal(context, Uri(scheme: 'tel', path: kStorePhone));
        break;
      case 'sms':
        const body = 'Halo WarungKuh, saya ingin memesan: ';
        await openExternal(
          context,
          Uri.parse('sms:$kStorePhone?body=${Uri.encodeComponent(body)}'),
        );
        break;
      case 'maps':
        await openExternal(
          context,
          Uri.https('www.google.com', '/maps/search/', {
            'api': '1',
            'query': kStoreMapQuery,
          }),
        );
        break;
      case 'user':
        final changed = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(builder: (_) => const UpdateUserScreen()),
        );
        if (changed == true) _loadProfile();
        break;
      case 'logout':
        await _logout();
        break;
    }
  }

  Future<void> _logout() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Anda akan keluar dari akun kasir ini.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Keluar')),
        ],
      ),
    );
    if (yes != true) return;
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _tab,
              children: [
                CatalogPage(
                  cart: _cart,
                  subtitle: _subtitle,
                  onMenu: _openMenu,
                  onAdd: _add,
                  onRemove: _remove,
                  onDetail: _showDetail,
                ),
                HistoryPage(subtitle: _subtitle, onMenu: _openMenu),
                ReportPage(subtitle: _subtitle, onMenu: _openMenu),
                HelpPage(subtitle: _subtitle, onMenu: _openMenu),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 448),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_tab == 0) ...[
                          CheckoutDock(cart: _cart, onTap: _openPayment),
                          const SizedBox(height: 12),
                        ],
                        FloatingTabBar(
                          index: _tab,
                          onChanged: (i) => setState(() => _tab = i),
                        ),
                      ],
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
