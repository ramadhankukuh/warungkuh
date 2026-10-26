import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme.dart';

/// Menu: Update User & Password.
class UpdateUserScreen extends StatefulWidget {
  const UpdateUserScreen({super.key});

  @override
  State<UpdateUserScreen> createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _user = TextEditingController();
  final _pass = TextEditingController();
  String _nama = '';
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await AuthService.profile();
    if (!mounted) return;
    setState(() {
      _nama = p.nama;
      _user.text = p.username;
    });
  }

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    await AuthService.updateCredentials(
      username: _user.text.trim(),
      password: _pass.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
          const SnackBar(content: Text('User & password berhasil diperbarui')));
    Navigator.of(context).pop(true);
  }

  InputDecoration _decoration(String label, {Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update User & Password')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: cardBox(radius: 22),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_nama.isNotEmpty) ...[
                      Text(
                        _nama,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ubah username dan password akun kasir',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.subtle, fontSize: 13),
                      ),
                      const SizedBox(height: 18),
                    ],
                    TextFormField(
                      controller: _user,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: _decoration('User'),
                      validator: (v) {
                        final t = v?.trim() ?? '';
                        if (t.length < 3) return 'Username minimal 3 karakter';
                        if (t.contains(' ')) return 'Username tanpa spasi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _pass,
                      obscureText: _obscure,
                      onFieldSubmitted: (_) => _update(),
                      decoration: _decoration(
                        'Password baru',
                        suffix: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 4)
                          ? 'Password minimal 4 karakter'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                              onPressed: _update, child: const Text('Update')),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
