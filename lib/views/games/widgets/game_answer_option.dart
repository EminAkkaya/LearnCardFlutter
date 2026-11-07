import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/feedback_colors.dart';

/// Cevap şıkkının durumu: cevaplanmadan önce [idle]; cevaptan sonra doğru şık
/// [correct], kullanıcının yanlış seçimi [wrong], diğerleri [neutral].
enum GameOptionState { idle, neutral, correct, wrong }

/// Çoktan seçmeli şık. Geri bildirim renk + ikon (check/x) + metin üçlüsüyle verilir.
class GameAnswerOption extends StatelessWidget {
  final String text;
  final GameOptionState state;
  final VoidCallback? onPressed;

  const GameAnswerOption({
    super.key,
    required this.text,
    required this.state,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final fb = FeedbackColors.of(context);

    var bg = p.card;
    var border = p.controlBorder;
    var fg = p.textPrimary;
    IconData? icon;
    String? status;

    switch (state) {
      case GameOptionState.correct:
        bg = fb.successContainer;
        border = fb.success;
        fg = fb.success;
        icon = LucideIcons.check;
        status = 'Doğru';
      case GameOptionState.wrong:
        bg = fb.dangerContainer;
        border = fb.danger;
        fg = fb.danger;
        icon = LucideIcons.x;
        status = 'Yanlış';
      case GameOptionState.neutral:
        border = p.border;
        fg = p.textSecondary;
      case GameOptionState.idle:
        break;
    }

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppPalette.radiusControl),
      side: BorderSide(color: border, width: icon != null ? 1.5 : 1),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            disabledBackgroundColor: bg,
            disabledForegroundColor: fg,
            elevation: 0,
            minimumSize: const Size.fromHeight(48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: shape,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: fg),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, color: fg, size: 18),
                const SizedBox(width: 4),
                Text(
                  status!,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
