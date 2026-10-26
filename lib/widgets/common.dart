import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme.dart';

/// Efek "ios-blur" (backdrop blur + warna putih transparan).
class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.child,
    this.color = const Color(0xD9FFFFFF),
    this.radius = 24,
    this.sigma = 18,
    this.border,
    this.shadow,
  });

  final Widget child;
  final Color color;
  final double radius;
  final double sigma;
  final BoxBorder? border;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(borderRadius: r, boxShadow: shadow),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: Container(
            decoration:
                BoxDecoration(color: color, borderRadius: r, border: border),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Foto profil kasir (logo WarungKuh).
class AvatarImage extends StatelessWidget {
  const AvatarImage({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        'assets/logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}

/// Baris aksi: ikon bulat berwarna + judul + keterangan.
class ActionRow extends StatelessWidget {
  const ActionRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.subtle)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tombol tutup bulat (X) pada sheet.
class CloseCircleButton extends StatelessWidget {
  const CloseCircleButton({super.key, required this.onTap, this.size = 32});

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCCE5E5EA),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(Icons.close,
              size: size * 0.56, color: const Color(0xFF525252)),
        ),
      ),
    );
  }
}

/// Garis putus-putus (pemisah pada struk).
class DashedLine extends StatelessWidget {
  const DashedLine({super.key, this.vertical = 8});

  final double vertical;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical),
      child: LayoutBuilder(
        builder: (context, box) {
          final n = (box.maxWidth / 6).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              n,
              (_) => Container(
                  width: 3.5, height: 1, color: const Color(0xFFD4D4D4)),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Toast "pill" hitam di atas layar (seperti #ios-toast pada desain).
// ---------------------------------------------------------------------------

OverlayEntry? _toastEntry;
Timer? _toastTimer;

void showPillToast(BuildContext context, String message) {
  _toastTimer?.cancel();
  try {
    _toastEntry?.remove();
  } catch (_) {}
  final overlay = Overlay.of(context, rootOverlay: true);
  final entry = OverlayEntry(builder: (_) => _PillToast(message: message));
  _toastEntry = entry;
  overlay.insert(entry);
  _toastTimer = Timer(const Duration(milliseconds: 2300), () {
    try {
      entry.remove();
    } catch (_) {}
    if (identical(_toastEntry, entry)) _toastEntry = null;
  });
}

class _PillToast extends StatelessWidget {
  const _PillToast({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + 12;
    return Positioned(
      top: top,
      left: 24,
      right: 24,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          builder: (context, v, child) => Opacity(
            opacity: v,
            child: Transform.translate(
                offset: Offset(0, -18 * (1 - v)), child: child),
          ),
          child: Center(
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xE6000000),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: const Color(0x33FFFFFF)),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x40000000),
                        blurRadius: 18,
                        offset: Offset(0, 8)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.done, size: 18, color: Color(0xFFFBBF24)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
