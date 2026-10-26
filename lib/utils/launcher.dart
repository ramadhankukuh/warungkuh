import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Buka telepon / SMS / Maps / WhatsApp lewat aplikasi bawaan perangkat.
Future<bool> _launchExternal(Uri uri) async {
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> openExternal(
  BuildContext context,
  Uri uri, {
  String failMessage = 'Tidak dapat membuka aplikasi tujuan di perangkat ini',
}) async {
  var ok = false;
  try {
    ok = await _launchExternal(uri);
  } catch (_) {
    ok = false;
  }
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(failMessage)));
  }
}
