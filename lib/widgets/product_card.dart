import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme.dart';
import '../utils/format.dart';

/// Gambar produk offline dengan fallback jika aset bermasalah.
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url, this.fit = BoxFit.cover});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      url,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return Container(
          color: const Color(0xFFF0EDEF),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stack) => Container(
        color: const Color(0xFFF0EDEF),
        alignment: Alignment.center,
        child: const Icon(Icons.fastfood_rounded,
            size: 40, color: AppColors.subtle),
      ),
    );
  }
}

/// Kartu produk (mengikuti `.product-item` pada katalog.html).
/// - ketuk FOTO       -> tambah ke Total Jual
/// - tahan FOTO       -> kurangi 1
/// - ketuk NAMA / (i) -> deskripsi produk
class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.remaining,
    required this.onAdd,
    required this.onRemove,
    required this.onDetail,
  });

  final Product product;
  final int remaining;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDetail;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final soldOut = widget.remaining <= 0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x0A000000)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: AnimatedScale(
              scale: _pressed ? 0.96 : 1,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onAdd,
                  onLongPress: widget.onRemove,
                  onTapDown: (_) => setState(() => _pressed = true),
                  onTapUp: (_) => setState(() => _pressed = false),
                  onTapCancel: () => setState(() => _pressed = false),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ProductImage(url: p.imageUrl),
                      // gradient + hint "Ketuk foto: + Jual"
                      const Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0x80000000), Color(0x00000000)],
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(6, 14, 6, 6),
                          ),
                        ),
                      ),
                      // pill habis (teks stok dihapus)
                      if (soldOut)
                        Positioned(
                          left: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xCCFF3B30),
                              borderRadius: BorderRadius.circular(99),
                              border:
                                  Border.all(color: const Color(0x33FFFFFF)),
                            ),
                            child: const Text(
                              'Habis',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      // tombol +
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Color(0x4D000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 3)),
                            ],
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 19),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: widget.onDetail,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primary.withAlpha(102),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  p.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.subtle),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0x0A000000))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    rupiah(p.price),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onDetail,
                  child: const Icon(Icons.info_outline,
                      size: 17, color: AppColors.tertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
