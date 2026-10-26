class SharedPreferences {
  SharedPreferences._();

  static final SharedPreferences _instance = SharedPreferences._();
  final Map<String, Object> _values = <String, Object>{};

  static Future<SharedPreferences> getInstance() async => _instance;

  bool containsKey(String key) => _values.containsKey(key);

  String? getString(String key) => _values[key] as String?;

  bool? getBool(String key) => _values[key] as bool?;

  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  Future<bool> setBool(String key, bool value) async {
    _values[key] = value;
    return true;
  }
}

class UserProfile {
  final String nama;
  final String username;
  const UserProfile({required this.nama, required this.username});
}

/// Login user memakai Shared Preferences (Latihan 7).
///
/// Catatan: password disimpan apa adanya karena ini tugas kuliah.
/// Untuk aplikasi produksi gunakan hashing + secure storage.
class AuthService {
  AuthService._();

  static const _kNama = 'nama_lengkap';
  static const _kUser = 'username';
  static const _kPass = 'password';
  static const _kLogged = 'is_logged_in';

  static Future<bool> hasAccount() async {
    final p = await SharedPreferences.getInstance();
    return p.containsKey(_kUser) && p.containsKey(_kPass);
  }

  static Future<void> register({
    required String nama,
    required String username,
    required String password,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kNama, nama);
    await p.setString(_kUser, username);
    await p.setString(_kPass, password);
    await p.setBool(_kLogged, true);
  }

  static Future<bool> login(String username, String password) async {
    final p = await SharedPreferences.getInstance();
    final ok =
        p.getString(_kUser) == username && p.getString(_kPass) == password;
    if (ok) await p.setBool(_kLogged, true);
    return ok;
  }

  static Future<bool> isLoggedIn() async {
    final p = await SharedPreferences.getInstance();
    final logged = p.getBool(_kLogged) ?? false;
    return logged && p.containsKey(_kUser) && p.containsKey(_kPass);
  }

  static Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kLogged, false);
  }

  static Future<UserProfile> profile() async {
    final p = await SharedPreferences.getInstance();
    return UserProfile(
      nama: p.getString(_kNama) ?? 'Kasir',
      username: p.getString(_kUser) ?? '',
    );
  }

  static Future<void> updateCredentials({
    required String username,
    required String password,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kUser, username);
    await p.setString(_kPass, password);
  }
}
