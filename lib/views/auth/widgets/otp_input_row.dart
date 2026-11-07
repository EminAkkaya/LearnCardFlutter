import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_palette.dart';

class OtpInputRow extends StatelessWidget {
  final int otpLength;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final Function(int index, String value) onDigitChanged;
  final Function(int index, KeyEvent event) onKeyEvent;

  const OtpInputRow({
    super.key,
    this.otpLength = 6,
    required this.controllers,
    required this.focusNodes,
    required this.onDigitChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    final radius = BorderRadius.circular(AppPalette.radiusControl);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(otpLength, (index) {
        return SizedBox(
          width: 48,
          height: 58,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) => onKeyEvent(index, event),
            child: TextFormField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: palette.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(6),
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: WidgetStateColor.resolveWith(
                  (states) => states.contains(WidgetState.focused) ? palette.card : palette.subtle,
                ),
                border: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide(color: palette.controlBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide(color: palette.controlBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                ),
              ),
              onChanged: (val) => onDigitChanged(index, val),
            ),
          ),
        );
      }),
    );
  }
}
