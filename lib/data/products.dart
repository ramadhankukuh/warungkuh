import '../models/product.dart';

/// Daftar produk.
final List<Product> kProducts = [
  Product(
    id: 'p1',
    name: 'Es Teh Jumbo',
    fullName: 'Es Teh Jumbo',
    subtitle: 'Cup 22oz Dingin',
    category: 'minuman',
    categoryLabel: 'Minuman Segar',
    price: 3500,
    stock: 25,
    description:
        'Es teh melati jumbo dengan takaran gula pasir murni khas racikan WarungKuh, disajikan dingin dengan cup 22oz mantap.',
    imageUrl: 'assets/products/es_teh_jumbo.jpg',
  ),
  Product(
    id: 'p2',
    name: 'Lumpia Goreng',
    fullName: 'Lumpia Goreng Spesial',
    subtitle: 'Rebung & Ayam Gurih',
    category: 'camilan',
    categoryLabel: 'Jajanan & Gorengan',
    price: 5000,
    stock: 18,
    description:
        'Lumpia rebung & ayam khas WarungKuh, renyah gurih dengan cocolan saus tauco manis pedas dan lokio segar.',
    imageUrl: 'assets/products/lumpia_goreng.jpg',
  ),
  Product(
    id: 'p3',
    name: 'Es Teh Kampul Jeruk',
    fullName: 'Es Teh Kampul Jeruk Peras',
    subtitle: 'Jeruk Peras Segar',
    category: 'minuman',
    categoryLabel: 'Minuman Segar',
    price: 5000,
    stock: 30,
    description:
        'Kombinasi teh wangi melati tubruk dan irisan jeruk peras lokal segar terapung, asam manis segar mantap.',
    imageUrl: 'assets/products/es_teh_kampul_jeruk.jpg',
  ),
  Product(
    id: 'p4',
    name: 'Tahu Bakso',
    fullName: 'Tahu Bakso Asli',
    subtitle: 'Daging Sapi Pilihan',
    category: 'camilan',
    categoryLabel: 'Jajanan & Gorengan',
    price: 4000,
    stock: 22,
    description:
        'Tahu kulit cokelat padat dengan isian olahan daging sapi khas Semarang, digoreng dadakan saat pesanan tiba.',
    imageUrl: 'assets/products/tahu_bakso.jpg',
  ),
  Product(
    id: 'p5',
    name: 'Mendoan Sambal Kecap',
    fullName: 'Mendoan Hangat Sambal Kecap',
    subtitle: 'Porsi 3 Lembar Besar',
    category: 'camilan',
    categoryLabel: 'Jajanan & Gorengan',
    price: 8000,
    stock: 15,
    description:
        'Tempe kedelai berbalut tepung daun bawang wangi digoreng setengah matang, disajikan isi 3 lembar plus sambal kecap cabe rawit.',
    imageUrl: 'assets/products/mendoan_sambal_kecap.jpg',
  ),
  Product(
    id: 'p6',
    name: 'Kopi Tubruk Robusta',
    fullName: 'Kopi Tubruk Robusta Senja',
    subtitle: 'Seduhan Panas Mantap',
    category: 'minuman',
    categoryLabel: 'Minuman Segar',
    price: 6000,
    stock: 40,
    description:
        'Biji kopi robusta Jawa Tengah giling segar diseduh air panas murni, tebal berkarakter cokelat karamel.',
    imageUrl: 'assets/products/kopi_tubruk_robusta.jpg',
  ),
];
