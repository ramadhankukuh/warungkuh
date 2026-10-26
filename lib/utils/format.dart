/// Format rupiah: 31350 -> "Rp 31.350"
String rupiah(int value) {
  final negative = value < 0;
  final digits = value.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
    buf.write(digits[i]);
  }
  return '${negative ? '-' : ''}Rp $buf';
}

String _two(int n) => n.toString().padLeft(2, '0');

String formatDateTime(DateTime d) =>
    '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';

/// Nomor nota: CK-2026-0001
String invoiceNumber(DateTime d, int seq) =>
    'CK-${d.year}-${seq.toString().padLeft(4, '0')}';

/// "Rp28.500" (tanpa spasi, seperti tombol di desain katalog).
String rupiahTight(int value) => rupiah(value).replaceFirst('Rp ', 'Rp');
