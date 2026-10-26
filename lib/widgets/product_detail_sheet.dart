import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme.dart';
import '../utils/format.dart';
import 'common.dart';

/// Sheet detail produk (mengikuti #product-detail-modal pada katalog.html).
class ProductDetailSheet extends StatelessWidget {
  const ProductDetailSheet({
    super.key,
    required this.product,
    required this.remaining,
    required this.onAdd,
  });

  final Product product;
  final int remaining;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final available = remaining > 0;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.tertiary,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.categoryLabel.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                CloseCircleButton(onTap: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              rupiah(product.price),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deskripsi & Racikan:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Color(0xE63C3C43),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 10,
                  child: _SheetButton(
                    label: 'Tutup',
                    background: AppColors.separator,
                    foreground: Colors.black,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 15,
                  child: _SheetButton(
                    label: '+ Masuk Jual',
                    icon: Icons.add_shopping_cart,
                    background: AppColors.primary,
                    foreground: Colors.white,
                    shadow: true,
                    onTap: available
                        ? () {
                            Navigator.of(context).pop();
                            onAdd();
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.icon,
    this.shadow = false,
  });

  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;
  final bool shadow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: shadow
              ? const [
                  BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 8,
                      offset: Offset(0, 3))
                ]
              : null,
        ),
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: foreground),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          icon != null ? FontWeight.w700 : FontWeight.w600,
                      color: foreground,
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
