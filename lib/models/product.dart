class Product {
  final String id;
  final String name;

  /// Nama lengkap (dipakai di deskripsi & notifikasi).
  final String fullName;
  final String subtitle;

  /// 'minuman' atau 'camilan'
  final String category;
  final String categoryLabel;
  final int price;

  /// Stok berkurang setelah transaksi selesai.
  int stock;
  final String description;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.fullName,
    required this.subtitle,
    required this.category,
    required this.categoryLabel,
    required this.price,
    required this.stock,
    required this.description,
    required this.imageUrl,
  });
}
