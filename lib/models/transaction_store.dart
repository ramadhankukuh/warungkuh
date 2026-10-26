import 'package:flutter/foundation.dart';

import 'receipt.dart';

/// Riwayat transaksi selama aplikasi berjalan (untuk tab Transaksi & Laporan).
class TransactionStore extends ChangeNotifier {
  TransactionStore._();
  static final TransactionStore instance = TransactionStore._();

  final List<ReceiptData> _items = [];

  /// Terbaru di atas.
  List<ReceiptData> get items => _items.reversed.toList(growable: false);
  bool get isEmpty => _items.isEmpty;

  void add(ReceiptData r) {
    _items.add(r);
    notifyListeners();
  }
}
