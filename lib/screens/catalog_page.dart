import 'package:flutter/material.dart';

import '../data/products.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../theme.dart';
import '../widgets/product_card.dart';
import '../widgets/shell_widgets.dart';

/// Tab Katalog (isi katalog.html): search, segmented control, grid produk.
class CatalogPage extends StatefulWidget {
  const CatalogPage({
    super.key,
    required this.cart,
    required this.subtitle,
    required this.onMenu,
    required this.onAdd,
    required this.onRemove,
    required this.onDetail,
  });

  final Cart cart;
  final String subtitle;
  final VoidCallback onMenu;
  final ValueChanged<Product> onAdd;
  final ValueChanged<Product> onRemove;
  final ValueChanged<Product> onDetail;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final TextEditingController _search = TextEditingController();
  final FocusNode _focus = FocusNode();
  String _category = 'semua';
  String _query = '';
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  List<Product> get _filtered {
    final q = _query.trim().toLowerCase();
    return kProducts.where((p) {
      final okCategory = _category == 'semua' || p.category == _category;
      final okQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.fullName.toLowerCase().contains(q) ||
          p.subtitle.toLowerCase().contains(q) ||
          p.categoryLabel.toLowerCase().contains(q);
      return okCategory && okQuery;
    }).toList();
  }

  Widget _searchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _focused ? Colors.white : const Color(0xCCE3E3E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focused
              ? AppColors.primary.withAlpha(77)
              : const Color(0x08000000),
          width: _focused ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: AppColors.subtle),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _search,
              focusNode: _focus,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(fontSize: 15, color: Colors.black),
              cursorColor: AppColors.primary,
              decoration: const InputDecoration(
                hintText: 'Cari menu kopi, teh, gorengan...',
                hintStyle: TextStyle(fontSize: 15, color: AppColors.subtle),
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          if (_query.isNotEmpty)
            GestureDetector(
              onTap: () {
                _search.clear();
                setState(() => _query = '');
              },
              child:
                  const Icon(Icons.cancel, size: 18, color: AppColors.subtle),
            ),
        ],
      ),
    );
  }

  Widget _segments() {
    final options = <(String, String)>[
      ('semua', 'Semua (${kProducts.length})'),
      ('minuman', 'Minuman'),
      ('camilan', 'Camilan'),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xE6E3E3E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _category = o.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        _category == o.$1 ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: _category == o.$1
                        ? const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    o.$2,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          _category == o.$1 ? FontWeight.w600 : FontWeight.w500,
                      color: _category == o.$1
                          ? Colors.black
                          : const Color(0xFF636366),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final cols = w < 600 ? 2 : (w < 820 ? 3 : 4);
        const pad = 16.0;
        const gap = 12.0;
        final itemW = (w - pad * 2 - gap * (cols - 1)) / cols;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: CustomScrollView(
              slivers: [
                // Header ikut ke-scroll bersama konten.
                SliverToBoxAdapter(
                  child: AppHeader(
                    subtitle: widget.subtitle,
                    onMenu: widget.onMenu,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(pad, 8, pad, 0),
                    child: Column(
                      children: [
                        _searchBar(),
                        const SizedBox(height: 12),
                        _segments(),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
                if (items.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text(
                          'Menu tidak ditemukan',
                          style: TextStyle(color: AppColors.subtle),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(pad, 0, pad, 190),
                    sliver: ListenableBuilder(
                      listenable: widget.cart,
                      builder: (context, _) => SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          mainAxisSpacing: gap,
                          crossAxisSpacing: gap,
                          mainAxisExtent: itemW + 90,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final p = items[i];
                            return ProductCard(
                              product: p,
                              remaining: p.stock - widget.cart.qtyOf(p),
                              onAdd: () => widget.onAdd(p),
                              onRemove: () => widget.onRemove(p),
                              onDetail: () => widget.onDetail(p),
                            );
                          },
                          childCount: items.length,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
