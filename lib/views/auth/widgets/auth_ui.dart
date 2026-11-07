import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/feedback_colors.dart';

/// Giriş/kayıt ekranlarının ortak form alanı görünümü: subtle zemin, kontrol
/// kenarlığı (tema), odakta kart zemini ve vurgu kenarı.
InputDecoration authInputDecoration(
  BuildContext context, {
  required String labelText,
  String? hintText,
  IconData? prefixIcon,
  Widget? suffixIcon,
}) {
  final palette = AppPalette.of(context);
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 18),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: WidgetStateColor.resolveWith(
      (states) => states.contains(WidgetState.focused) ? palette.card : palette.subtle,
    ),
  );
}

/// Şifre alanındaki göster/gizle düğmesi.
class PasswordVisibilityButton extends StatelessWidget {
  final bool obscured;
  final VoidCallback onPressed;

  const PasswordVisibilityButton({super.key, required this.obscured, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: obscured ? 'Şifreyi göster' : 'Şifreyi gizle',
      icon: Icon(obscured ? LucideIcons.eyeOff : LucideIcons.eye, size: 18),
      onPressed: onPressed,
    );
  }
}

enum AuthSnackTone { success, error, info }

/// Durum bildirimi: tona göre renk + ikon + metin.
void showAuthSnackBar(
  BuildContext context,
  String message, {
  AuthSnackTone tone = AuthSnackTone.info,
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    buildAuthSnackBar(context, message, tone: tone, action: action),
  );
}

SnackBar buildAuthSnackBar(
  BuildContext context,
  String message, {
  AuthSnackTone tone = AuthSnackTone.info,
  SnackBarAction? action,
}) {
  final feedback = FeedbackColors.of(context);
  final (color, icon) = switch (tone) {
    AuthSnackTone.success => (feedback.success, LucideIcons.circleCheck),
    AuthSnackTone.error => (feedback.danger, LucideIcons.circleAlert),
    AuthSnackTone.info => (feedback.info, LucideIcons.info),
  };
  return SnackBar(
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    action: action,
    content: Row(
      children: [
        Icon(icon, size: 18, color: feedback.onAccent),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: TextStyle(color: feedback.onAccent))),
      ],
    ),
  );
}

/// Dolu birincil buton içindeki yükleniyor göstergesi.
class ButtonSpinner extends StatelessWidget {
  const ButtonSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
