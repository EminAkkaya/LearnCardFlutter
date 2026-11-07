import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/text_parser.dart';
import '../../../models/reader_theme.dart';
import 'reader_word_style.dart';

class ReaderParagraph extends ConsumerStatefulWidget {
  final String text;
  final bool isFocusMode;
  final Map<String, String> cardMap;
  final ReaderThemeColors colors;
  final Function(String) onWordTap;
  final double fontSize;
  final double lineHeight;

  const ReaderParagraph({
    super.key,
    required this.text,
    required this.isFocusMode,
    required this.cardMap,
    required this.colors,
    required this.onWordTap,
    required this.fontSize,
    required this.lineHeight,
  });

  @override
  ConsumerState<ReaderParagraph> createState() => _ReaderParagraphState();
}

class _ReaderParagraphState extends ConsumerState<ReaderParagraph> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    _clearRecognizers();
    super.dispose();
  }

  void _clearRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.trim().isEmpty) {
      return const SizedBox(height: 16);
    }

    _clearRecognizers();
    final tokens = TextParser.parseTextToTokens(widget.text);
    final List<InlineSpan> spans = [];
    final double effectiveFontSize = widget.isFocusMode
        ? widget.fontSize + 2.0
        : widget.fontSize;
    final double effectiveLineHeight = widget.lineHeight;

    for (final token in tokens) {
      if (!token.isWord) {
        spans.add(
          TextSpan(
            text: token.text,
            style: TextStyle(
              fontSize: effectiveFontSize,
              height: effectiveLineHeight,
              color: widget.colors.defaultText,
            ),
          ),
        );
      } else {
        final recognizer = TapGestureRecognizer()
          ..onTap = () => widget.onWordTap(token.cleanWord);
        _recognizers.add(recognizer);

        final status = widget.cardMap[token.cleanWord];
        final look = ReaderWordStyle.forStatus(status, widget.colors);

        spans.add(
          TextSpan(
            text: token.text,
            style: TextStyle(
              fontSize: effectiveFontSize,
              fontWeight: status != null ? FontWeight.w600 : FontWeight.w400,
              color: look.color,
              height: effectiveLineHeight,
              decoration: TextDecoration.underline,
              decorationColor: look.underline,
              decorationStyle: look.pattern,
              decorationThickness: look.thickness,
            ),
            recognizer: recognizer,
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text.rich(TextSpan(children: spans)),
    );
  }
}
