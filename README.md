# WarungKuh POS

Aplikasi kasir WarungKuh berbasis Flutter. Logo dan seluruh gambar produk
disimpan sebagai aset lokal sehingga aplikasi dapat digunakan tanpa internet.

## Menjalankan aplikasi

```powershell
flutter pub get
flutter run
```

## Membuat APK untuk dibagikan

```powershell
flutter build apk --release
```

File hasil build berada di:

```text
build\app\outputs\flutter-apk\app-release.apk
```

Salin file tersebut ke HP Android, buka file APK, lalu izinkan instalasi dari
sumber ini jika diminta. Folder `assets` tidak perlu dibagikan terpisah karena
semua aset sudah dikompilasi ke dalam APK.

## Aset lokal

- Logo: `assets/logo.png`
- Gambar produk: `assets/products/`

Jika menambahkan gambar baru, daftarkan folder atau file tersebut di bagian
`flutter.assets` pada `pubspec.yaml`, kemudian jalankan `flutter pub get` dan
build ulang.
