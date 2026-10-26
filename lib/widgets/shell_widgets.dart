import 'package:flutter/material.dart';

import '../models/cart.dart';
import '../theme.dart';
import '../utils/format.dart';
import 'common.dart';

/// Header besar ala iOS: avatar + "WarungKuh POS" + tombol ⋯ (katalog.html <header>).
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.subtitle, required this.onMenu});

  final String subtitle;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(bottom: BorderSide(color: Color(0x0A000000))),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Color(0x1A000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 1)),
                            ],
                          ),
                          child: const AvatarImage(size: 40),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              color: AppColors.emerald,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'WarungKuh POS',
                          style: TextStyle(
                            fontSize: 20,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1,
                            fontWeight: FontWeight.w500,
                            color: AppColors.subtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: const Color(0xB3E5E5EA),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onMenu,
                      child: const SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(Icons.more_horiz,
                            size: 20, color: Color(0xCC000000)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tab bar mengambang (nav pada katalog.html), latar putih polos.
class FloatingTabBar extends StatelessWidget {
  const FloatingTabBar(
      {super.key, required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  static const _items = <({IconData icon, String label})>[
    (icon: Icons.point_of_sale, label: 'Katalog'),
    (icon: Icons.receipt_long, label: 'Transaksi'),
    (icon: Icons.bar_chart, label: 'Laporan'),
    (icon: Icons.storefront_outlined, label: 'Bantuan'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.separator),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1F000000), blurRadius: 30, offset: Offset(0, 10)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            for (var i = 0; i < _items.length; i++)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // hanya ikon yang berubah warna (coklat tema) saat aktif
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          child: Icon(
                            _items[i].icon,
                            key: ValueKey(i == index),
                            size: 22,
                            color: i == index
                                ? AppColors.primary
                                : AppColors.subtle,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _items[i].label,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 11,
                            letterSpacing: -0.2,
                            fontWeight: FontWeight.w500,
                            color: AppColors.subtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Dock "Total pembelian" (floating checkout bar). Ketuk -> form pembayaran.
class CheckoutDock extends StatelessWidget {
  const CheckoutDock({super.key, required this.cart, required this.onTap});

  final Cart cart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.separator),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 32,
                    offset: Offset(0, 8)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 6,
                            offset: Offset(0, 3)),
                      ],
                    ),
                    child: const Icon(Icons.shopping_bag,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'TOTAL PEMBELIAN',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: AppColors.subtle,
                          ),
                        ),
                        Text(
                          '${cart.itemCount} Item',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 19,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 14, 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 6,
                            offset: Offset(0, 3)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          rupiahTight(cart.subtotal),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right,
                            color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Popover "Aksi Cepat Warung" (#quick-action-popover) + menu akun.
class QuickMenu extends StatelessWidget {
  const QuickMenu({super.key, required this.onSelect, required this.onClose});

  final ValueChanged<String> onSelect;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xF2FFFFFF),
      elevation: 14,
      shadowColor: const Color(0x44000000),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 264,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x0F000000)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Aksi Cepat Warung',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                  CloseCircleButton(onTap: onClose, size: 24),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0x0A000000)),
            const SizedBox(height: 4),
            ActionRow(
              icon: Icons.call,
              iconColor: const Color(0xFF059669),
              iconBg: const Color(0xFFECFDF5),
              title: 'Call Center',
              subtitle: '+62 812-3456-789',
              onTap: () => onSelect('call'),
            ),
            ActionRow(
              icon: Icons.sms,
              iconColor: const Color(0xFF2563EB),
              iconBg: const Color(0xFFEFF6FF),
              title: 'SMS Center',
              subtitle: 'Kirim pesan order',
              onTap: () => onSelect('sms'),
            ),
            ActionRow(
              icon: Icons.near_me,
              iconColor: const Color(0xFFEA580C),
              iconBg: const Color(0xFFFFF7ED),
              title: 'Lokasi / Maps Agen',
              subtitle: 'Kalibanteng, Semarang',
              onTap: () => onSelect('maps'),
            ),
            const Divider(height: 9, color: Color(0x0A000000)),
            ActionRow(
              icon: Icons.manage_accounts,
              iconColor: AppColors.primary,
              iconBg: const Color(0xFFFFFBEB),
              title: 'Update User & Password',
              subtitle: 'Ubah akun kasir',
              onTap: () => onSelect('user'),
            ),
            ActionRow(
              icon: Icons.logout,
              iconColor: AppColors.red,
              iconBg: AppColors.redLight,
              title: 'Keluar',
              subtitle: 'Logout akun kasir',
              onTap: () => onSelect('logout'),
            ),
          ],
        ),
      ),
    );
  }
}
