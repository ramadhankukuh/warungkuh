import 'package:flutter/foundation.dart';

import '../config.dart';
import 'product.dart';

class CartLine {
  final Product product;
  int qty;
  CartLine(this.product, this.qty);

  int get total => product.price * qty;
}

/// Keranjang penjualan (Total Jual).
class Cart extends ChangeNotifier {
  final Map<String, CartLine> _lines = {};

  List<CartLine> get lines => _lines.values.toList(growable: false);
  bool get isEmpty => _lines.isEmpty;

  int get itemCount => _lines.values.fold<int>(0, (s, l) => s + l.qty);
  int get subtotal => _lines.values.fold<int>(0, (s, l) => s + l.total);
  int get tax => (subtotal * kTaxRate).round();
  int get total => subtotal + tax;

  int qtyOf(Product p) => _lines[p.id]?.qty ?? 0;

  /// Tambah 1 item. Return false jika stok tidak cukup.
  bool add(Product p) {
    final current = qtyOf(p);
    if (current >= p.stock) return false;
    final line = _lines[p.id];
    if (line == null) {
      _lines[p.id] = CartLine(p, 1);
    } else {
      line.qty += 1;
    }
    notifyListeners();
    return true;
  }

  void decrement(Product p) {
    final line = _lines[p.id];
    if (line == null) return;
    line.qty -= 1;
    if (line.qty <= 0) _lines.remove(p.id);
    notifyListeners();
  }

  void clear() {
    if (_lines.isEmpty) return;
    _lines.clear();
    notifyListeners();
  }

  /// Transaksi selesai: kurangi stok lalu kosongkan keranjang.
  void checkout() {
    for (final l in _lines.values) {
      l.product.stock -= l.qty;
    }
    clear();
  }
}
