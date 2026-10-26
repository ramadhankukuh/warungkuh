import '../config.dart';
import '../utils/format.dart';

class ReceiptLine {
  final String name;
  final int qty;
  final int price;
  const ReceiptLine(
      {required this.name, required this.qty, required this.price});

  int get total => qty * price;
}

class ReceiptData {
  final String invoice;
  final DateTime time;
  final String kasir;
  final List<ReceiptLine> lines;
  final int subtotal;
  final int tax;
  final int total;
  final String method; // 'Tunai' | 'QRIS'
  final int tendered;
  final int change;

  const ReceiptData({
    required this.invoice,
    required this.time,
    required this.kasir,
    required this.lines,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.method,
    required this.tendered,
    required this.change,
  });

  /// Teks struk untuk dikirim lewat WhatsApp.
  String toPlainText() {
    final b = StringBuffer();
    b.writeln(kStoreName);
    b.writeln(kStoreAddress);
    b.writeln('No: $invoice');
    b.writeln(formatDateTime(time));
    b.writeln('Kasir: $kasir');
    b.writeln('--------------------------');
    for (final l in lines) {
      b.writeln(l.name);
      b.writeln('  ${l.qty}x @ ${rupiah(l.price)} = ${rupiah(l.total)}');
    }
    b.writeln('--------------------------');
    b.writeln('Subtotal : ${rupiah(subtotal)}');
    b.writeln('PB1 (10%): ${rupiah(tax)}');
    b.writeln('TOTAL    : ${rupiah(total)}');
    b.writeln('Bayar ($method): ${rupiah(tendered)}');
    if (method == 'Tunai') b.writeln('Kembali  : ${rupiah(change)}');
    b.writeln('--------------------------');
    b.writeln('Thank you for your order!');
    return b.toString();
  }
}
